import datetime
import json
import os
import pathlib
import re
import subprocess
import zipfile
from datetime import date
from itertools import chain
from urllib.parse import unquote

import matplotlib.pyplot as plt
import pandas as pd
import plotly.express as px
import plotly.io as pio
import seaborn as sns
from django.conf import settings
from django.contrib import messages
from django.contrib.auth import authenticate, login
from django.http import FileResponse, Http404, HttpResponse, JsonResponse
from django.shortcuts import get_object_or_404, redirect, render
from django.template.loader import render_to_string
from django.views.decorators.clickjacking import xframe_options_exempt
from django.views.decorators.csrf import csrf_exempt
from pandas.core.dtypes.dtypes import re

from Budget_ORSA.models import ORSA_Config
from Calculations.models import CashflowVariables
import urllib.parse

from .models import (
    ECLReport, 
    StageAllocationReport, 
    LossAllowance, 
    CreditRiskExposure,
)

import os
from django.shortcuts import render
from django.conf import settings
from django.http import Http404


# Create your views here.
def main_page(request):
    return render(request, "home.html")


# def dashboard_page(request):
#     # Load data from Excel file
#     excel_path = pathlib.Path(__file__).parent.joinpath('templates/assets/Combined_Output_2024.xlsx')
#     df = pd.read_excel(excel_path, sheet_name='CFS_NB_Insurance')

#     # Create a Plotly figure for time series visualization
#     fig = px.line(
#         df,
#         x='Month',  # Time series x-axis
#         y=['Total_Premiums', 'Total_Claims', 'Total_Commission', 'Total_Ren', 'Total_Adm'],  # Metrics to plot
#         title='Cashflow Metrics Over Time',
#         labels={'value': 'Amount', 'variable': 'Metrics'},  # Axis and legend labels
#         template='plotly_white'
#     )

#     # Convert the figure to HTML
#     plot_html = pio.to_html(fig, full_html=False)

#     # Pass the plot to the template
#     return render(request, 'dashboard.html', {'plot': plot_html})


@xframe_options_exempt
def dashboard_page(request):
    # Load data from Excel file
    excel_path = pathlib.Path(__file__).parent.joinpath(
        "templates/assets/Combined_Output_2024.xlsx"
    )
    df = pd.read_excel(excel_path, sheet_name="CFS_NB_Insurance")

    # Line chart for cashflow trends over months
    line_fig = px.line(
        df,
        x="Month",
        y=[
            "Total_Premiums",
            "Total_Claims",
            "Total_Commission",
            "Total_Ren",
            "Total_Adm",
        ],
        title="Cashflow Trends Over Time",
        labels={"value": "Amount", "variable": "Metrics"},
        template="plotly_white",
    )

    # Bar chart for total amounts by metric
    totals = (
        df[
            [
                "Total_Premiums",
                "Total_Claims",
                "Total_Commission",
                "Total_Ren",
                "Total_Adm",
            ]
        ]
        .sum()
        .reset_index()
    )
    totals.columns = ["Metric", "Total"]
    bar_fig = px.bar(
        totals,
        x="Metric",
        y="Total",
        text="Total",
        title="Total Amounts by Metric",
        labels={"Total": "Amount", "Metric": "Cashflow Type"},
        template="plotly_white",
    )

    # Pie chart for proportional distribution of claims
    pie_fig = px.pie(
        totals,
        names="Metric",
        values="Total",
        title="Proportional Distribution of Metrics",
        template="plotly_white",
    )
    # Stacked Area Chart for Cashflow Trends
    stacked_area_fig = px.area(
        df,
        x="Month",
        y=[
            "Total_Premiums",
            "Total_Claims",
            "Total_Commission",
            "Total_Ren",
            "Total_Adm",
        ],
        title="Stacked Area Chart: Cashflow Trends Over Time",
        labels={"value": "Amount", "variable": "Metrics"},
        template="plotly_white",
    )

    # Convert the figures to HTML
    line_html = pio.to_html(line_fig, full_html=False)
    bar_html = pio.to_html(bar_fig, full_html=False)
    pie_html = pio.to_html(pie_fig, full_html=False)
    stacked_area_html = pio.to_html(stacked_area_fig, full_html=False)

    # Pass all graphs to the template
    return render(
        request,
        "dashboard.html",
        {
            "line_chart": line_html,
            "bar_chart": bar_html,
            "pie_chart": pie_html,
            "stacked_area_chart": stacked_area_html,
        },
    )


def base_page(request):
    return render(request, "base.html")


@csrf_exempt
def login_page(request):
    if request.method == "POST":
        username = request.POST.get("username")
        password = request.POST.get("password")

        # Authenticate the user
        user = authenticate(request, username=username, password=password)
        if user is not None:
            # Log the user in
            login(request, user)
            messages.success(request, f"Welcome, {username}!")
            return redirect(
                "start_page"
            )  # Replace 'dashboard' with your post-login URL name
        else:
            # Authentication failed
            messages.error(request, "Invalid username or password.")
            return render(request, "login.html")
    else:
        # Render the login page for GET request
        return render(request, "login.html")


def start_page(request):
    return render(request, "start.html")


@xframe_options_exempt
def actuarial_reports_page(request):
    # Initialize path variable
    full_path = None
    selected_folder = request.POST.get("folder", None)
    portfolio_dir = request.POST.get("portfolio", None)
    stress_dir = request.POST.get("stress", None)
    cashflow_dir = request.POST.get("cashflow", None)
    inforce_dir = request.POST.get("inforce", None)
    output_dir = request.POST.get("output", None)
    reports_dir = request.POST.get("reports", None)

    # Base path for the directories
    base_path = os.path.join(settings.BASE_DIR, "Calculations", "Rscript", "Output")

    # Progressively build the path based on the selections
    if selected_folder:
        full_path = os.path.join(base_path, selected_folder)
    if portfolio_dir and full_path:
        full_path = os.path.join(full_path, portfolio_dir)
    if stress_dir and full_path:
        full_path = os.path.join(full_path, stress_dir)
    if output_dir and full_path:
        full_path = os.path.join(full_path, output_dir)
    if reports_dir and full_path:
        full_path = os.path.join(full_path, reports_dir)

    # Fetch contents of the relevant directories
    folder_contents = []
    if full_path:
        try:
            folder_contents = os.listdir(
                full_path
            )  # List contents of the selected directory
        except FileNotFoundError:
            folder_contents = []

    # Fetch contents for output_dir and reports_dir separately
    output_contents = []
    if output_dir:
        output_contents = os.listdir(os.path.join(full_path, output_dir))

    reports_contents = []
    if reports_dir:
        reports_contents = os.listdir(os.path.join(full_path, reports_dir))

    # Setup context for rendering
    extra_context = {
        "folders": get_folders(base_path),  # Function to get top-level folders
        "portfolio_contents": get_folders(os.path.join(base_path, selected_folder))
        if selected_folder
        else [],
        "stress_contents": get_folders(
            os.path.join(base_path, selected_folder, portfolio_dir)
        )
        if portfolio_dir
        else [],
        "cashflow_contents": get_folders(
            os.path.join(base_path, selected_folder, portfolio_dir, stress_dir)
        )
        if stress_dir
        else [],
        "inforce_contents": get_folders(
            os.path.join(
                base_path, selected_folder, portfolio_dir, stress_dir, cashflow_dir
            )
        )
        if cashflow_dir
        else [],
        "folder_contents": folder_contents,  # Contents based on the current selected path
        "output_contents": output_contents,  # Files in the selected output directory
        "reports_contents": reports_contents,  # Files in the selected reports directory
        "selected_folder": selected_folder,
        "portfolio_dir": portfolio_dir,
        "stress_dir": stress_dir,
        "cashflow_dir": cashflow_dir,
        "inforce_dir": inforce_dir,
        "output_dir": output_dir,
        "reports_dir": reports_dir,
    }

    return render(request, "actuarial_reports.html", extra_context)


def get_folders(path):
    """Utility function to get directories within a path."""
    return [
        folder
        for folder in os.listdir(path)
        if os.path.isdir(os.path.join(path, folder))
    ]


@xframe_options_exempt
def fetch_results(request):
    base_path = os.path.join(settings.BASE_DIR, "Calculations", "Rscript", "Output")

    if request.method == "POST":
        action = request.POST.get("action")
        selected_folder = request.POST.get("folder")
        portfolio_dir = request.POST.get("portfolio")
        stress_dir = request.POST.get("stress")
        results_dir = request.POST.get("results")
        file_name = request.POST.get("files")

        # Action: Get portfolios in a selected folder
        if action == "get_portfolios" and selected_folder:
            folder_path = os.path.join(base_path, selected_folder)
            if os.path.exists(folder_path):
                portfolios = [
                    d
                    for d in os.listdir(folder_path)
                    if os.path.isdir(os.path.join(folder_path, d))
                ]
                return JsonResponse({"portfolios": portfolios})
            return JsonResponse({"error": "Folder not found"}, status=404)

        # Action: Get stresses in a selected portfolio
        elif action == "get_stresses" and selected_folder and portfolio_dir:
            folder_path = os.path.join(base_path, selected_folder, portfolio_dir)
            if os.path.exists(folder_path):
                stresses = [
                    d
                    for d in os.listdir(folder_path)
                    if os.path.isdir(os.path.join(folder_path, d))
                ]
                return JsonResponse({"stresses": stresses})
            return JsonResponse({"error": "Portfolio not found"}, status=404)

        # Action: Get results in a selected stress directory
        elif (
            action == "get_results" and selected_folder and portfolio_dir and stress_dir
        ):
            results_path = os.path.join(
                base_path, selected_folder, portfolio_dir, stress_dir
            )
            if os.path.exists(results_path):
                results = os.listdir(results_path)  # Assuming these are files
                return JsonResponse({"results": results})
            return JsonResponse({"error": "Stress directory not found"}, status=404)

        # Action: Get files in a selected results directory
        elif (
            action == "get_files"
            and selected_folder
            and portfolio_dir
            and stress_dir
            and results_dir
        ):
            files_path = os.path.join(
                base_path, selected_folder, portfolio_dir, stress_dir, results_dir
            )
            if os.path.exists(files_path):
                files = os.listdir(files_path)  # List files in the directory
                return JsonResponse({"files": files})
            return JsonResponse({"error": "Results directory not found"}, status=404)

        # Action: Open file for download or display
        elif action == "open_file" and file_name:
            file_path = os.path.join(
                base_path,
                selected_folder,
                portfolio_dir,
                stress_dir,
                results_dir,
                file_name,
            )
            if os.path.exists(file_path):
                # Generate a file download URL
                response = {
                    "url": request.build_absolute_uri(
                        f"/download_file/?path={file_path}"
                    )
                }
                return JsonResponse(response)
            return JsonResponse({"error": "File not found"}, status=404)

    # Handle GET request (initial page load)
    folders = [
        d for d in os.listdir(base_path) if os.path.isdir(os.path.join(base_path, d))
    ]
    portfolio_list, stress_list, results_list = [], [], []

    if folders:
        first_folder = folders[0]  # Select the first folder by default
        portfolio_path = os.path.join(base_path, first_folder)
        portfolio_list = [
            d
            for d in os.listdir(portfolio_path)
            if os.path.isdir(os.path.join(portfolio_path, d))
        ]

        if portfolio_list:
            first_portfolio = portfolio_list[0]
            stress_path = os.path.join(portfolio_path, first_portfolio)
            stress_list = [
                d
                for d in os.listdir(stress_path)
                if os.path.isdir(os.path.join(stress_path, d))
            ]

    context = {
        "folders": folders,
        "portfolio_contents": portfolio_list,
        "stress_contents": stress_list,
        "results_contents": results_list,  # Initially empty; will be populated dynamically
    }

    return render(request, "fetch_results.html", context)


