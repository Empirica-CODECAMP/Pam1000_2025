from django.contrib import admin
from .models import Audit, PowerBi
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


# Fetch function for Clearview Audit report
def fetch_clearview_audit_report(modeladmin, request, queryset):
    instance = queryset.first()
    if not instance:
        return HttpResponse("No file selected.", status=400)

    try:
        df = pd.read_excel(
            instance.clearview_audit_file.path, sheet_name="Clearview Audit"
        )  # Adjust sheet name as necessary
        return HttpResponse(styled_html_table(df), content_type="text/html")
    except Exception as e:
        return HttpResponse(f"Error fetching Clearview Audit report: {e}", status=500)


fetch_clearview_audit_report.short_description = "Fetch Clearview Audit Report"


# Fetch function for Power BI KPI report
def fetch_kpi_power_bi_report(modeladmin, request, queryset):
    instance = queryset.first()
    if not instance:
        return HttpResponse("No file selected.", status=400)

    try:
        df = pd.read_excel(
            instance.kpi_power_bi_file.path, sheet_name="KPI Power BI"
        )  # Adjust sheet name as necessary
        return HttpResponse(styled_html_table(df), content_type="text/html")
    except Exception as e:
        return HttpResponse(f"Error fetching KPI Power BI report: {e}", status=500)


fetch_kpi_power_bi_report.short_description = "Fetch KPI Power BI Report"


# Admin class for Audit
@admin.register(Audit)
class AuditAdmin(admin.ModelAdmin):
    list_display = ("title", "created_at")  # Display fields in the admin list view
    actions = [
        fetch_clearview_audit_report
    ]  # Registering the fetch action for Clearview Audit


# Admin class for PowerBi
@admin.register(PowerBi)
class PowerBiAdmin(admin.ModelAdmin):
    list_display = ("title", "created_at")  # Display fields in the admin list view
    actions = [
        fetch_kpi_power_bi_report
    ]  # Registering the fetch action for Power BI KPI
