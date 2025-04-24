from django.db import models

# Create your models here.



from django.db import models

class ECLReport(models.Model):
    name = models.CharField(max_length=200)
    file = models.FileField(upload_to='ecl_calculations/ecl_reports/')
    uploaded_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name

class StageAllocationReport(models.Model):
    name = models.CharField(max_length=200)
    file = models.FileField(upload_to='ecl_calculations/stage_allocations/')
    uploaded_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name

class LossAllowance(models.Model):
    name = models.CharField(max_length=200)
    file = models.FileField(upload_to='ecl_calculations/loss_allowances/')
    uploaded_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name

class CreditRiskExposure(models.Model):
    name = models.CharField(max_length=200)
    file = models.FileField(upload_to='ecl_calculations/credit_risk_exposures/')
    uploaded_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name