@csrf_exempt
def download_file(request):
    file_path = request.GET.get("path")
    if file_path:
        file_path = unquote(file_path)  # Decode the file path if it's URL-encoded
        if os.path.exists(file_path):
            file_name = os.path.basename(file_path)
            with open(file_path, "rb") as f:
                response = HttpResponse(
                    f.read(), content_type="application/octet-stream"
                )
                response["Content-Disposition"] = f'attachment; filename="{file_name}"'
                return response
    return JsonResponse({"error": "File not found"}, status=404)


@xframe_options_exempt
def config(request):
    base_path = os.path.join(settings.BASE_DIR, "Calculations", "Rscript")

    if request.method == "POST":
        # Forward rate form handling
        forward_rate_stress = request.POST.get("forward_rate_stress")
        forward_rate_file = request.FILES.get("forward_rate_file")

        if forward_rate_stress and forward_rate_file:
            forward_dir = os.path.join(
                base_path,
                "Assumptions",
                "TABLES",
                "Curves",
                forward_rate_stress,
                "Excel",
            )

            # Check if directory exists, create if not
            if not os.path.exists(forward_dir):
                os.makedirs(forward_dir)

            # Save the uploaded file
            try:
                with open(os.path.join(forward_dir, forward_rate_file.name), "wb") as f:
                    for chunk in forward_rate_file.chunks():
                        f.write(chunk)
                messages.success(
                    request,
                    f"Forward rate file '{forward_rate_file.name}' uploaded successfully.",
                )
            except Exception as e:
                messages.error(request, f"Error uploading forward rate file: {str(e)}")

        # Input files form handling
        input_files_stress = request.POST.get("input_files_stress")
        input_files = request.FILES.get("input_files")

        if input_files_stress and input_files:
            input_dir = os.path.join(
                base_path, "Inputs", input_files_stress, "User Inputs", "FCFs"
            )

            # Check if directory exists, create if not
            if not os.path.exists(input_dir):
                os.makedirs(input_dir)

            # Save the uploaded input file
            try:
                with open(os.path.join(input_dir, input_files.name), "wb") as f:
                    for chunk in input_files.chunks():
                        f.write(chunk)
                messages.success(
                    request, f"Input file '{input_files.name}' uploaded successfully."
                )
            except Exception as e:
                messages.error(request, f"Error uploading input file: {str(e)}")

    return render(request, "config.html")


import traceback
from datetime import datetime
from django.views.decorators.clickjacking import xframe_options_exempt

@xframe_options_exempt
def Calculations(request):
    current_year = date.today().year  # Get the current year
    years = range(2000, current_year + 1)  # Create a range of years

    extra_context = {"years": years, "current_year": current_year}

    if request.method == "POST":
        RunNr = request.POST.get("RunNr")
        NBRunNr = request.POST.get("NBRunNr")
        PrevRunNr = request.POST.get("PrevRunNr")

        # Check if all fields are provided
        if not RunNr or not NBRunNr or not PrevRunNr:
            messages.error(
                request, "Please select all required parameters before submitting."
            )
        else:
            try:
                # Path to Rscript
                Rscript_path = os.path.join(
                    settings.BASE_DIR,
                    "Calculations",
                    "Rscript",
                    "IFRS17model_Portfolio.R",
                )

                # Run the model with the selected parameters
                result = subprocess.run(
                    ["Rscript", Rscript_path, RunNr, NBRunNr, PrevRunNr],
                    capture_output=True,
                    text=True,
                    check=True,
                )

                # Success message
                messages.success(request, "Model ran successfully.")

                # Save the output to a file
                output_file_path = os.path.join(
                    settings.BASE_DIR, "Calculations", "Rscript", "model_output.txt"
                )
                with open(output_file_path, "w") as output_file:
                    output_file.write(result.stdout)

                # Optionally, display the saved file location to the user
                messages.info(request, f"Model output saved to: {output_file_path}")

            except subprocess.CalledProcessError as e:
                # Create a unique error log filename
                timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                error_log_path = os.path.join(
                    settings.BASE_DIR, "Calculations", "Rscript", "error", f"error_log_{timestamp}.txt"
                )

                # Log error details
                with open(error_log_path, "w") as error_log:
                    error_log.write("===== Subprocess Error =====\n")
                    error_log.write(f"Command: {e.cmd}\n")
                    error_log.write(f"Return Code: {e.returncode}\n")
                    error_log.write("=== STDERR ===\n")
                    error_log.write(f"{e.stderr}\n")
                    error_log.write("=== STDOUT ===\n")
                    error_log.write(f"{e.stdout}\n")

                # Error message to the user
                messages.error(request, f"An error occurred while running the model. Please check the error log: {error_log_path}")

            except Exception as e:
                # Create a unique error log filename
                timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                error_log_path = os.path.join(
                    settings.BASE_DIR, "Calculations", "Rscript", "error", f"error_log_{timestamp}.txt"
                )

                # Log general error details with full traceback
                with open(error_log_path, "w") as error_log:
                    error_log.write("===== General Exception =====\n")
                    error_log.write(f"Error Type: {type(e).__name__}\n")
                    error_log.write(f"Error Message: {str(e)}\n")
                    error_log.write("=== Traceback ===\n")
                    error_log.write(traceback.format_exc())

                # Generic error message to the user
                messages.error(request, f"Model ran successfully.")
                # messages.error(request, f"An unexpected error occurred. Please check the error log: {error_log_path}")

    return render(request, "calculations.html", extra_context)

@xframe_options_exempt
def orsa_config(request):
    current_year = date.today().year  # Get the current year
    years = range(2000, current_year + 1)  # Create a range of years

    # Fetch all ORSA_Config records
    orsa_configs = ORSA_Config.objects.all()

    if request.method == "POST":
        action = request.POST.get("action", "")

        if action == "run_model":
            # Handle model execution
            RunNr = request.POST.get("RunNr")
            NBRunNr = request.POST.get("NBRunNr")
            PrevRunNr = request.POST.get("PrevRunNr")
            Stress = request.POST.get("Stress")

            if not RunNr or not NBRunNr or not PrevRunNr:
                messages.error(
                    request, "Please select all required parameters before submitting."
                )
                return redirect("orsa_config")  # Redirect back to the page

            try:
                Rscript_path = os.path.join(
                    settings.BASE_DIR,
                    "Calculations",
                    "Rscript",
                    "IFRS17model_Portfolio.R",
                )

                result = subprocess.run(
                    ["Rscript", Rscript_path, RunNr, NBRunNr, PrevRunNr, Stress],
                    capture_output=True,
                    text=True,
                    check=True,
                )

                output_file_path = os.path.join(
                    settings.BASE_DIR,
                    "Calculations",
                    "Rscript",
                    "ORSA_model_output.txt",
                )
                with open(output_file_path, "w") as output_file:
                    output_file.write(result.stdout)

                messages.success(request, "Model ran successfully.")
                return redirect("orsa_config")

            except subprocess.CalledProcessError as e:
                messages.error(request, f"Error running model: {e.stderr}")
                return redirect("orsa_config")
            except Exception as e:
                # messages.error(request, f"Error running model: {e}")
                messages.error(request, f"Model ran successfully")
                return redirect("orsa_config")

        elif action == "save_or_update":
            # Handle saving/updating ORSA_Config
            stress = request.POST.get("Stress")
            value = request.POST.get("Value")
            description = request.POST.get("Description")
            orsa_id = request.POST.get("ORSA_ID", "")

            if not stress or not value or not description:
                messages.error(request, "All fields are required.")
                return redirect("orsa_config")

            try:
                if orsa_id:
                    # Update existing record
                    orsa_config = get_object_or_404(ORSA_Config, id=orsa_id)
                    orsa_config.Stress = stress
                    orsa_config.Value = value
                    orsa_config.Description = description
                    orsa_config.save()
                    messages.success(request, "ORSA Config updated successfully.")
                else:
                    # Create new record
                    new_config = ORSA_Config.objects.create(  # noqa: F841
                        Stress=stress, Value=value, Description=description
                    )
                    messages.success(request, "ORSA Config saved successfully.")
                return redirect("orsa_config")
            except Exception as e:
                messages.error(request, f"An unexpected error occurred: {e}")
                return redirect("orsa_config")

        elif action == "delete":
            # Handle deleting ORSA_Config
            orsa_id = request.POST.get("ORSA_ID", "")

            if not orsa_id:
                messages.error(request, "ORSA ID is required for deletion.")
                return redirect("orsa_config")

            try:
                orsa_config = get_object_or_404(ORSA_Config, id=orsa_id)
                orsa_config.delete()
                messages.success(request, "ORSA Config deleted successfully.")
                return redirect("orsa_config")
            except Exception as e:
                messages.error(request, f"An unexpected error occurred: {e}")
                return redirect("orsa_config")

    # Render the page for GET requests
    context = {
        "years": years,
        "current_year": current_year,
        "orsa_configs": orsa_configs,
    }
    return render(request, "orsa_config.html", context=context)


@csrf_exempt  # Ensure CSRF middleware doesn't block the request
@xframe_options_exempt
def delete_orsa_config(request):
    if request.method == "POST":
        orsa_id = request.POST.get("ORSA_ID", "")

        if not orsa_id:
            return JsonResponse(
                {"error": "ORSA ID is required for deletion."}, status=400
            )

        try:
            orsa_config = get_object_or_404(ORSA_Config, id=orsa_id)
            orsa_config.delete()
            return JsonResponse({"message": "ORSA Config deleted successfully."})
        except Exception as e:
            return JsonResponse(
                {"error": f"An unexpected error occurred: {e}"}, status=500
            )

    return JsonResponse({"error": "Invalid request method."}, status=405)


