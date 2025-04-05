from django.db import models

RiskAdjChoices = (
    ("Percentage", "Percentage"),
    ("Formula", "Formula"),
)


# Create your models here.
class RunSettings(models.Model):
    PrevRun_Nr = models.IntegerField()
    NBRun_Nr = models.IntegerField()
    Run_Nr = models.IntegerField()
    Run_Description = models.CharField(max_length=200)
    ForwardInterestRatesName_IFstart = models.CharField(max_length=200)
    ForwardInterestRatesName_IFend = models.CharField(max_length=200)
    ForwardInterestRatesName_NB = models.CharField(max_length=200)
    EconomicAssumptionsName = models.CharField(max_length=200)
    RiskAdj = models.CharField(max_length=200, choices=RiskAdjChoices)
    RiskAdjustmentFac = models.FloatField()
    IncurredAcqCotsPeriod = models.FloatField()

    def __str__(self):
        return f"{self.Run_Description} - {self.Run_Nr} - {self.PrevRun_Nr} - {self.NBRun_Nr}"


class InsuranceCashflowVariables(models.Model):
    premium = models.CharField(max_length=200)
    claims = models.CharField(max_length=200)
    acquisition = models.CharField(max_length=200)
    admin = models.CharField(max_length=200)

    def __str__(self):
        return f"{self.premium} - {self.claims} - {self.acquisition} - {self.admin}"


class ReinsuranceCashflowVariables(models.Model):
    premium = models.CharField(max_length=200)
    claims = models.CharField(max_length=200)
    acquisition = models.CharField(max_length=200)
    admin = models.CharField(max_length=200)

    def __str__(self):
        return f"{self.premium} - {self.claims} - {self.acquisition} - {self.admin}"
