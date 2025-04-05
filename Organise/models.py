from django.db import models


class FinancialYear(models.Model):
    year = models.PositiveIntegerField(unique=True)

    def __str__(self):
        return str(self.year)


class ConfigurationGroup(models.Model):
    name = models.CharField(max_length=100)

    def __str__(self):
        return self.name


class CashFlow(models.Model):
    cash_flow_type = models.CharField(max_length=100)

    def __str__(self):
        return self.cash_flow_type


class Disclosure(models.Model):
    disclosure_name = models.CharField(max_length=100)

    def __str__(self):
        return self.disclosure_name


class Subledger(models.Model):
    name = models.CharField(max_length=100)

    def __str__(self):
        return self.name


class TrialBalance(models.Model):
    name = models.CharField(max_length=100)

    def __str__(self):
        return self.name


class CombinedOutput(models.Model):
    output_name = models.CharField(max_length=100)

    def __str__(self):
        return self.output_name


class FinancialConfiguration(models.Model):
    year = models.ForeignKey(FinancialYear, on_delete=models.CASCADE)
    configuration_group = models.ForeignKey(
        ConfigurationGroup, on_delete=models.CASCADE
    )
    cash_flows = models.ManyToManyField(CashFlow, blank=True)
    disclosures = models.ManyToManyField(Disclosure, blank=True)
    subledger = models.ForeignKey(
        Subledger, on_delete=models.CASCADE, blank=True, null=True
    )
    trial_balance = models.ForeignKey(
        TrialBalance, on_delete=models.CASCADE, blank=True, null=True
    )
    combined_output = models.ManyToManyField(CombinedOutput, blank=True)

    def __str__(self):
        return f"{self.configuration_group} - {self.year}"