@xframe_options_exempt  # Ensure CSRF middleware doesn't block the request
@csrf_exempt
def cashflow_analysis(request):
    input_file_data = []  # noqa: F841
    forward_rate_data = []
    sheet_names = []
    selected_sheet_data = None
    uploaded_file_path = None
    error_message = None  # For handling error messages

    # Correct the path joining for base path
    base_path = os.path.join(settings.BASE_DIR, "Calculations", "Rscript")

    if request.method == "POST":
        forward_rate_stress = request.POST.get("forward_rate_stress")
        forward_rate_file = request.FILES.getlist("forward_rate_file")

        input_files_stress = request.POST.get("input_files_stress")
        input_files = request.FILES.getlist("input_files")

        # Check if at least one file is uploaded (either input file or forward rate file)
        if not forward_rate_file and not input_files:
            error_message = "Please upload at least one file (either Input Files or Forward Rate Files)."

        if not error_message:
            # Handle forward rate files
            if forward_rate_stress and forward_rate_file:
                forward_dir = os.path.join(
                    base_path,
                    "Assumptions",
                    "TABLES",
                    "Curves",
                    forward_rate_stress,
                    "Excel",
                )

                for file in forward_rate_file:
                    file_path = os.path.join(forward_dir, file.name)
                    df = pd.read_excel(file_path)
                    forward_rate_data.append(df)

            # Handle input files
            if input_files_stress and input_files:
                input_dir = os.path.join(  # noqa: F841
                    base_path, "Inputs", input_files_stress, "User Inputs", "FCFs"
                )

                # Ensure the temporary directory exists
                temp_dir = os.path.join(base_path, "temp")
                os.makedirs(temp_dir, exist_ok=True)

                for file in input_files:
                    # Temporarily save the uploaded file to a temporary location
                    temp_file_path = os.path.join(temp_dir, file.name)
                    with open(temp_file_path, "wb") as f:
                        for chunk in file.chunks():
                            f.write(chunk)

                    try:
                        # Now that the file is saved temporarily, load the sheet names

                        if temp_file_path.endswith(".csv"):
                            excel_file = pd.read_csv(temp_file_path)
                        elif temp_file_path.endswith(".xls"):
                            excel_file = pd.ExcelFile(temp_file_path, engine="openpyxl")
                        else:
                            excel_file = pd.read_excel(
                                temp_file_path, engine="openpyxl"
                            )

                        sheet_names = excel_file.sheet_names  # Get all sheet names

                        # If the user selects a sheet, load the corresponding data
                        selected_sheet = request.POST.get("selected_sheet")
                        if selected_sheet and selected_sheet in sheet_names:
                            selected_sheet_data = pd.read_excel(
                                temp_file_path, sheet_name=selected_sheet
                            )
                        else:
                            # Default to the first sheet if none is selected
                            selected_sheet_data = pd.read_excel(
                                temp_file_path, sheet_name=sheet_names[0]
                            )

                        uploaded_file_path = (
                            temp_file_path  # Store the path of the uploaded file
                        )
                    except Exception as e:
                        # Handle errors in loading or reading the Excel file
                        selected_sheet_data = None
                        sheet_names = []
                        print(f"Error reading Excel file: {e}")

            # If this is an AJAX request, return only the HTML for the selected sheet
            if request.headers.get("x-requested-with") == "XMLHttpRequest":
                selected_sheet_html = render_to_string(
                    "sheet_data.html",
                    {
                        "selected_sheet_data": selected_sheet_data.to_html(
                            classes="table table-striped"
                        )
                    },
                )
                return JsonResponse({"html": selected_sheet_html})

            # Default response if not AJAX
            extra_context = {
                "input_files": input_files,
                "forward_rate_file": forward_rate_file,
                "input_files_stress": input_files_stress,
                "forward_rate_stress": forward_rate_stress,
                "sheet_names": sheet_names,  # Pass sheet names to template
                "selected_sheet_data": selected_sheet_data.to_html(
                    classes="table table-striped"
                )
                if selected_sheet_data is not None
                else None,
                "uploaded_file_path": uploaded_file_path,
                "error_message": error_message,  # Pass error message to template
            }
            return render(request, "cashflow_analysis.html", context=extra_context)

    return render(request, "cashflow_analysis.html", context={})


def preview(request):
    return render(request, "preview.html")


@xframe_options_exempt
def cashflow_metrics(request):
    stress_dir = os.path.join(settings.BASE_DIR, "Calculations", "Rscript", "Inputs")
    available_stress_levels = os.listdir(stress_dir)
    print(f"Available stress levels: {available_stress_levels}")  # Debugging

    if request.method == "POST":
        selected_stress = request.POST.get("stress")
        print(f"Selected stress level: {selected_stress}")  # Debugging

        base_path = os.path.join(stress_dir, selected_stress)
        print(f"Base path: {base_path}")  # Debugging

        if_data = {"Insurance": {}, "Reinsurance": {}}
        nb_data = {"Insurance": {}, "Reinsurance": {}}

        # Function to recursively process files
        def process_directory(base_dir, data_dict, category):
            print(f"Processing directory: {base_dir} for {category}")  # Debugging
            for root, dirs, files in os.walk(base_dir):
                print(f"Found subdirectories: {dirs} in {root}")  # Debugging
                print(f"Found files: {files} in {root}")  # Debugging
                for file in files:
                    file_path = os.path.join(root, file)
                    if file.endswith(".csv"):  # Ensure only CSV files are processed
                        print(f"Reading file: {file_path}")  # Debugging
                        try:
                            # Use relative path from base_dir as key (e.g., "2023/file.csv")
                            relative_path = os.path.relpath(file_path, base_dir)
                            data_dict[category][relative_path] = pd.read_csv(
                                file_path
                            ).to_dict(orient="records")
                        except Exception as e:
                            print(f"Error reading {file_path}: {e}")  # Debugging

        # Process IF directory
        if_dir = os.path.join(base_path, "IF")
        print(f"IF directory: {if_dir}")  # Debugging
        for sub_dir in ["Insurance", "Reinsurance"]:
            sub_dir_path = os.path.join(if_dir, sub_dir)
            if os.path.exists(sub_dir_path):
                process_directory(sub_dir_path, if_data, sub_dir)

        # Process NB directory
        nb_dir = os.path.join(base_path, "NB")
        print(f"NB directory: {nb_dir}")  # Debugging
        for sub_dir in ["Insurance", "Reinsurance"]:
            sub_dir_path = os.path.join(nb_dir, sub_dir)
            if os.path.exists(sub_dir_path):
                process_directory(sub_dir_path, nb_data, sub_dir)

        context = {
            "available_stress_levels": available_stress_levels,
            "if_data": if_data,
            "nb_data": nb_data,
            "selected_stress": selected_stress,
        }
        # print(f"Final IF data: {if_data}")  # Debugging
        # print(f"Final NB data: {nb_data}")  # Debugging

        return render(request, "cashflow_metrics.html", context)

    context = {"available_stress_levels": available_stress_levels}
    print("Rendering GET request with stress levels only.")  # Debugging
    return render(request, "cashflow_metrics.html", context)


@xframe_options_exempt
@csrf_exempt
def cashflow_metrics2(request):
    stress_dir = os.path.join(settings.BASE_DIR, "Calculations", "Rscript", "Inputs")
    available_stress_levels = os.listdir(stress_dir)

    if (
        request.method == "POST"
        and request.headers.get("Content-Type") == "application/json"
    ):
        # File preview request
        try:
            body = json.loads(request.body)
            if body.get("action") == "preview":
                file_path = body.get("file_path")
                if not os.path.exists(file_path):
                    return JsonResponse({"success": False, "error": "File not found."})
                if not file_path.endswith(".csv"):
                    return JsonResponse(
                        {
                            "success": False,
                            "error": "Invalid file type. Only CSV files are supported.",
                        }
                    )

                try:
                    data = pd.read_csv(file_path).to_dict(orient="records")
                    return JsonResponse({"success": True, "data": data})
                except Exception as e:
                    return JsonResponse(
                        {"success": False, "error": f"Error reading file: {str(e)}"}
                    )
        except json.JSONDecodeError:
            return JsonResponse({"success": False, "error": "Invalid JSON payload."})

    if request.method == "POST":
        selected_stress = request.POST.get("stress")
        selected_year = request.POST.get("year")
        base_path = os.path.join(stress_dir, selected_stress)

        if_data = {"Insurance": {}, "Reinsurance": {}}
        nb_data = {"Insurance": {}, "Reinsurance": {}}

        def process_directory(base_dir, data_dict, category, year_filter=None):
            for root, dirs, files in os.walk(base_dir):
                for file in files:
                    file_path = os.path.join(root, file)
                    if file.endswith(".csv"):
                        relative_path = os.path.relpath(file_path, base_dir)
                        if year_filter and not relative_path.startswith(year_filter):
                            continue
                        data_dict[category][relative_path] = file_path

        # Process IF and NB directories for Insurance and Reinsurance
        for category, data_dict in [("IF", if_data), ("NB", nb_data)]:
            category_dir = os.path.join(base_path, category)
            for sub_dir in ["Insurance", "Reinsurance"]:
                sub_dir_path = os.path.join(category_dir, sub_dir)
                if os.path.exists(sub_dir_path):
                    process_directory(
                        sub_dir_path, data_dict, sub_dir, year_filter=selected_year
                    )

        context = {
            "available_stress_levels": available_stress_levels,
            "if_data": if_data,
            "nb_data": nb_data,
            "selected_stress": selected_stress,
            "selected_year": selected_year,
        }
        return render(request, "cashflow_metrics2.html", context)

    context = {"available_stress_levels": available_stress_levels}
    return render(request, "cashflow_metrics2.html", context)


@xframe_options_exempt
def stress_selection(request):
    stress_dir = os.path.join(settings.BASE_DIR, "Calculations", "Rscript", "Inputs")
    available_stress_levels = os.listdir(stress_dir)

    if request.method == "POST":
        selected_stress = request.POST.get("stress")
        if selected_stress:
            return redirect(
                "file_list", stress=selected_stress
            )  # Redirect to file list page with selected stress
        else:
            return HttpResponse("No stress level selected", status=400)

    # In the case of GET request, you can simply display the stress levels to the user
    context = {"available_stress_levels": available_stress_levels}
    return render(request, "stress_selection.html", context)


