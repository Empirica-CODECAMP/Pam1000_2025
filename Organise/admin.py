from django.contrib import admin

# Register your models here.
from django.contrib import admin
from .models import (
    FinancialYear,
    ConfigurationGroup,
    CashFlow,
    Disclosure,
    Subledger,
    TrialBalance,
    CombinedOutput,
    FinancialConfiguration,
)


@admin.register(FinancialYear)
class FinancialYearAdmin(admin.ModelAdmin):
    list_display = ("year",)
    search_fields = ("year",)


@admin.register(ConfigurationGroup)
class ConfigurationGroupAdmin(admin.ModelAdmin):
    list_display = ("name",)
    search_fields = ("name",)


@admin.register(CashFlow)
class CashFlowAdmin(admin.ModelAdmin):
    list_display = ("cash_flow_type",)
    search_fields = ("cash_flow_type",)


@admin.register(Disclosure)
class DisclosureAdmin(admin.ModelAdmin):
    list_display = ("disclosure_name",)
    search_fields = ("disclosure_name",)


@admin.register(Subledger)
class SubledgerAdmin(admin.ModelAdmin):
    list_display = ("name",)
    search_fields = ("name",)


@admin.register(TrialBalance)
class TrialBalanceAdmin(admin.ModelAdmin):
    list_display = ("name",)
    search_fields = ("name",)


@admin.register(CombinedOutput)
class CombinedOutputAdmin(admin.ModelAdmin):
    list_display = ("output_name",)
    search_fields = ("output_name",)


@admin.register(FinancialConfiguration)
class FinancialConfigurationAdmin(admin.ModelAdmin):
    list_display = ("year", "configuration_group")
    list_filter = ("year", "configuration_group")
    search_fields = ("year__year", "configuration_group__name")
