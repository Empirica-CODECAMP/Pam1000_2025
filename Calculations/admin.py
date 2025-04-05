from django.contrib import admin
from .models import Pam1000, BudgetSetup, ModelRun, RunLog
import pandas as pd
from django.http import HttpResponse
from unfold.admin import ModelAdmin as UnfoldModelAdmin


# Function to generate styled HTML tables
def styled_html_table(df):
    df.columns = ["" if "Unnamed" in str(col) else col for col in df.columns]
    df.fillna("", inplace=True)
    styles = """
    <style>
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 25px 0;
            font-size: 18px;
            text-align: left;
        }
        table th, table td {
            padding: 12px 15px;
            border: 1px solid #ddd;
        }
        table tr {
            background-color: #f2f2f2;
        }
        table th {
            background-color: #4CAF50;
            color: white;
            font-weight: bold;
        }
        table tr:nth-child(even) {
            background-color: #f9f9f9;
        }
        table tr:hover {
            background-color: #f1f1f1;
        }
    </style>
    """
    return styles + df.to_html(index=False)


# Fetch function for Pam1000 report
def fetch_pam1000_report(modeladmin, request, queryset):
    instance = queryset.first()
    if not instance:
        return HttpResponse("No file selected.", status=400)

    try:
        df = pd.read_excel(
            instance.upload_file.path
        )  # Adjust the sheet name or file type if necessary
        return HttpResponse(styled_html_table(df), content_type="text/html")
    except Exception as e:
        return HttpResponse(f"Error fetching Pam1000 report: {e}", status=500)


fetch_pam1000_report.short_description = "Fetch Pam1000 Report"


# Fetch function for BudgetSetup report
def fetch_budget_setup_report(modeladmin, request, queryset):
    instance = queryset.first()
    if not instance:
        return HttpResponse("No file selected.", status=400)

    try:
        df = pd.read_excel(
            instance.orsa_file.path
        )  # Adjust the sheet name if necessary
        return HttpResponse(styled_html_table(df), content_type="text/html")
    except Exception as e:
        return HttpResponse(f"Error fetching Budget Setup report: {e}", status=500)


fetch_budget_setup_report.short_description = "Fetch Budget Setup Report"


# Fetch function for ModelRun result
def fetch_model_run_result(modeladmin, request, queryset):
    instance = queryset.first()
    if not instance:
        return HttpResponse("No result file selected.", status=400)

    try:
        df = pd.read_excel(
            instance.result_file.path
        )  # Adjust the sheet name if necessary
        return HttpResponse(styled_html_table(df), content_type="text/html")
    except Exception as e:
        return HttpResponse(f"Error fetching ModelRun result: {e}", status=500)


fetch_model_run_result.short_description = "Fetch Model Run Result"


# Admin class for Pam1000
@admin.register(Pam1000)
class Pam1000Admin(admin.ModelAdmin):
    list_display = ("title", "created_at")  # Display title and upload time
    actions = [fetch_pam1000_report]  # Registering the fetch action


# Admin class for BudgetSetup
@admin.register(BudgetSetup)
class BudgetSetupAdmin(admin.ModelAdmin):
    list_display = (
        "setup_name",
        "creation_date",
        "last_modified",
    )  # Display key fields
    actions = [fetch_budget_setup_report]  # Registering the fetch action


# Admin class for ModelRun
from django.shortcuts import render

# Admin class for ModelRun
from django.contrib import admin
from django.utils.safestring import mark_safe
from django.middleware.csrf import get_token
from .models import ModelRun  # Import your model


@admin.register(ModelRun)
class ModelRunAdmin(UnfoldModelAdmin):
    list_display = ("model_name", "run_date", "status")
    actions = [fetch_model_run_result]

    change_list_template = "admin/model_run.html"  # Specify the custom template path

    def changelist_view(self, request, extra_context=None):
        # Create a form that submits a POST request
        csrf_token = get_token(request)  # Get the CSRF token
        button_html = mark_safe(
            """
            <form action="http://127.0.0.1:8000/Calculations/run_model/" method="post" style="display:inline;">
                <input type="hidden" name="csrfmiddlewaretoken" value="{csrf_token}">
                <button type="submit" class="button">Run Model</button>
            </form>
            """.format(csrf_token=csrf_token)
        )

        # Add the button HTML to extra context
        extra_context = extra_context or {}
        extra_context["custom_button"] = button_html

        # Call the superclass method with the extra context
        return super().changelist_view(request, extra_context=extra_context)


# Admin class for RunLog (no fetch action needed here)
@admin.register(RunLog)
class RunLogAdmin(admin.ModelAdmin):
    list_display = (
        "model_run",
        "timestamp",
    )  # Display the associated ModelRun and log timestamp
    search_fields = ("model_run__model_name",)  # Allow searching by model run name
    list_filter = ("timestamp",)  # Filter by log entry timestamp


from django.contrib import admin
from django.urls import path
from django.shortcuts import render
import pandas as pd
import plotly.express as px
import os
from django.conf import settings


class CustomAdminSite(admin.AdminSite):
    site_header = "Insurance Dashboard Admin"

    def get_urls(self):
        urls = super().get_urls()
        custom_urls = [
            path("dashboard/", self.admin_view(self.dashboard_view), name="dashboard"),
        ]
        return custom_urls + urls

    def dashboard_view(self, request):
        file_path = os.path.join(
            settings.BASE_DIR,
            "Calculations",
            "Rscript",
            "Output",
            "Combined_Output_2024.xlsx",
        )

        try:
            df = pd.read_excel(file_path, sheet_name="CFS_NB_Insurance")
        except FileNotFoundError:
            return render(
                request,
                "admin/dashboard_charts.html",
                {"error": "Data file not found."},
            )

        fig = px.line(
            df,
            x=df.columns[0],
            y=df.columns[1:],
            title="Insurance Dashboard",
            labels={df.columns[0]: "Date"},
        )
        fig.update_layout(
            xaxis_title="Month",
            yaxis_title="Financial Metrics",
            template="plotly_white",
            hovermode="x unified",
        )
        fig2 = px.bar(
            df,
            x=df.columns[0],
            y=df.columns[1:],
            title="Insurance Dashboard - Bar Chart",
            labels={df.columns[0]: "Month"},
        )

        chart = fig.to_html(full_html=False)
        chart2 = fig2.to_html(full_html=False)

        context = {"chart": chart, "chart2": chart2}
        return render(request, "admin/dashboard_charts.html", context)


admin_site = CustomAdminSite(name="custom_admin")

from .models import CashflowVariables


@admin.register(CashflowVariables)
class CashflowVariablesAdmin(UnfoldModelAdmin):
    list_display = ("premiums", "claims", "admin", "acquisitions")