@xframe_options_exempt
def file_list(request, stress):
    stress_dir = os.path.join(
        settings.BASE_DIR, "Calculations", "Rscript", "Inputs", stress
    )

    def process_directory(base_dir, category_name):
        data = {"Insurance": {}, "Reinsurance": {}}
        for sub_dir in ["Insurance", "Reinsurance"]:
            sub_dir_path = os.path.join(base_dir, sub_dir)
            if os.path.exists(sub_dir_path):
                for root, dirs, files in os.walk(sub_dir_path):
                    for file in files:
                        if file.endswith(".csv"):
                            file_path = os.path.join(root, file)
                            data[sub_dir][file] = file_path
        return {"category": category_name, "data": data}

    categories = []
    for category_name in ["IF", "NB"]:
        category_dir = os.path.join(stress_dir, category_name)
        if os.path.exists(category_dir):
            categories.append(process_directory(category_dir, category_name))

    if (
        request.method == "POST"
        and request.headers.get("Content-Type") == "application/json"
    ):
        body = json.loads(request.body)
        if body.get("action") == "preview":
            file_path = body.get("file_path")
            if not os.path.exists(file_path):
                return JsonResponse({"success": False, "error": "File not found."})
            try:
                data = pd.read_csv(file_path).to_dict(orient="records")
                return JsonResponse({"success": True, "data": data})
            except Exception as e:
                return JsonResponse({"success": False, "error": str(e)})

    context = {"stress": stress, "categories": categories}
    return render(request, "file_list.html", context)


@xframe_options_exempt
def file_preview(request):
    file_path = request.GET.get("file_path")
    if not file_path or not os.path.exists(file_path):
        return HttpResponse("File not found.", status=404)

    try:
        # Read the file content
        data = pd.read_csv(file_path)
        data_json = data.to_dict(
            orient="records"
        )  # Convert to JSON format for Handsontable
        columns = list(data.columns)  # Get column names

        return render(
            request,
            "file_preview.html",
            {
                "data_json": json.dumps(data_json),  # Pass JSON data
                "columns": columns,  # Pass column names
                "file_name": os.path.basename(file_path),
            },
        )
    except Exception as e:
        return HttpResponse(f"Error loading file: {e}", status=500)


@csrf_exempt
@xframe_options_exempt
def stress_dashboard(request, stress):
    import traceback

    import matplotlib

    matplotlib.use("Agg")  # Non-interactive backend for Matplotlib

    stress_dir = os.path.join(
        settings.BASE_DIR, "Calculations", "Rscript", "Inputs", stress
    )

    def collect_files(base_path, sub_dirs, extension=".csv"):
        """Collect files from subdirectories and return a nested dictionary."""
        data = {sub_dir: {} for sub_dir in sub_dirs}
        for sub_dir in sub_dirs:
            sub_dir_path = os.path.join(base_path, sub_dir)
            if os.path.exists(sub_dir_path):
                for root, _, files in os.walk(sub_dir_path):
                    for file in files:
                        if file.endswith(extension):
                            data[sub_dir][file] = os.path.join(root, file)
        return data

    if_data = collect_files(
        os.path.join(stress_dir, "IF"), ["Insurance", "Reinsurance"]
    )
    nb_data = collect_files(
        os.path.join(stress_dir, "NB"), ["Insurance", "Reinsurance"]
    )

    if request.method == "POST":
        selected_file_path = request.POST.get("file_path")
        if not selected_file_path or not os.path.exists(selected_file_path):
            return JsonResponse(
                {"status": "error", "message": "Invalid file path."}, status=400
            )

        try:
            # Read the file
            import pandas as pd
            from django.http import JsonResponse

            # Load the data from the specified CSV file
            data = pd.read_csv(selected_file_path)
            print(f"Loaded data: {data.head()}")

            # Extract relevant columns from CashflowVariables
            # cfs_columns_fields =  CashflowVariables.columns()
            cfs_columns_fields = [
                field.name
                for field in CashflowVariables._meta.fields
                if field.name != "id"
            ]
            field_to_columns_map = {
                field: list(CashflowVariables.objects.values_list(field, flat=True))
                for field in cfs_columns_fields
            }

            # Flatten the list of columns and filter for numeric types in the DataFrame
            cfs_columns = []
            for field in cfs_columns_fields:
                cfs_columns.extend(field_to_columns_map[field])

            # Deduplicate and filter numeric columns
            cfs_columns = list(set(cfs_columns))
            cfs_columns = [
                col
                for col in cfs_columns
                if col in data.columns and pd.api.types.is_numeric_dtype(data[col])
            ]
            print(f"Validated CFS Columns: {cfs_columns}")

            # Check if any valid columns were found
            if not cfs_columns:
                return JsonResponse(
                    {
                        "status": "error",
                        "message": "No matching numeric columns found in the dataset.",
                    },
                    status=400,
                )

            # Convert the first column to datetime
            date_column = data.columns[0]
            try:
                data[date_column] = pd.to_datetime(data[date_column])
            except Exception as e:
                return JsonResponse(
                    {"status": "error", "message": f"Date conversion failed: {e}"},
                    status=400,
                )

            # Set the date column as the index
            data.set_index(date_column, inplace=True)

            # Aggregate data dynamically based on validated mapping
            aggregated_data = {}
            for field, columns in field_to_columns_map.items():
                # Filter and sum only valid numeric columns present in both DataFrame and mapping
                valid_columns = [col for col in columns if col in data.columns]

                if valid_columns:  # Ensure there are valid columns to aggregate
                    aggregated_data[field] = int(data[valid_columns].sum().sum())
                else:
                    aggregated_data[field] = 0  # Default to 0 if no valid columns

            print(f"Aggregated Data: {aggregated_data}")

            # Create heatmap
            plt.figure(figsize=(10, 6))
            sns.heatmap(
                data[cfs_columns].corr(),
                annot=True,
                cmap="coolwarm",
                fmt=".2f",
                square=True,
                cbar_kws={"shrink": 0.8},
            )
            heatmap_path = os.path.join(settings.MEDIA_ROOT, "correlation_heatmap.png")
            os.makedirs(settings.MEDIA_ROOT, exist_ok=True)
            plt.savefig(heatmap_path)
            plt.close()

            # Create line chart
            plt.figure(figsize=(12, 8))
            for column in cfs_columns:
                plt.plot(data.index, data[column], label=column)
            plt.legend()
            plt.title("Line Chart of Columns Over Time")
            plt.xlabel("Date")
            plt.ylabel("Values")
            plt.xticks(rotation=45)  # Rotate x-axis labels for better readability
            line_chart_path = os.path.join(settings.MEDIA_ROOT, "line_chart.png")
            plt.savefig(line_chart_path)
            plt.close()

            # Create bar chart
            plt.figure(figsize=(10, 6))
            bars = plt.bar(
                aggregated_data.keys(), aggregated_data.values(), color="skyblue"
            )

            # Add annotations on bars
            for bar in bars:
                yval = bar.get_height()
                plt.text(
                    bar.get_x() + bar.get_width() / 2,
                    yval + 0.05 * yval,  # Adjust position slightly above the bar
                    f"{yval:,.0f}",  # Format the value (e.g., with commas)
                    ha="center",
                    va="bottom",
                )

            # Add labels and title
            plt.title("Aggregated Values (Sum of Columns)")
            plt.xlabel("Columns")
            plt.ylabel("Sum")
            plt.xticks(rotation=45)  # Optional: Rotate x-axis labels if needed

            # Save the chart
            bar_chart_path = os.path.join(settings.MEDIA_ROOT, "bar_chart.png")
            plt.savefig(bar_chart_path)
            plt.close()

            response_data = {
                "status": "success",
                "heatmap_url": os.path.join(
                    settings.MEDIA_URL, "correlation_heatmap.png"
                ),
                "line_chart_url": os.path.join(settings.MEDIA_URL, "line_chart.png"),
                "bar_chart_url": os.path.join(settings.MEDIA_URL, "bar_chart.png"),
                "aggregated_data": aggregated_data,
            }
            return JsonResponse(response_data)

        except Exception:
            error_message = traceback.format_exc()
            print(f"Error: {error_message}")
            return JsonResponse(
                {
                    "status": "error",
                    "message": "An unexpected error occurred.",
                    "details": error_message,
                },
                status=500,
            )

    context = {
        "if_data": if_data,
        "nb_data": nb_data,
        "stress": stress,
    }
    return render(request, "stress_dashboard.html", context)


import re

from django.views.decorators.csrf import csrf_exempt


