from django.contrib import admin
from .models import Subledger, TrialBalance
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


# Fetch function for Subledger report
def fetch_subledger_report(modeladmin, request, queryset):
    instance = queryset.first()
    if not instance:
        return HttpResponse("No file selected.", status=400)

    try:
        df = pd.read_excel(
            instance.subledger_file.path, sheet_name="Subledger"
        )  # Adjust sheet name as necessary
        return HttpResponse(styled_html_table(df), content_type="text/html")
    except Exception as e:
        return HttpResponse(f"Error fetching subledger report: {e}", status=500)


fetch_subledger_report.short_description = "Fetch Subledger Report"


# Fetch function for Trial Balance report
def fetch_trial_balance_report(modeladmin, request, queryset):
    instance = queryset.first()
    if not instance:
        return HttpResponse("No file selected.", status=400)

    try:
        df = pd.read_excel(
            instance.trial_balance_file.path, sheet_name="TrialBalance"
        )  # Adjust sheet name as necessary
        return HttpResponse(styled_html_table(df), content_type="text/html")
    except Exception as e:
        return HttpResponse(f"Error fetching trial balance report: {e}", status=500)


fetch_trial_balance_report.short_description = "Fetch Trial Balance Report"


# Admin class for Subledger
@admin.register(Subledger)
class SubledgerAdmin(admin.ModelAdmin):
    list_display = ("title", "created_at")  # Display fields in the admin list view
    actions = [fetch_subledger_report]  # Registering the fetch action for subledger


# Admin class for TrialBalance
@admin.register(TrialBalance)
class TrialBalanceAdmin(admin.ModelAdmin):
    list_display = ("title", "created_at")  # Display fields in the admin list view
    actions = [
        fetch_trial_balance_report
    ]  # Registering the fetch action for trial balance
