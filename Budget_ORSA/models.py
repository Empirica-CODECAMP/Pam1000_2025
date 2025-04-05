from django.db import models


class ORSADisclosures(models.Model):
    title = models.CharField(max_length=255)
    financial_orsa_file = models.FileField(upload_to="budget_orsa/financial_orsa/")
    # actuarial_report_file = models.FileField(upload_to='budget_orsa/actuarial_reports/')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.title


class ActuarialReport(models.Model):
    title = models.CharField(max_length=255)
    # financial_orsa_file = models.FileField(upload_to='budget_orsa/financial_orsa/')
    actuarial_report_file = models.FileField(upload_to="budget_orsa/actuarial_reports/")
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.title


class ORSA_Config(models.Model):
    Stress = models.CharField(max_length=255)
    Value = models.CharField(max_length=255)
    Description = models.CharField(max_length=255)

    def __str__(self):
        return self.Stress
