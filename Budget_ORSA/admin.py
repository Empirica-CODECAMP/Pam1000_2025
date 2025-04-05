from django.contrib import admin
from .models import ORSADisclosures, ActuarialReport, ORSA_Config
import pandas as pd
from django.http import HttpResponse


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


# Fetch function for Financial ORSA report
def fetch_financial_orsa_report(modeladmin, request, queryset):
    instance = queryset.first()
    if not instance:
        return HttpResponse("No file selected.", status=400)

    try:
        df = pd.read_excel(
            instance.financial_orsa_file.path, sheet_name="Financial ORSA"
        )  # Adjust sheet name as necessary
        return HttpResponse(styled_html_table(df), content_type="text/html")
    except Exception as e:
        return HttpResponse(f"Error fetching Financial ORSA report: {e}", status=500)


fetch_financial_orsa_report.short_description = "Fetch Financial ORSA Report"


# Fetch function for Actuarial Report
def fetch_actuarial_report(modeladmin, request, queryset):
    instance = queryset.first()
    if not instance:
        return HttpResponse("No file selected.", status=400)

    try:
        df = pd.read_excel(
            instance.actuarial_report_file.path, sheet_name="Actuarial Report"
        )  # Adjust sheet name as necessary
        return HttpResponse(styled_html_table(df), content_type="text/html")
    except Exception as e:
        return HttpResponse(f"Error fetching Actuarial Report: {e}", status=500)


fetch_actuarial_report.short_description = "Fetch Actuarial Report"


# Admin class for ORSADisclosures
@admin.register(ORSADisclosures)
class ORSADisclosuresAdmin(admin.ModelAdmin):
    list_display = ("title", "created_at")  # Display fields in the admin list view
    actions = [
        fetch_financial_orsa_report
    ]  # Registering the fetch action for Financial ORSA


# Admin class for ActuarialReport
@admin.register(ActuarialReport)
class ActuarialReportAdmin(admin.ModelAdmin):
    list_display = ("title", "created_at")  # Display fields in the admin list view
    actions = [
        fetch_actuarial_report
    ]  # Registering the fetch action for Actuarial Report


# Admin class for ORSA_Config
@admin.register(ORSA_Config)
class ORSA_ConfigAdmin(admin.ModelAdmin):
    list_display = (
        "Stress",
        "Value",
        "Description",
    )  # Display fields in the admin list view