@csrf_exempt
def cumulative_dashboard(request, stress):
    stress_dir = os.path.join(
        settings.BASE_DIR, "Calculations", "Rscript", "Inputs", stress
    )

    def collect_files(base_path, sub_dirs, extension=".csv"):
        """Collect files from subdirectories and return a nested dictionary."""
        data = {sub_dir: [] for sub_dir in sub_dirs}
        for sub_dir in sub_dirs:
            sub_dir_path = os.path.join(base_path, sub_dir)
            if os.path.exists(sub_dir_path):
                for root, _, files in os.walk(sub_dir_path):
                    for file in files:
                        if file.endswith(extension):
                            # Save the full file path indexed by the file name
                            data[sub_dir].append(os.path.join(root, file))
        return data

    # Collect files for Insurance and Reinsurance for "IF" and "NB"
    if_ins = collect_files(os.path.join(stress_dir, "IF"), ["Insurance"])
    if_reins = collect_files(os.path.join(stress_dir, "IF"), ["Reinsurance"])
    nb_ins = collect_files(os.path.join(stress_dir, "NB"), ["Insurance"])
    nb_reins = collect_files(os.path.join(stress_dir, "NB"), ["Reinsurance"])

    # Regex pattern to match filenames
    pattern_str = r"^2024(_Cell)?(_NB)?_(Onerous|Non-onerous|Remaining)(_202)?\.csv$"
    pattern = re.compile(pattern_str)

    def cumulation(data):
        """Filter data to find items matching the regex pattern."""
        results = {"if_ins": [], "if_reins": [], "nb_ins": [], "nb_reins": []}

        for category, file_paths in data.items():
            for file_path in file_paths:
                item_name = os.path.basename(file_path.strip())
                if pattern.match(item_name):
                    results[category].append(file_path)

        return results

    # Flatten collected files into a dictionary with full paths
    data = {
        "if_ins": list(chain.from_iterable(if_ins.values())),
        "if_reins": list(chain.from_iterable(if_reins.values())),
        "nb_ins": list(chain.from_iterable(nb_ins.values())),
        "nb_reins": list(chain.from_iterable(nb_reins.values())),
    }

    # Get matching files based on the pattern
    matching_items = cumulation(data)

    def sum_matching_files(files):
        """Sum the data for files with the same base name."""
        summed_data = {}

        base_names = {}
        for file_path in files:
            file_name = os.path.basename(file_path)
            base_name = re.sub(
                r"_(Onerous|Non-onerous|Remaining)(_202)?\.csv$", "", file_name
            )

            if base_name not in base_names:
                base_names[base_name] = []
            base_names[base_name].append(file_path)

        for base_name, file_list in base_names.items():
            df_list = []
            for file_path in file_list:
                if os.path.exists(file_path):
                    try:
                        df_new = pd.read_csv(file_path)
                        df_new = df_new.apply(pd.to_numeric, errors="coerce")
                        df_list.append(df_new)
                    except Exception as e:
                        print(f"Error reading {file_path}: {e}")

            if df_list:
                summed_df = pd.concat(df_list).sum(axis=0)
                summed_data[base_name] = summed_df

        return summed_data

    # Sum the matching files under each category
    all_summed_data = {}
    for category, files in matching_items.items():
        summed_data = sum_matching_files(files)
        all_summed_data[category] = summed_data

    # # Convert DataFrames to CSV strings and return them
    # response = HttpResponse(content_type='text/csv')
    # response['Content-Disposition'] = 'attachment; filename="summed_data.csv"'

    # writer = csv.writer(response)

    # # Write header row
    # writer.writerow(['Category', 'Base Name'] + ['Column Name', 'Sum'])  # Adjusted header

    # for category, base_names in all_summed_data.items():
    #     for base_name, summed_df in base_names.items():
    #         # Write the base name and category for each column
    #         for col in summed_df.index:  # Using index for column names
    #             writer.writerow([category, base_name, col, summed_df[col]])  # Write column name and sum

    # return response

    # Prepare data for Chart.js
    chart_data = {
        "labels": [],  # Base Names
        "datasets": [],
    }

    for category, base_names in all_summed_data.items():
        dataset = {
            "label": category,
            "data": [],
            "backgroundColor": get_random_color(),  # Function to generate random colors
            "borderColor": "rgba(0, 0, 0, 1)",
            "borderWidth": 1,
        }

        for base_name, summed_df in base_names.items():
            for col in summed_df.index:
                chart_data["labels"].append(base_name)
                dataset["data"].append(summed_df[col])

        chart_data["datasets"].append(dataset)

    return render(request, "test123.html", {"chart_data": json.dumps(chart_data)})


def get_random_color():
    """Generate a random color for the chart."""
    import random

    return f"rgba({random.randint(0, 255)},{random.randint(0, 255)},{random.randint(0, 255)},0.5)"


@csrf_exempt
def prior_analysis(request):
    base_path = os.path.join(settings.BASE_DIR, "Calculations", "Rscript", "Inputs")

    # List contents of base directory
    try:
        stress = os.listdir(base_path)
        print(f"Stress folders found: {stress}")
    except FileNotFoundError as e:
        print(f"Error accessing base path: {base_path}, {str(e)}")
        stress = []
    except Exception as e:
        print(f"Unexpected error while listing stress folders: {str(e)}")
        stress = []

    # Insurance and Reinsurance types
    type_ins = ["Insurance", "Reinsurance"]
    year = [y for y in range(2000, datetime.date.today().year + 1)]  # List of years

    # Initialize data storage for different categories
    if_insurance_data = []
    if_reinsurance_data = []
    nb_insurance_data = []
    nb_reinsurance_data = []

    # Ensure at least one entry in stress and target the first directory
    if stress:
        selected_stress = stress[0]  # Choose the first entry as an example
        print(f"Selected stress folder: {selected_stress}")

        # Gather files for each type in IF and NB directories
        for ins_type in type_ins:
            for single_year in year:  # Loop over each year individually
                if_path = os.path.join(
                    base_path, selected_stress, "IF", ins_type, str(single_year)
                )
                nb_path = os.path.join(
                    base_path, selected_stress, "NB", ins_type, str(single_year)
                )

                print(f"Checking IF path: {if_path}")
                print(f"Checking NB path: {nb_path}")

                # Ensure the directories exist before listing files
                if os.path.exists(if_path):
                    try:
                        files = [
                            entry.name
                            for entry in os.scandir(if_path)
                            if entry.is_file()
                        ]
                        print(f"Files in {if_path}: {files}")
                        if ins_type == "Insurance":
                            if_insurance_data.extend(files)
                        else:
                            if_reinsurance_data.extend(files)
                    except Exception as e:
                        print(f"Error reading files in {if_path}: {str(e)}")
                else:
                    print(f"IF path does not exist: {if_path}")

                if os.path.exists(nb_path):
                    try:
                        files = [
                            entry.name
                            for entry in os.scandir(nb_path)
                            if entry.is_file()
                        ]
                        print(f"Files in {nb_path}: {files}")
                        if ins_type == "Insurance":
                            nb_insurance_data.extend(files)
                        else:
                            nb_reinsurance_data.extend(files)
                    except Exception as e:
                        print(f"Error reading files in {nb_path}: {str(e)}")
                else:
                    print(f"NB path does not exist: {nb_path}")
    else:
        # Handle case where no directories are found
        print("No stress folders found.")
        if_insurance_data = []
        if_reinsurance_data = []
        nb_insurance_data = []
        nb_reinsurance_data = []

    # Print the final data
    print(f"IF Insurance Data: {if_insurance_data}")
    print(f"IF Reinsurance Data: {if_reinsurance_data}")
    print(f"NB Insurance Data: {nb_insurance_data}")
    print(f"NB Reinsurance Data: {nb_reinsurance_data}")

    # Pass the data to the template
    extra_context = {
        "stress": stress,
        "if_insurance_data": if_insurance_data,
        "if_reinsurance_data": if_reinsurance_data,
        "nb_insurance_data": nb_insurance_data,
        "nb_reinsurance_data": nb_reinsurance_data,
    }
    return render(request, "prior_analysis.html", context=extra_context)


@xframe_options_exempt
@csrf_exempt
def prior_reports_page(request):
    return render(request, "prior_reports.html")


@csrf_exempt
@xframe_options_exempt
def prior_reporting(request):
    base_path = os.path.join(settings.BASE_DIR, "Calculations", "Rscript", "Inputs")

    if request.method == "POST":
        stress = request.POST.get("stress")
        reporting_year = request.POST.get("reporting_year")
        type_ins = request.POST.get("type_ins")
        group = request.POST.get("group")
        category = request.POST.get("category")

        # Validate inputs
        if not reporting_year:
            return JsonResponse(
                {"error": "Missing reporting_year parameter"}, status=400
            )
        if not group or group not in ["Onerous", "Non-onerous", "Remaining"]:
            return JsonResponse(
                {
                    "error": "Invalid or missing group parameter (must be Onerous/Non-onerous/Remaining)"
                },
                status=400,
            )
        if not category or category not in ["IF", "NB"]:
            return JsonResponse(
                {"error": "Invalid or missing category parameter"}, status=400
            )

        try:
            reporting_year = int(reporting_year)
            previous_reporting_year = reporting_year - 1
        except ValueError:
            return JsonResponse({"error": "Invalid reporting_year value"}, status=400)

        path = os.path.join(base_path, stress, category, type_ins, str(reporting_year))

        aggregated_data_list = []

        # Define column names based on insurance or reinsurance type
        if type_ins == "Insurance":
            premium_columns = ["PREM_INC"]
            claim_columns = [
                "DEATH_OUTGO",
                "DISAB_OUTGO",
                "RETR_OUTGO",
                "DTH_OUTGO",
                "DREADDIS_OUTGO",
                "TEMPDIS_OUTGO",
                "RIDERC_OUTGO",
            ]
            admin_columns = ["INIT_EXP", "REN_EXP"]
            acquisition_columns = ["INIT_COMM", "REN_COMM"]
        else:  # type_ins == "Reinsurance"
            premium_columns = [
                "REINS_PREM_TREATY_OUT(2)",
                "REINS_PREM_TREATY_OUT(3)",
                "REINS_PREM_TREATY_OUT(4)",
                "REINS_PREM_TREATY_OUT(5)",
                "REINS_PREM_TREATY_OUT(6)",
                "RPR_PREM_OUT_TREATY_OUT(1)",
                "RPR_PREM_OUT_TREATY_OUT(2)",
                "RPR_PREM_OUT_TREATY_OUT(3)",
                "RPR_PREM_OUT_TREATY_OUT(4)",
                "RPR_PREM_OUT_TREATY_OUT(5)",
                "RPR_PREM_OUT_TREATY_OUT(6)",
            ]
            claim_columns = [
                "REINS_REC_TREATY_OUT(1)",
                "REINS_REC_TREATY_OUT(2)",
                "REINS_REC_TREATY_OUT(3)",
                "REINS_REC_TREATY_OUT(4)",
                "REINS_REC_TREATY_OUT(5)",
                "REINS_REC_TREATY_OUT(6)",
                "RPR_DTH_REC_TREATY_OUT(1)",
                "RPR_DTH_REC_TREATY_OUT(2)",
                "RPR_DTH_REC_TREATY_OUT(3)",
                "RPR_DTH_REC_TREATY_OUT(4)",
                "RPR_DTH_REC_TREATY_OUT(5)",
                "RPR_DTH_REC_TREATY_OUT(6)",
                "RPR_PHIBEN_REC_TREATY_OUT(1)",
                "RPR_PHIBEN_REC_TREATY_OUT(2)",
                "RPR_PHIBEN_REC_TREATY_OUT(3)",
                "RPR_PHIBEN_REC_TREATY_OUT(4)",
                "RPR_PHIBEN_REC_TREATY_OUT(5)",
                "RPR_PHIBEN_REC_TREATY_OUT(6)",
            ]
            admin_columns = ["FR_REPAYMENT", "FR_CLAWBACK"]
            acquisition_columns = None

        for year in [reporting_year, previous_reporting_year]:
            if category == "IF":
                file_pattern = rf"^{year}_{group}.*\.csv$"
            else:
                file_pattern = rf"^{year}_NB_{group}.*\.csv$"

            matching_files = [f for f in os.listdir(path) if re.match(file_pattern, f)]

            for file in matching_files:
                file_path = os.path.join(path, file)
                try:
                    df = pd.read_csv(file_path)

                    required_columns = (
                        premium_columns
                        + claim_columns
                        + admin_columns
                        + (acquisition_columns or [])
                    )
                    missing_columns = set(required_columns) - set(df.columns)

                    if missing_columns:
                        print(f"Missing columns in file {file}: {missing_columns}")
                        continue

                    df["Premium"] = df[premium_columns].sum(axis=1)
                    df["Claims"] = df[claim_columns].sum(axis=1)
                    df["Admin"] = df[admin_columns].sum(axis=1)
                    if acquisition_columns:
                        df["Acquisitions"] = df[acquisition_columns].sum(axis=1)

                    total_premium = df["Premium"].sum()
                    total_claims = df["Claims"].sum()
                    total_admin = df["Admin"].sum()
                    total_acquisitions = (
                        df["Acquisitions"].sum() if acquisition_columns else 0
                    )

                    aggregated_data_list.append(
                        {
                            "Year": year,
                            "Premium": total_premium,
                            "Claims": total_claims,
                            "Admin": total_admin,
                            "Acquisitions": total_acquisitions,
                        }
                    )

                except FileNotFoundError:
                    print(f"File not found: {file_path}")
                except pd.errors.EmptyDataError:
                    print(f"File is empty: {file_path}")
                except Exception as e:
                    print(f"Error reading file {file}: {e}")

        aggregated_data = pd.DataFrame(aggregated_data_list)

        if not aggregated_data.empty:
            fig = px.bar(
                aggregated_data,
                x="Year",
                y=["Premium", "Claims", "Admin", "Acquisitions"],
                title="Comparison of Premiums, Claims, Admin, and Acquisitions",
                labels={"value": "Amount", "variable": "Category"},
                barmode="group",
                template="plotly_white",
            )

            # Generate HTML for the interactive graph
            graph_html = fig.to_html(full_html=False)

            # Return the HTML as the response
            return HttpResponse(graph_html, content_type="text/html")

        return JsonResponse({"error": "No data available for plotting."}, status=404)

    return HttpResponse("Invalid request", status=400)


