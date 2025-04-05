# calculations/tasks.py

from celery import shared_task
from .models import ModelRun, RunLog
import subprocess
import json
import os


@shared_task
def execute_r_script(model_run_id):
    try:
        model_run = ModelRun.objects.get(id=model_run_id)
        # Update status to 'running'
        model_run.status = "running"
        model_run.save()

        # Log the start of the task
        RunLog.objects.create(
            model_run=model_run, log_entry="R script execution started."
        )

        # Define the path to your R script
        r_script_path = os.path.join(
            os.getcwd(), "scripts", "ifrs17_model.R"
        )  # Adjust the path as needed

        # Prepare command to execute R script
        # Pass parameters as a JSON string argument
        command = ["Rscript", r_script_path, json.dumps(model_run.input_parameters)]

        # Execute the R script
        result = subprocess.run(command, capture_output=True, text=True)

        if result.returncode == 0:
            # R script executed successfully
            # Assume the R script outputs a result file path
            result_file_path = os.path.join(
                "model_results", f"result_{model_run.id}.json"
            )  # Adjust as needed

            # Save the result file (ensure the R script outputs to the correct location)
            # Here, you might need to move or process the result as per your requirements

            model_run.status = "completed"
            # Optionally, save the result data
            # model_run.result_file = result_file_path
            model_run.save()

            # Log success
            RunLog.objects.create(
                model_run=model_run, log_entry="R script executed successfully."
            )
        else:
            # R script failed
            model_run.status = "failed"
            model_run.error_message = result.stderr
            model_run.save()

            # Log failure
            RunLog.objects.create(
                model_run=model_run,
                log_entry=f"R script failed with error: {result.stderr}",
            )
    except Exception as e:
        # Handle unexpected errors
        model_run.status = "failed"
        model_run.error_message = str(e)
        model_run.save()

        # Log exception
        RunLog.objects.create(
            model_run=model_run, log_entry=f"Unexpected error: {str(e)}"
        )


from celery import shared_task
import pandas as pd
import plotly.express as px
import os
from django.conf import settings


@shared_task
def generate_charts():
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
        return {"error": "Data file not found."}

    # Plot a line chart using Plotly Express
    fig = px.line(
        df,
        x=df.columns[0],
        y=df.columns[1:],
        title="Insurance Dashboard",
        labels={df.columns[0]: "Date"},
    )
    fig.update_layout(
        xaxis_title="Month", yaxis_title="Financial Metrics", template="plotly_white"
    )

    # Bar chart for financial metrics
    fig2 = px.bar(
        df,
        x=df.columns[0],
        y=df.columns[1:],
        title="Insurance Dashboard - Bar Chart",
        labels={df.columns[0]: "Month"},
    )

    chart = fig.to_html(full_html=False)
    chart2 = fig2.to_html(full_html=False)

    return {"line_chart": chart, "bar_chart": chart2}
