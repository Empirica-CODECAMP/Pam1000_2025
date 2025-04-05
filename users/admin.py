from django.contrib import admin
from .models import *
from import_export import resources
from import_export.admin import ImportExportModelAdmin
from django.template.response import TemplateResponse
from django.utils import timezone
from datetime import datetime
from django.contrib import admin
from django.template.response import TemplateResponse
from django.utils import timezone
from datetime import datetime
from import_export import resources
from .models import Curves  # Ensure to import your model
from django.http import HttpResponseRedirect
from django.urls import reverse


# Curves Admin and Resource
class CurvesResource(resources.ModelResource):
    class Meta:
        model = Curves


class CurvesAdminImport(ImportExportModelAdmin):
    resource_class = CurvesResource
    list_display = (
        "year",
        "projected_month",
        "nominal_forward_rate",
        "real_forward_rate",
    )

    def get_list_chart_data(self, queryset):
        if not queryset.exists():  # Ensure there's data
            return {"labels": [], "datasets": []}  # Return empty structure if no data

        current_year = timezone.now().year
        months = [datetime(current_year, month, 1) for month in range(1, 13)]

        labels = []
        nominal_totals = []
        real_totals = []

        # Assuming 'projected_month' is an integer (1 for Jan, 2 for Feb, etc.)
        for month in months:
            labels.append(month.strftime("%b %Y"))

            # Filter and sum nominal and real forward rates for each month
            nominal_totals.append(
                sum(
                    x.nominal_forward_rate
                    for x in queryset
                    if x.year == month.year and x.projected_month == month.month
                )
            )
            real_totals.append(
                sum(
                    x.real_forward_rate
                    for x in queryset
                    if x.year == month.year and x.projected_month == month.month
                )
            )

        colors = ["#79aec8", "#ff9999"]

        return {
            "labels": labels,
            "datasets": [
                {
                    "label": "Nominal Forward Rate",
                    "data": nominal_totals,
                    "backgroundColor": colors[0],
                },
                {
                    "label": "Real Forward Rate",
                    "data": real_totals,
                    "backgroundColor": colors[1],
                },
            ],
        }

    def changelist_view(self, request, extra_context=None):
        extra_context = extra_context or {}
        queryset = self.get_queryset(request)
        chart_data = self.get_list_chart_data(queryset)

        print("App Label:", self.model._meta.app_label)  # Log app label

        extra_context["chart_data"] = chart_data
        return super().changelist_view(request, extra_context=extra_context)


admin.site.register(Curves, CurvesAdminImport)


# Insurance Admin and Resource
class InsuranceResource(resources.ModelResource):
    class Meta:
        model = Insurance


class InsuranceAdminImport(ImportExportModelAdmin):
    resource_class = InsuranceResource
    list_display = ("year", "type", "group", "portfolio", "time")
    search_fields = ("year", "type", "group", "portfolio__name", "time")
    actions = ["Import_files", "delete_all"]

    def Import_files(self, request, queryset):
        # Perform any logic if needed
        # Redirect to another page (e.g., an 'import' page)
        portfolio_names = ",".join(
            [portfolio.name for portfolio in Portfolio.objects.all()]
        )
        return HttpResponseRedirect(
            reverse("import_files_page") + f"?portfolios={portfolio_names}"
        )

    Import_files.short_description = "Import Files"

    def delete_all(self, request, queryset):
        Insurance.objects.all().delete()

    delete_all.short_description = "Delete All"


admin.site.register(Insurance, InsuranceAdminImport)


# Reinsurance Admin and Resource
class ReinsuranceResource(resources.ModelResource):
    class Meta:
        model = Reinsurance


class ReinsuranceAdminImport(ImportExportModelAdmin):
    resource_class = ReinsuranceResource
    list_display = ("year", "type", "group", "portfolio", "time")
    search_fields = ("year", "type", "group", "portfolio", "time")


admin.site.register(Reinsurance, ReinsuranceAdminImport)


# Portfolio Admin and Resource
class PortfolioResource(resources.ModelResource):
    class Meta:
        model = Portfolio


class PortfolioAdminImport(ImportExportModelAdmin):
    resource_class = PortfolioResource
    list_display = ("name", "description")
    search_fields = ("name", "description")


admin.site.register(Portfolio, PortfolioAdminImport)


class Insurance_FilesResource(resources.ModelResource):
    class Meta:
        model = Insurance_Files


class Insurance_FilesAdminImport(ImportExportModelAdmin):
    resource_class = Insurance_FilesResource
    list_display = ("file", "created_at")


admin.site.register(Insurance_Files, Insurance_FilesAdminImport)


class Forward_Rate_FilesResource(resources.ModelResource):
    class Meta:
        model = Forward_Rate_Files


class Forward_Rate_FilesAdminImport(ImportExportModelAdmin):
    resource_class = Forward_Rate_FilesResource
    list_display = ("file", "created_at")


admin.site.register(Forward_Rate_Files, Forward_Rate_FilesAdminImport)
