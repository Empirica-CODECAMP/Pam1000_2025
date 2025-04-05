import json
import os
from django.http import JsonResponse
import plotly.express as px
import pandas as pd

from Calculations.models import ModelRun
from Calculations.tasks import execute_r_script
from django.views.decorators.csrf import csrf_exempt


@csrf_exempt
def run_ifrs17_model(request):
    if request.method == "POST":
        try:
            data = json.loads(request.body)
            parameters = data.get("parameters", {})

            # Validate input
            if not parameters:
                return JsonResponse(
                    {"success": False, "message": "Parameters are required"}, status=400
                )

            # Create a new ModelRun instance
            model_run = ModelRun.objects.create(
                model_name="IFRS17 Model",
                input_parameters=json.dumps(parameters),
                status="pending",
            )

            # Enqueue the Celery task
            execute_r_script.delay(model_run.id)

            return JsonResponse(
                {
                    "success": True,
                    "message": "IFRS17 model run initiated successfully",
                    "model_run_id": model_run.id,
                }
            )
        except json.JSONDecodeError:
            return JsonResponse(
                {"success": False, "message": "Invalid JSON"}, status=400
            )
        except Exception as e:
            return JsonResponse(
                {"success": False, "message": "An error occurred", "error": str(e)},
                status=500,
            )

    return JsonResponse(
        {"success": False, "message": "Invalid request method"}, status=405
    )


import subprocess
from django.shortcuts import render, redirect
from .models import ModelRun
from .forms import ModelRunForm


def run_model(request):
    if request.method == "POST":
        form = ModelRunForm(request.POST)
        if form.is_valid():
            # Save the model run instance
            model_run = form.save(commit=False)
            model_run.status = "running"
            model_run.save()

            # Extract parameters to pass to R script
            run_nr = form.cleaned_data["Run_Nr"]
            prev_run_nr = form.cleaned_data["PrevRun_Nr"]
            nb_run_nr = form.cleaned_data["NBRun_Nr"]

            # Get the directory of the current file (usually the view or script)
            rscript_path = os.path.dirname(
                os.path.abspath(__file__)
            )  # Correctly gets the directory of the current script

            # Join it with the relative path to your R script folder and file
            rscript_path = os.path.join(
                rscript_path, "Rscript", "IFRS17model_Portfolio.R"
            )
            try:
                # Run the R script using subprocess
                result = subprocess.run(
                    [
                        "Rscript",
                        rscript_path,
                        str(run_nr),
                        str(prev_run_nr),
                        str(nb_run_nr),
                    ],
                    capture_output=True,
                    text=True,
                )

                if result.returncode == 0:
                    model_run.status = "completed"
                    # Optionally, save the output to a file or process it
                else:
                    model_run.status = "failed"
                    model_run.error_message = result.stderr

            except Exception as e:
                model_run.status = "failed"
                model_run.error_message = str(e)

            model_run.save()
            return redirect("model_run_status", pk=model_run.pk)

    else:
        form = ModelRunForm()

    return render(request, "run_model.html", {"form": form})


from django.shortcuts import render, get_object_or_404
from .models import ModelRun


def model_run_status(request, pk):
    model_run = get_object_or_404(ModelRun, pk=pk)
    return render(request, "model_run_status.html", {"model_run": model_run})


import pandas as pd
import plotly.express as px
from django.shortcuts import render
from django.conf import settings
import os
import os
import pandas as pd
import plotly.express as px
from django.conf import settings
from django.shortcuts import render
from django.views.decorators.clickjacking import xframe_options_exempt


@xframe_options_exempt
def dashboard_charts(request):
    # Define the path dynamically using Django settings
    file_path = os.path.join(
        settings.BASE_DIR,
        "Calculations",
        "Rscript",
        "Output",
        "Combined_Output_2024.xlsx",
    )

    # Read data from the specified Excel file and sheet
    try:
        df = pd.read_excel(file_path, sheet_name="CFS_NB_Insurance")
    except FileNotFoundError:
        # Handle case where file is missing or path is incorrect
        return render(
            request, "admin/dashboard_charts.html", {"error": "Data file not found."}
        )

    # Plot a line chart using Plotly Express
    fig = px.line(
        df,
        x=df.columns[0],
        y=df.columns[1:],
        title="Insurance Dashboard",
        labels={df.columns[0]: "Date", "value": "Value", "variable": "Metrics"},
    )

    # Additional layout customization for the line chart
    fig.update_layout(
        xaxis_title="Month",
        yaxis_title="Financial Metrics",
        template="plotly_white",
        hovermode="x unified",
    )

    # Bar chart for financial metrics
    fig2 = px.bar(
        df,
        x=df.columns[0],
        y=df.columns[1:],
        title="Insurance Dashboard - Bar Chart",
        labels={df.columns[0]: "Month"},
    )

    # Create a histogram for the financial metrics
    # Assuming you're interested in plotting a histogram of the first numeric column of the data
    # Replace 'Value' with the actual column name that you want to plot the histogram for
    fig3 = px.histogram(
        df,
        x=df.columns[1],  # Choose the numeric column for the histogram
        title="Distribution of Financial Metrics",
        labels={df.columns[1]: "Value"},
    )

    # Convert Plotly figures to HTML
    chart = fig.to_html()
    chart2 = fig2.to_html()
    chart3 = fig3.to_html()  # Histogram chart

    # Pass the charts to the template context
    context = {
        "chart": chart,
        "chart2": chart2,
        "chart3": chart3,
    }  # Include histogram chart in the context
    return render(request, "admin/dashboard_charts.html", context)