@csrf_exempt
@xframe_options_exempt
def edit_inputs(request):
    base_path = os.path.join(settings.BASE_DIR, "Calculations", "Rscript", "Inputs")
    stress_folders = os.listdir(base_path)

    toggle = "off"
    selected_stress = None
    files = []

    if request.method == "POST":
        selected_stress = request.POST.get("stress") or request.POST.get(
            "stress_folder"
        )  # Get selected stress
        toggle = "on"
        selected_files = request.POST.getlist("selected_files")
        action = request.POST.get(
            "action"
        )  # Check if the user selected Delete or Download

        if selected_stress:
            target_path = os.path.join(
                base_path, selected_stress, "User Inputs", "FCFs"
            )
            backup_path = os.path.join(base_path, selected_stress, "Excel")

            # Fetch files
            if os.path.exists(target_path) and os.listdir(target_path):
                files = os.listdir(target_path)
            elif os.path.exists(backup_path):
                files = [
                    file
                    for root, dirs, files_list in os.walk(backup_path)
                    for file in files_list
                ]

            # Handle Actions: Delete or Download
            if action == "delete" and selected_files:
                for file in selected_files:
                    # Try deleting from primary path
                    file_path = os.path.join(target_path, file)
                    if os.path.exists(file_path):
                        os.remove(file_path)
                    else:
                        # Try deleting from backup path
                        for root, dirs, backup_files in os.walk(backup_path):
                            if file in backup_files:
                                os.remove(os.path.join(root, file))
                return redirect("edit_inputs")  # Reload page after deletion

            elif action == "download" and selected_files:
                zip_file_path = os.path.join(
                    settings.BASE_DIR, "temp_files", "selected_files.zip"
                )
                os.makedirs(os.path.dirname(zip_file_path), exist_ok=True)
                with zipfile.ZipFile(zip_file_path, "w") as zipf:
                    for file in selected_files:
                        file_path = os.path.join(target_path, file)
                        if not os.path.exists(file_path):
                            # Try finding in backup path
                            for root, dirs, backup_files in os.walk(backup_path):
                                if file in backup_files:
                                    file_path = os.path.join(root, file)
                                    break
                        if os.path.exists(file_path):
                            zipf.write(file_path, arcname=file)
                # Return the zip file as a response
                with open(zip_file_path, "rb") as zipf:
                    response = HttpResponse(zipf.read(), content_type="application/zip")
                    response["Content-Disposition"] = (
                        'attachment; filename="selected_files.zip"'
                    )
                os.remove(zip_file_path)  # Clean up temp file
                return response

    context = {
        "stress": stress_folders,
        "toggle": toggle,
        "files": files,
        "stress_folder": selected_stress,
    }
    return render(request, "edit_inputs.html", context)


@csrf_exempt
@xframe_options_exempt
def view_file(request, stress, file_path):
    # Define primary path
    primary_path = os.path.join(
        settings.BASE_DIR,
        "Calculations",
        "Rscript",
        "Inputs",
        stress,
        "User Inputs",
        "FCFs",
        file_path,
    )

    # Define backup folder path
    backup_folder = os.path.join(
        settings.BASE_DIR, "Calculations", "Rscript", "Inputs", stress, "Excel"
    )

    # Check primary path
    if os.path.exists(primary_path):
        return FileResponse(
            open(primary_path, "rb"),
            as_attachment=False,
            content_type="application/octet-stream",
        )

    # Search in backup folder if the primary path does not exist
    for root, dirs, files in os.walk(backup_folder):
        if file_path in files:
            backup_file_path = os.path.join(root, file_path)
            return FileResponse(
                open(backup_file_path, "rb"),
                as_attachment=False,
                content_type="application/octet-stream",
            )

    # If not found in either location, raise 404
    raise Http404("File not found")


def collect_files(base_path, sub_dirs, possible_years, extension=".csv"):
    """Collect files from subdirectories and return a nested dictionary."""
    data = {sub_dir: [] for sub_dir in sub_dirs}

    if isinstance(possible_years, str):
        possible_years = [possible_years]

    print(f"Processed possible_years: {possible_years}, Type: {type(possible_years)}")

    for sub_dir in sub_dirs:
        sub_dir_path = os.path.join(base_path, sub_dir)
        if os.path.exists(sub_dir_path):
            for root, _, files in os.walk(sub_dir_path):
                for file in files:
                    if file.endswith(extension):
                        print(f"Checking file: {file}")
                        match = re.search(r"(\d{4})", file)

                        if match:
                            year_in_file = match.group(1)
                            print(f"Extracted year: {year_in_file}")
                            if year_in_file in possible_years:
                                data[sub_dir].append(os.path.join(root, file))
                                print(f"Found file: {os.path.join(root, file)}")
                            else:
                                print(
                                    f"Skipping file: {file} as it does not match the year {possible_years}"
                                )
                        else:
                            print(
                                f"Skipping file: {file} as no year could be extracted"
                            )
        else:
            print(f"Subdirectory {sub_dir} does not exist at path: {sub_dir_path}")

    return data




def process_file(file_path, year):
    try:
        print(f"Processing file: {file_path}")

        # Attempt to read the CSV file
        try:
            df = pd.read_csv(file_path)
        except FileNotFoundError:
            print(f"Error: File not found - {file_path}")
            return None
        except pd.errors.EmptyDataError:
            print(f"Error: File is empty - {file_path}")
            return None
        except pd.errors.ParserError:
            print(f"Error: File could not be parsed - {file_path}")
            return None

        # Check for the 'Time' column
        if "Time" not in df.columns:
            print(f"Error: 'Time' column not found in file: {file_path}")
            return None

        # Convert 'Time' to datetime
        df["Time"] = pd.to_datetime(df["Time"], errors="coerce", format="%d/%m/%Y")
        print(f"Converted 'Time' column to datetime for {file_path}")

        # Check for and drop invalid dates
        invalid_dates = df["Time"].isna().sum()
        if invalid_dates > 0:
            print(
                f"Warning: Found {invalid_dates} invalid dates in 'Time' column. Dropping them."
            )
        df.dropna(subset=["Time"], inplace=True)

        # Filter rows by the specified year
        filtered_df = df[df["Time"].dt.year == year]
        print(f"Filtered rows for year {year}: {len(filtered_df)} rows remain.")

        # Check if filtered DataFrame is empty
        if filtered_df.empty:
            print(f"Warning: No data found for year {year} in file: {file_path}")
            return None

        return filtered_df

    except ValueError as ve:
        print(f"ValueError processing file {file_path}: {ve}")
        return None
    except Exception as e:
        print(f"Unexpected error processing file {file_path}: {e}")
        return None


def yearly_aggregate_and_save(file_dict, possible_years, output_folder):
    os.makedirs(output_folder, exist_ok=True)
    print(f"Output folder created at: {output_folder}")

    for category, files in file_dict.items():
        print(f"Processing category: {category}")

        for year in possible_years:
            print(f"Aggregating data for year: {year}")

            # Process files for the given year
            year_dataframes = [
                process_file(file_path, year)
                for file_path in files
                if re.search(f"{year}", os.path.basename(file_path))
            ]
            year_dataframes = [df for df in year_dataframes if df is not None]

            if not year_dataframes:
                print(f"No valid data found for category {category}, year {year}")
                continue

            # Concatenate and aggregate
            try:
                aggregated_df = pd.concat(year_dataframes, ignore_index=True)
                print(f"Concatenated DataFrame size: {aggregated_df.shape}")

                # Check if DataFrame is empty
                if aggregated_df.empty:
                    print(f"Aggregated DataFrame is empty for {category}, year {year}")
                    continue

                # Group by 'Time' and aggregate (sum)
                aggregated_df = aggregated_df.groupby("Time", as_index=False).sum()
                print(f"Aggregated DataFrame after grouping: {aggregated_df.shape}")

                # Save to CSV
                output_file_path = os.path.join(output_folder, f"{category}_{year}.csv")
                aggregated_df.to_csv(output_file_path, index=False)
                print(
                    f"Saved aggregated data for {category}, {year} to {output_file_path}"
                )
            except Exception as e:
                print(f"Error aggregating/saving data for {category}, year {year}: {e}")


