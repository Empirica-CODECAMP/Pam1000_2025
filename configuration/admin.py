from django.contrib import admin
from .models import *
from import_export import resources
from import_export.admin import ImportExportModelAdmin
from unfold.admin import ModelAdmin as UnfoldModelAdmin
# Register your models here.


class ReinsuranceCashflowVariablesResource(resources.ModelResource):
    class Meta:
        model = ReinsuranceCashflowVariables


class InsuranceCashflowVariablesResource(resources.ModelResource):
    class Meta:
        model = InsuranceCashflowVariables


class RunSettingsResource(resources.ModelResource):
    class Meta:
        model = RunSettings


class ReinsuranceCashflowVariablesAdminImport(ImportExportModelAdmin, UnfoldModelAdmin):
    resource_class = ReinsuranceCashflowVariablesResource
    list_display = ("premium", "claims", "acquisition", "admin")


class InsuranceCashflowVariablesAdminImport(ImportExportModelAdmin, UnfoldModelAdmin):
    resource_class = InsuranceCashflowVariablesResource
    list_display = ("premium", "claims", "acquisition", "admin")


class RunSettingsAdminImport(ImportExportModelAdmin, UnfoldModelAdmin):
    resource_class = RunSettingsResource
    list_display = ("PrevRun_Nr", "Run_Nr", "NBRun_Nr", "Run_Description")
    # Define actions as a list of method references
    actions = ["run_year"]  # This needs to be the method name (lowercase)

    # Define the action method for Run Year
    def run_year(self, request, queryset):
        for i in queryset:
            # Assuming `Run_Year()` is a method on your model
            i.Run_Nr()  # Call the method for each selected object
            i.save()  # Save changes if any are made
        self.message_user(
            request, "Run Year executed successfully on selected items."
        )  # Display a message in admin

    # Set the short description for the action
    run_year.short_description = (
        "Run Year"  # Use the method name, not the string "Run Year"
    )


admin.site.register(
    ReinsuranceCashflowVariables, ReinsuranceCashflowVariablesAdminImport
)
admin.site.register(InsuranceCashflowVariables, InsuranceCashflowVariablesAdminImport)
admin.site.register(RunSettings, RunSettingsAdminImport)