# def dashboard_charts(request):
#     # Define the path dynamically using Django settings
#     file_path = os.path.join(settings.BASE_DIR, "Calculations", "Rscript", "Output", "Combined_Output_2024.xlsx")

#     # Read data from the specified Excel file and sheet
#     try:
#         df = pd.read_excel(file_path, sheet_name='CFS_NB_Insurance')
#     except FileNotFoundError:
#         # Handle case where file is missing or path is incorrect
#         return render(request, 'admin/index.html', {'error': 'Data file not found.'})

#     # Plot a line chart using Plotly Express
#     fig = px.line(df, x=df.columns[0], y=df.columns[1:],
#                   title="Insurance Dashboard",
#                   labels={
#                       df.columns[0]: "Date",
#                       "value": "Value",
#                       "variable": "Metrics"
#                   })

#     # Additional layout customization
#     fig.update_layout(
#         xaxis_title="Month",
#         yaxis_title="Financial Metrics",
#         template="plotly_white",
#         hovermode="x unified"
#     )

#     # Bar chart for financial metrics
#     fig2 = px.bar(df, x=df.columns[0], y=df.columns[1:],
#                   title="Insurance Dashboard - Bar Chart",
#                   labels={df.columns[0]: "Month"})

#     chart2 = fig2.to_html(full_html=False)
#     # Convert Plotly figure to HTML
#     chart = fig.to_html(full_html=False)

#     # Pass the chart to the template context
#     context = {'chart': chart,
#                'chart2': chart2}
#     return render(request, 'admin/index.html', context)


# dashboard/views.py

from django.shortcuts import render
from .tasks import generate_charts

# def dashboard_charts(request):
#     # Trigger Celery task asynchronously
#     task = generate_charts.apply_async()

#     # Wait for the task to complete (this can be done in a more efficient way)
#     result = task.get(timeout=30)  # You can adjust the timeout as needed

#     if "error" in result:
#         return render(request, 'admin/index.html', {'error': result["error"]})

#     # Extract the charts from the result
#     chart = result["line_chart"]
#     chart2 = result["bar_chart"]

#     # Pass the chart to the template context
#     context = {'chart': chart, 'chart2': chart2}
#     return render(request, 'admin/index.html', context)
# views.py
import os
import subprocess
from django.shortcuts import redirect, render
from .models import ModelRun
from .forms import ModelRunForm


def run_model2(model_instance=None, request=None):
    if request:
        # For admin form submission
        if request.method == "POST":
            form = ModelRunForm(request.POST)
            if form.is_valid():
                model_instance = form.save(commit=False)
                model_instance.status = "running"
                model_instance.save()
                # Assign cleaned data for manual request
                run_nr = form.cleaned_data["Run_Nr"]
                prev_run_nr = form.cleaned_data["PrevRun_Nr"]
                nb_run_nr = form.cleaned_data["NBRun_Nr"]
    elif model_instance:
        # For signal-based runs
        model_instance.status = "running"
        model_instance.save()
        # Use model instance data for automatic run
        run_nr = model_instance.Run_Nr
        prev_run_nr = model_instance.PrevRun_Nr
        nb_run_nr = model_instance.NBRun_Nr

    # Define path to the R script
    rscript_path = os.path.join(
        os.path.dirname(os.path.abspath(__file__)), "Rscript", "IFRS17model_Portfolio.R"
    )

    try:
        # Run the R script using subprocess
        result = subprocess.run(
            ["Rscript", rscript_path, str(run_nr), str(prev_run_nr), str(nb_run_nr)],
            capture_output=True,
            text=True,
            check=True,
        )
        model_instance.status = "completed"
    except subprocess.CalledProcessError as e:
        model_instance.status = "failed"
        model_instance.error_message = e.stderr
    except Exception as e:
        model_instance.status = "failed"
        model_instance.error_message = str(e)

    model_instance.save()

    # Redirect if a request exists; otherwise, no redirect for auto-run
    if request:
        return redirect("model_run_status", pk=model_instance.pk)
    return None


from django.shortcuts import render, get_object_or_404, redirect
from django.http import JsonResponse, HttpResponse
from .models import CashflowVariables
import json
from django.views.decorators.csrf import csrf_exempt


@xframe_options_exempt
def fcf_vars_page(request):
    # Render the HTML page for CRUD operations
    return render(request, "fcf_vars.html")


@csrf_exempt
def fcf_vars_api(request):
    if request.method == "GET":
        # Read all data
        data = list(CashflowVariables.objects.values())
        return JsonResponse(data, safe=False)

    if request.method == "POST":
        # Create a new entry
        premiums = request.POST.get("premiums")
        claims = request.POST.get("claims")
        admin = request.POST.get("admin")
        acquisitions = request.POST.get("acquisitions")
        type = request.POST.get("type")
        CashflowVariables.objects.create(
            premiums=premiums,
            claims=claims,
            admin=admin,
            acquisitions=acquisitions,
            type=type,
        )
        return JsonResponse({"message": "Created successfully"})

    if request.method == "PUT":
        # Update an entry
        data = json.loads(request.body)
        obj = get_object_or_404(CashflowVariables, id=data.get("id"))
        obj.premiums = data.get("premiums", obj.premiums)
        obj.claims = data.get("claims", obj.claims)
        obj.admin = data.get("admin", obj.admin)
        obj.acquisitions = data.get("acquisitions", obj.acquisitions)
        obj.type = data.get("type", obj.type)
        obj.save()
        return JsonResponse({"message": "Updated successfully"})

    if request.method == "DELETE":
        # Delete an entry
        data = json.loads(request.body)
        obj = get_object_or_404(CashflowVariables, id=data.get("id"))
        obj.delete()
        return JsonResponse({"message": "Deleted successfully"})