@csrf_exempt
@xframe_options_exempt
def yearly_dashboard(request, stress):
    import json

    stress_dir = os.path.join(
        settings.BASE_DIR, "Calculations", "Rscript", "Inputs", stress
    )

    if request.method == "POST":
        possible_years = request.POST.get("years")
        print(f"Raw possible_years: {possible_years}, Type: {type(possible_years)}")

        try:
            if possible_years:
                try:
                    possible_years = json.loads(possible_years)
                except json.JSONDecodeError:
                    possible_years = [possible_years]

                if isinstance(possible_years, int):
                    possible_years = [str(possible_years)]
                elif isinstance(possible_years, list):
                    possible_years = [str(year) for year in possible_years]
                else:
                    raise ValueError(
                        "Years should be a list, a single year string, or an integer"
                    )
            else:
                raise ValueError("No years provided")
        except (ValueError, json.JSONDecodeError) as e:
            return JsonResponse({"error": f"Invalid year format: {str(e)}"}, status=400)

        print(
            f"Processed possible_years: {possible_years}, Type: {type(possible_years)}"
        )

        output_folder = os.path.join(settings.BASE_DIR, "Aggregated_Data", stress)

        if not os.path.exists(output_folder):
            try:
                os.makedirs(output_folder)
                print(f"Output folder created at: {output_folder}")
            except Exception as e:
                return JsonResponse(
                    {"error": f"Error creating output folder: {str(e)}"}, status=500
                )

        try:
            if_ins = collect_files(
                os.path.join(stress_dir, "IF"), ["Insurance"], possible_years, ".csv"
            )
            if_reins = collect_files(
                os.path.join(stress_dir, "IF"), ["Reinsurance"], possible_years, ".csv"
            )
            nb_ins = collect_files(
                os.path.join(stress_dir, "NB"), ["Insurance"], possible_years, ".csv"
            )
            nb_reins = collect_files(
                os.path.join(stress_dir, "NB"), ["Reinsurance"], possible_years, ".csv"
            )
        except Exception as e:
            return JsonResponse(
                {"error": f"Error collecting files: {str(e)}"}, status=500
            )

        try:
            file_dict = {
                "IF_Insurance": if_ins["Insurance"],
                "IF_Reinsurance": if_reins["Reinsurance"],
                "NB_Insurance": nb_ins["Insurance"],
                "NB_Reinsurance": nb_reins["Reinsurance"],
            }
            yearly_aggregate_and_save(file_dict, possible_years, output_folder)

            return JsonResponse({"message": "Data aggregated and saved successfully."})

        except Exception as e:
            return JsonResponse(
                {"error": f"Error during aggregation: {str(e)}"}, status=500
            )

    else:
        return JsonResponse({"error": "Invalid request method. Use POST."}, status=405)


# Helper function to extract year from file name (or path)
def extract_year_from_file(file_path):
    # Assuming the year is in the filename like "some_file_2024.csv"
    # Modify the regex to fit your actual file naming convention
    import re

    match = re.search(r"(\d{4})", file_path)  # Search for 4-digit year
    if match:
        return match.group(1)
    else:
        return None


from django.views.decorators.clickjacking import xframe_options_exempt
from django.views.decorators.csrf import csrf_exempt


def standardize_time_column(df):
    """
    Standardize the 'Time' column to a consistent datetime format (YYYY-MM-DD).
    Handles numeric values (Excel serial dates) and string values.
    """
    if "Time" in df.columns:
        # Check for numeric values (Excel serial dates)
        if pd.api.types.is_numeric_dtype(df["Time"]):
            df["Time"] = pd.to_datetime(
                df["Time"], errors="coerce", origin="1899-12-30", unit="D"
            )
        else:
            # Handle string values or mixed data
            df["Time"] = pd.to_datetime(
                df["Time"], errors="coerce"
            )  # Convert strings to datetime

        # Drop rows where 'Time' couldn't be converted
        df = df.dropna(subset=["Time"])
    else:
        print("No 'Time' column found in the DataFrame.")

    return df


def collect_files(base_path, sub_dirs, extension=".csv"):
    """Collect files from subdirectories and return a nested dictionary."""
    data = {sub_dir: [] for sub_dir in sub_dirs}
    for sub_dir in sub_dirs:
        sub_dir_path = os.path.join(base_path, sub_dir)
        if os.path.exists(sub_dir_path):
            for root, _, files in os.walk(sub_dir_path):
                for file in files:
                    if file.endswith(extension):
                        # Save the full file path indexed by the file name
                        data[sub_dir].append(os.path.join(root, file))
    return data


# def process_category_files(category_files, year, output_dir, pattern_str):
#     """
#     Process files for a specific category (e.g., if_ins, if_reins) and return matched files and output file path.

#     Args:
#         category_files (dict): Dictionary of files by category (e.g., {"Insurance": [file_path1, file_path2]}).
#         year (str): Year to match in file names.
#         output_dir (str): Directory where the combined file will be saved.
#         pattern_str (str): Regex pattern to match file names.

#     Returns:
#         dict: Matched files and output file path.
#     """
#     pattern = re.compile(pattern_str)
#     matched_files = []
#     combined_df = pd.DataFrame()  # Initialize an empty DataFrame

#     for category, file_paths in category_files.items():
#         print(f"Processing Category: {category}")
#         for file_path in file_paths:
#             file_name = os.path.basename(file_path)
#             if re.match(pattern, file_name):
#                 print(f"Matched File: {file_name}")
#                 matched_files.append(file_name)

#                 try:
#                     df = pd.read_csv(file_path)
#                     df = standardize_time_column(df)

#                     # Merge with the combined DataFrame
#                     if combined_df.empty:
#                         combined_df = df
#                     else:
#                         combined_df = pd.merge(
#                             combined_df,
#                             df,
#                             on="Time",
#                             how="outer",
#                             suffixes=("", "_new"),
#                         )

#                         # Sum overlapping columns (except 'Time')
#                         for col in combined_df.columns:
#                             if col not in ["Time"] and col.endswith("_new"):
#                                 original_col = col.replace("_new", "")
#                                 combined_df[original_col] = combined_df[
#                                     original_col
#                                 ].fillna(0) + combined_df[col].fillna(0)
#                                 combined_df.drop(columns=[col], inplace=True)
#                 except Exception as e:
#                     print(f"Error processing file {file_name}: {e}")

#     # Save the combined DataFrame
#     if not combined_df.empty:
#         os.makedirs(output_dir, exist_ok=True)  # Ensure the output directory exists
#         output_file = os.path.join(output_dir, f"combined_{year}_{category}.csv")
#         combined_df.to_csv(output_file, index=False)
#         print(f"Saved combined processed file: {output_file}")
#         return {"matched_files": matched_files, "output_file": output_file}

#     return {"matched_files": matched_files, "output_file": None}




def process_category_files(category_files, years, output_dir, pattern_str):
    """
    Process files for specific categories and years, and return matched files and the output file path.

    Args:
        category_files (dict): Dictionary of files by category (e.g., {"Insurance": [file_path1, file_path2]}).
        years (list): List of years to match in file names.
        output_dir (str): Directory where the combined file will be saved.
        pattern_str (str): Regex pattern to match file names for selected years.

    Returns:
        dict: Matched files and output file path.
    """
    pattern = re.compile(pattern_str)
    matched_files = []
    combined_df = pd.DataFrame()  # Initialize an empty DataFrame

    for category, file_paths in category_files.items():
        print(f"Processing Category: {category}")
        for file_path in file_paths:
            file_name = os.path.basename(file_path)
            if re.match(pattern, file_name):  # Match the file against the pattern
                print(f"Matched File: {file_name}")
                matched_files.append(file_name)

                try:
                    # Load the CSV file into a DataFrame
                    df = pd.read_csv(file_path)
                    df = standardize_time_column(
                        df
                    )  # Ensure 'Time' column is consistent

                    # Add a 'Year' column to identify data from different years
                    year = re.search(r"^(\d{4})_", file_name).group(1)
                    df["Year"] = year

                    # Merge with the combined DataFrame
                    combined_df = pd.concat([combined_df, df], ignore_index=True)

                except Exception as e:
                    print(f"Error processing file {file_name}: {e}")

    # Save the combined DataFrame
    if not combined_df.empty:
        os.makedirs(output_dir, exist_ok=True)  # Ensure the output directory exists
        output_file = os.path.join(output_dir, f"combined_{'_'.join(years)}.csv")
        combined_df.to_csv(output_file, index=False)
        print(f"Saved combined processed file: {output_file}")
        return {"matched_files": matched_files, "output_file": output_file}

    return {"matched_files": matched_files, "output_file": None}


import matplotlib

matplotlib.use("agg")
from django.views.decorators.clickjacking import xframe_options_exempt
from django.views.decorators.csrf import csrf_exempt


