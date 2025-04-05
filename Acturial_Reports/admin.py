from django.contrib import admin
from django.urls import path
from django.http import HttpResponse
import pandas as pd
from unfold.admin import ModelAdmin as UnfoldModelAdmin

from .models import ActuarialReport


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


def fetch_report_lcb(self, request, queryset):
    instance = queryset.first()  # Get the first selected instance
    if not instance:
        return HttpResponse("No file selected.", status=400)  # Handle no file selected

    # Try to fetch the '1.1 LCB' report
    try:
        df_lcb = pd.read_excel(instance.file.path, sheet_name="Report 1.1")
        return HttpResponse(styled_html_table(df_lcb), content_type="text/html")
    except Exception as e:
        return HttpResponse(f"Error fetching '1.1 LCB' report: {e}", status=500)


fetch_report_lcb.short_description = "Fetch Report 1.1 LCB"


def fetch_report_csm(self, request, queryset):
    instance = queryset.first()  # Get the first selected instance
    if not instance:
        return HttpResponse("No file selected.", status=400)  # Handle no file selected

    # Try to fetch the '1.2 CSM' report
    try:
        df_csm = pd.read_excel(
            instance.file.path, sheet_name="Report 1.2 - CSM release"
        )
        return HttpResponse(styled_html_table(df_csm), content_type="text/html")
    except Exception as e:
        return HttpResponse(f"Error fetching '1.2 CSM' report: {e}", status=500)


fetch_report_csm.short_description = "Fetch Report 1.2 CSM"


def fetch_report_1_3(self, request, queryset):
    instance = queryset.first()  # Get the first selected instance
    if not instance:
        return HttpResponse("No file selected.", status=400)  # Handle no file selected

    # Try to fetch the '1.3 Report'
    try:
        df_report_1_3 = pd.read_excel(
            instance.file.path, sheet_name="Report 1.3 NB Recognition-Ins"
        )
        return HttpResponse(styled_html_table(df_report_1_3), content_type="text/html")
    except Exception as e:
        return HttpResponse(f"Error fetching the '1.3 Report': {e}", status=500)


fetch_report_1_3.short_description = "Fetch Report 1.3"


from django.contrib import admin
from .models import ActuarialReport
from django.utils.html import format_html
from .utils import (
    load_csv_data,
    generate_graph,
)  # Adjust import based on utils location


@admin.register(ActuarialReport)
class ActuarialReportAdmin(UnfoldModelAdmin):
    list_display = ("title", "created_at")  # Show title and created_at in list view
    # change_list_template = "admin/acturial_reports_change_list.html"
    actions = ["fetch_report_lcb", "fetch_report_csm", "fetch_report_1_3"]

    # Custom actions
    def fetch_report_lcb(self, request, queryset):
        return fetch_report_lcb(self, request, queryset)

    fetch_report_lcb.short_description = "Fetch Report 1.1 LCB"

    def fetch_report_csm(self, request, queryset):
        return fetch_report_csm(self, request, queryset)

    fetch_report_csm.short_description = "Fetch Report 1.2 CSM"

    def fetch_report_1_3(self, request, queryset):
        return fetch_report_1_3(self, request, queryset)

    fetch_report_1_3.short_description = "Fetch Report 1.3"

    # # Customizing the changelist view to include the graph
    # def changelist_view(self, request, extra_context=None):
    #     # Load data from CSV or Excel and generate graph
    #     data = load_csv_data('media/actuarial_reports/Report_1.2_CSM_run-off_2_Vf9IJRI.xlsx')
    #     graph_image = generate_graph(data)

    #     # Pass graph data as extra context to the template
    #     extra_context = extra_context or {}
    #     extra_context['graph_image'] = graph_image
    #     return super().changelist_view(request, extra_context=extra_context)
