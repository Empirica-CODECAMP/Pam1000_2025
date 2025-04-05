from django.db import models


class Audit(models.Model):
    title = models.CharField(max_length=255)
    clearview_audit_file = models.FileField(
        upload_to="analytics/reports/clearview_audit/"
    )
    # kpi_power_bi_file = models.FileField(upload_to='analytics/reports/kpi_power_bi/')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.title

    class meta:
        verbose_name_plural = "Audit"


class PowerBi(models.Model):
    title = models.CharField(max_length=255)
    # clearview_audit_file = models.FileField(upload_to='analytics/reports/clearview_audit/')
    kpi_power_bi_file = models.FileField(upload_to="analytics/reports/kpi_power_bi/")
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.title

    class meta:
        verbose_name_plural = "PowerBi"