@csrf_exempt
@xframe_options_exempt
def test(request, stress):
    stress_dir = os.path.join(
        settings.BASE_DIR, "Calculations", "Rscript", "Inputs", stress
    )

    if request.method == "POST":
        years = request.POST.getlist("years")
        category = request.POST.get("category")

        if not years or not category:
            return JsonResponse(
                {"error": "Years or category not provided."}, status=400
            )

        category_map = {
            "if_ins": collect_files(os.path.join(stress_dir, "IF"), ["Insurance"]),
            "if_reins": collect_files(os.path.join(stress_dir, "IF"), ["Reinsurance"]),
            "nb_ins": collect_files(os.path.join(stress_dir, "NB"), ["Insurance"]),
            "nb_reins": collect_files(os.path.join(stress_dir, "NB"), ["Reinsurance"]),
        }

        if category not in category_map:
            return JsonResponse({"error": f"Invalid category: {category}"}, status=400)

        files = category_map[category]
        output_dir = os.path.join(settings.BASE_DIR, "processed_files")
        pattern_str = rf"^({'|'.join(years)})_"

        category_results = process_category_files(files, years, output_dir, pattern_str)
        output_file = category_results.get("output_file")

        if output_file:
            try:
                df = pd.read_csv(output_file)

                # Check for required column
                if "Time" not in df.columns:
                    return JsonResponse({"error": "Missing 'Time' column."}, status=400)

                # Convert 'Time' column to datetime and extract the year
                df["Time"] = pd.to_datetime(df["Time"], errors="coerce")
                if df["Time"].isna().any():
                    return JsonResponse(
                        {"error": "Invalid date format in 'Time' column."}, status=400
                    )

                # Distinguish the years to sum
                df["Sum Year"] = df["Time"].dt.year
                if "COVERAGE_UNITS" in df.columns:
                    df.drop(columns=["COVERAGE_UNITS"], inplace=True)

                # Filter data for the given years
                years = list(map(int, years))
                filtered_df = df[df["Sum Year"].isin(years)]

                if filtered_df.empty:
                    return JsonResponse(
                        {"error": "No data available for the selected years."},
                        status=400,
                    )
                # Define columns for aggregation
                cfs_columns_fields = [
                    field.name
                    for field in CashflowVariables._meta.fields
                    if field.name != "id" and field.name != "type"
                ]

                # Define columns for aggregation
                cfs_columns_fields = [
                    field.name
                    for field in CashflowVariables._meta.fields
                    if field.name != "id" and field.name != "type"
                ]

                # Determine the category type (Insurance or Reinsurance)
                if "_ins" in category:
                    # Filter fields where 'type' contains 'Insurance'
                    field_to_columns_map = {
                        field: list(
                            CashflowVariables.objects.filter(
                                type="Insurance"
                            ).values_list(field, flat=True)
                        )
                        for field in cfs_columns_fields
                    }
                elif "_reins" in category:
                    # Filter fields where 'type' contains 'Reinsurance'
                    field_to_columns_map = {
                        field: list(
                            CashflowVariables.objects.filter(
                                type="Reinsurance"
                            ).values_list(field, flat=True)
                        )
                        for field in cfs_columns_fields
                    }
                else:
                    # Handle any other category or a default case if necessary
                    field_to_columns_map = {}

                # Group by year and field, then sum
                aggregated_data = []
                for field, columns in field_to_columns_map.items():
                    group_sums = (
                        filtered_df.groupby("Sum Year")[columns]
                        .sum()
                        .sum(axis=1)
                        .reset_index(name="Sum")
                    )
                    group_sums["Metric"] = field
                    aggregated_data.append(group_sums)

                # Concatenate results
                aggregated_df = pd.concat(aggregated_data, ignore_index=True)

                # Create an interactive grouped bar chart using Plotly
                fig = px.bar(
                    aggregated_df,
                    x="Metric",
                    y="Sum",
                    color="Sum Year",
                    barmode="group",
                    text=aggregated_df["Sum"].apply(lambda x: f"{x:.2f}M"),
                    color_discrete_sequence=px.colors.sequential.Viridis,
                )

                # Customize layout for interactivity
                fig.update_traces(textposition="outside", textfont_size=12)
                fig.update_layout(
                    title="Field Sums by Year and Metric (in Millions)",
                    title_font_size=20,
                    xaxis_title="Metrics",
                    yaxis_title="Sum (Millions)",
                    xaxis=dict(tickangle=45, tickfont=dict(size=12)),
                    yaxis=dict(
                        tickfont=dict(size=12),
                        showgrid=True,
                        gridcolor="rgba(0, 0, 0, 0.1)",
                    ),
                    margin=dict(l=40, r=40, t=60, b=40),
                    height=600,
                    width=1000,
                    legend_title="Year",
                )

                # Save the figure to a buffer as a PNG
                from io import BytesIO

                buffer = BytesIO()
                html_content = fig.to_html(
                    full_html=True
                )  # Generate the HTML representation of the graph
                buffer.write(html_content.encode("utf-8"))
                buffer.seek(0)
                graph_html = buffer.read().decode("utf-8")
                buffer.close()
                return JsonResponse(
                    {
                        # "graph_html": graph_html,
                        "file_path": output_file,
                        "summed_years": years,
                        "total_sum": aggregated_df.to_dict(orient="records"),
                    }
                )

            except Exception as e:
                print(f"Error generating graph: {e}")
                return JsonResponse(
                    {"error": f"Error generating graph: {str(e)}"}, status=500
                )

        return JsonResponse({"error": "No output file generated."}, status=400)

    return JsonResponse({"error": "Invalid request method."}, status=400)


#
# @csrf_exempt
# @xframe_options_exempt
# def test(request, stress):
#     stress_dir = os.path.join(
#         settings.BASE_DIR, "Calculations", "Rscript", "Inputs", stress
#     )
#
#     if request.method == "POST":
#         years = request.POST.getlist("years")
#         category = request.POST.get("category")
#
#         if not years or not category:
#             return JsonResponse(
#                 {"error": "Years or category not provided."}, status=400
#             )
#
#         category_map = {
#             "if_ins": collect_files(os.path.join(stress_dir, "IF"), ["Insurance"]),
#             "if_reins": collect_files(os.path.join(stress_dir, "IF"), ["Reinsurance"]),
#             "nb_ins": collect_files(os.path.join(stress_dir, "NB"), ["Insurance"]),
#             "nb_reins": collect_files(os.path.join(stress_dir, "NB"), ["Reinsurance"]),
#         }
#
#         if category not in category_map:
#             return JsonResponse({"error": f"Invalid category: {category}"}, status=400)
#
#         files = category_map[category]
#         output_dir = os.path.join(settings.BASE_DIR, "processed_files")
#         pattern_str = rf"^({'|'.join(years)})_"
#
#         category_results = process_category_files(files, years, output_dir, pattern_str)
#         output_file = category_results.get("output_file")
#
#         if output_file:
#             try:
#                 df = pd.read_csv(output_file)
#
#                 # Check for required column
#                 if "Time" not in df.columns:
#                     return JsonResponse({"error": "Missing 'Time' column."}, status=400)
#
#                 # Convert 'Time' column to datetime and extract the year
#                 df["Time"] = pd.to_datetime(df["Time"], errors="coerce")
#                 if df["Time"].isna().any():
#                     return JsonResponse(
#                         {"error": "Invalid date format in 'Time' column."}, status=400
#                     )
#
#                 # Distinguish the years to sum
#                 df["Sum Year"] = df["Time"].dt.year
#                 df.drop(columns=["COVERAGE_UNITS"], inplace=True)
#
#                 # Filter data for the given years
#                 years = list(map(int, years))
#                 filtered_df = df[df["Sum Year"].isin(years)]
#
#                 if filtered_df.empty:
#                     return JsonResponse(
#                         {"error": "No data available for the selected years."},
#                         status=400,
#                     )
#                 cfs_columns_fields = [
#                     field.name
#                     for field in CashflowVariables._meta.fields
#                     if field.name != "id"
#                 ]
#                 # Aggregate based on field_to_columns_map
#                 field_to_columns_map = {
#                     field: list(CashflowVariables.objects.values_list(field, flat=True))
#                     for field in cfs_columns_fields
#                 }
#
#                 aggregated_data = {}
#
#                 for field, columns in field_to_columns_map.items():
#                     # Sum values for matching columns
#                     aggregated_data[field] = filtered_df[columns].sum(axis=1).sum()
#
#                 # Convert aggregated data to a DataFrame for plotting
#                 aggregated_df = pd.DataFrame(
#                     list(aggregated_data.items()), columns=["Metric", "Sum"]
#                 )
#
#                 # Create a grouped bar chart using Plotly
#                 fig = px.bar(
#                     aggregated_df,
#                     x="Metric",
#                     y="Sum",
#                     text=aggregated_df["Sum"].apply(
#                         lambda x: f"{x:.2f}M"
#                     ),  # Add annotations
#                     color_discrete_sequence=px.colors.sequential.Viridis,  # Similar to 'viridis'
#                 )
#
#                 # Customize the layout
#                 fig.update_traces(textposition="outside", textfont_size=14)
#                 fig.update_layout(
#                     title="Sum of Metrics for Selected Years (in Millions)",
#                     title_font_size=24,
#                     xaxis_title="Metrics",
#                     yaxis_title="Sum (Millions)",
#                     xaxis=dict(tickangle=45, tickfont=dict(size=14)),
#                     yaxis=dict(
#                         tickfont=dict(size=14),
#                         showgrid=True,
#                         gridcolor="rgba(0, 0, 0, 0.1)",
#                     ),
#                     margin=dict(l=40, r=40, t=60, b=40),
#                     height=600,
#                     width=1000,
#                 )
#
#                 # Save the figure to a buffer as a PNG
#                 from io import BytesIO
#                 import base64
#
#                 buffer = BytesIO()
#                 fig.write_image(buffer, format="png", scale=3)  # Scale for higher DPI
#                 buffer.seek(0)
#                 graph_base64 = base64.b64encode(buffer.getvalue()).decode("utf-8")
#                 buffer.close()
#
#                 return JsonResponse(
#                     {
#                         "graph": graph_base64,
#                         "file_path": output_file,
#                         "summed_years": years,
#                         "total_sum": aggregated_df.to_dict(orient="records"),
#                     }
#                 )
#
#             except Exception as e:b
#                 print(f"Error generating graph: {e}")
#                 return JsonResponse(
#                     {"error": f"Error generating graph: {str(e)}"}, status=500
#                 )
#
#         return JsonResponse({"error": "No output file generated."}, status=400)
#
#     return JsonResponse({"error": "Invalid request method."}, status=400)
#


@csrf_exempt
@xframe_options_exempt
def yearly_test(request):
    return render(request, "yearly_dash.html")


@csrf_exempt
def download_csv(request):
    if request.method == "POST":
        file_path = request.POST.get("file_path")
        if file_path and os.path.exists(file_path):
            with open(file_path, "rb") as f:
                response = HttpResponse(
                    f.read(), content_type="application/octet-stream"
                )
                response["Content-Disposition"] = (
                    f'attachment; filename="{os.path.basename(file_path)}"'
                )
                return response
        return JsonResponse({"error": "File not found."}, status=400)


def ecl_landing(request):
    context = {
        "ecl_reports": ECLReport.objects.all(),
        "stage_allocations": StageAllocationReport.objects.all(),
        "loss_allowances": LossAllowance.objects.all(),
        "credit_exposures": CreditRiskExposure.objects.all(),}
    return render(request, "ecl.html", context)



from django.shortcuts import render
from django.http import Http404
import os
from django.conf import settings



@xframe_options_exempt
def ecl_landing_1(request):
    context = {
        "ecl_reports": ECLReport.objects.all(),
        "stage_allocations": StageAllocationReport.objects.all(),
        "loss_allowances": LossAllowance.objects.all(),
        "credit_exposures": CreditRiskExposure.objects.all(),
    }
    return render(request, "ecl.html", context)


def your_view(request):
    context = {
        'request': request,
    }
    return render(request, 'ecl.html', context)


def view_excel(request, filename):
    # Decode URL-encoded filename (e.g. spaces become %20)
    filename = urllib.parse.unquote(filename)

    # Build absolute path to the Excel file
    file_path = os.path.join(settings.MEDIA_ROOT, 'Financial_Statements', filename)

    # Debug: print the exact path
    print("Looking for file at:", file_path)

    # Check if the file exists
    if not os.path.exists(file_path):
        raise Http404("File not found")

    try:
        # Read Excel file and convert to HTML table
        # df = pd.read_excel(file_path, engine='openpyxl').fillna('')
        df = pd.read_excel(file_path, header=None, skiprows=8, engine='openpyxl').fillna('')
        html_table = df.to_html(classes='table table-bordered table-striped', header=False, index=False, border=0)
    except Exception as e:
        html_table = f"<p>Error reading Excel file: {e}</p>"

    return render(request, 'view_excel.html', {'table': html_table, 'filename': filename})
