from django.db import models

# Create your models here.
GROUPS_CHOICES = (
    ("onerous", "Onerous"),
    ("non-onerous", "Non-Onerous"),
    ("remaining", "Remaining"),
    ("odd", "ODD"),
)

TYPE_CHOICES = (
    ("in-force", "In-Force"),
    ("new_business", "New Business"),
)


class Curves(models.Model):
    year = models.PositiveIntegerField()
    projected_month = models.PositiveIntegerField()
    nominal_forward_rate = models.FloatField()
    real_forward_rate = models.FloatField()

    class Meta:
        verbose_name = "Forward Rate"
        # verbose_name_plural = 'Forward Rates'  # Set the plural name here
        app_label = "users"  # Ensure this matches your app name

    def __str__(self):
        return (
            str(self.year)
            + " - "
            + str(self.projected_month)
            + " - "
            + str(self.nominal_forward_rate)
        )


class Portfolio(models.Model):
    name = models.CharField(max_length=100)
    description = models.TextField()

    class Meta:
        verbose_name = "Portfolio"
        verbose_name_plural = "Portfolios"

    def __str__(self):
        return self.name + " - " + self.description


class Insurance(models.Model):
    year = models.PositiveIntegerField()
    type = models.CharField(max_length=20, choices=TYPE_CHOICES)
    group = models.CharField(max_length=20, choices=GROUPS_CHOICES)
    portfolio = models.ForeignKey(Portfolio, on_delete=models.CASCADE, null=True)
    time = models.CharField(max_length=100)

    PREM_INC = models.FloatField(null=True, blank=True)
    DEATH_OUTGO = models.FloatField(null=True, blank=True)
    DISAB_OUTGO = models.FloatField(null=True, blank=True)
    INIT_EXP = models.FloatField(null=True, blank=True)
    REN_EXP = models.FloatField(null=True, blank=True)
    INIT_COMM = models.FloatField(null=True, blank=True)
    REN_COMM = models.FloatField(null=True, blank=True)
    PHIBEN_OUTGO = models.FloatField(null=True, blank=True)
    PHIBEN_OUTGO_BLL = models.FloatField(null=True, blank=True)
    CR_BEN_OUTGO = models.FloatField(null=True, blank=True)
    RETR_OUTGO = models.FloatField(null=True, blank=True)
    DTH_OUTGO = models.FloatField(null=True, blank=True)
    DREADDIS_OUTGO = models.FloatField(null=True, blank=True)
    TEMPDIS_OUTGO = models.FloatField(null=True, blank=True)
    RIDERC_OUTGO = models.FloatField(null=True, blank=True)
    RISK_ADJ = models.FloatField(null=True, blank=True)
    COVERAGE_UNITS = models.FloatField(null=True, blank=True)

    class Meta:
        verbose_name = "Insurance Data"
        verbose_name_plural = "Insurance Data"

    def __str__(self):
        return f"{self.year} - {self.type} - {self.group}"


class Reinsurance(models.Model):
    year = models.PositiveIntegerField()
    type = models.CharField(max_length=20, choices=TYPE_CHOICES)
    group = models.CharField(max_length=20, choices=GROUPS_CHOICES)
    portfolio = models.ForeignKey(Portfolio, on_delete=models.CASCADE, null=True)
    time = models.CharField(max_length=100)

    # Corrected field names (removed special characters and spaces)
    reins_prem_treaty_out_1 = models.FloatField(null=True, blank=True)
    reins_prem_treaty_out_2 = models.FloatField(null=True, blank=True)
    reins_prem_treaty_out_3 = models.FloatField(null=True, blank=True)
    reins_prem_treaty_out_4 = models.FloatField(null=True, blank=True)
    reins_prem_treaty_out_5 = models.FloatField(null=True, blank=True)
    reins_prem_treaty_out_6 = models.FloatField(null=True, blank=True)
    rpr_prem_out_treaty_out_1 = models.FloatField(null=True, blank=True)
    rpr_prem_out_treaty_out_2 = models.FloatField(null=True, blank=True)
    rpr_prem_out_treaty_out_3 = models.FloatField(null=True, blank=True)
    rpr_prem_out_treaty_out_4 = models.FloatField(null=True, blank=True)
    rpr_prem_out_treaty_out_5 = models.FloatField(null=True, blank=True)
    rpr_prem_out_treaty_out_6 = models.FloatField(null=True, blank=True)
    fr_repayment = models.FloatField(null=True, blank=True)
    fr_clawback = models.FloatField(null=True, blank=True)
    reins_rec_treaty_out_1 = models.FloatField(null=True, blank=True)
    reins_rec_treaty_out_2 = models.FloatField(null=True, blank=True)
    reins_rec_treaty_out_3 = models.FloatField(null=True, blank=True)
    reins_rec_treaty_out_4 = models.FloatField(null=True, blank=True)
    reins_rec_treaty_out_5 = models.FloatField(null=True, blank=True)
    reins_rec_treaty_out_6 = models.FloatField(null=True, blank=True)
    rpr_dth_rec_treaty_out_1 = models.FloatField(null=True, blank=True)
    rpr_dth_rec_treaty_out_2 = models.FloatField(null=True, blank=True)
    rpr_dth_rec_treaty_out_3 = models.FloatField(null=True, blank=True)
    rpr_dth_rec_treaty_out_4 = models.FloatField(null=True, blank=True)
    rpr_dth_rec_treaty_out_5 = models.FloatField(null=True, blank=True)
    rpr_dth_rec_treaty_out_6 = models.FloatField(null=True, blank=True)
    rpr_phiben_rec_treaty_out_1 = models.FloatField(null=True, blank=True)
    rpr_phiben_rec_treaty_out_2 = models.FloatField(null=True, blank=True)
    rpr_phiben_rec_treaty_out_3 = models.FloatField(null=True, blank=True)
    rpr_phiben_rec_treaty_out_4 = models.FloatField(null=True, blank=True)
    rpr_phiben_rec_treaty_out_5 = models.FloatField(null=True, blank=True)
    rpr_phiben_rec_treaty_out_6 = models.FloatField(null=True, blank=True)
    fr_new_finan = models.FloatField(null=True, blank=True)
    risk_adj_ri_treaty_out_fr_1 = models.FloatField(null=True, blank=True)
    risk_adj_ri_treaty_out_fr_2 = models.FloatField(null=True, blank=True)
    risk_adj_ri_treaty_out_fr_3 = models.FloatField(null=True, blank=True)
    risk_adj_ri_treaty_out_fr_4 = models.FloatField(null=True, blank=True)
    risk_adj_ri_treaty_out_fr_5 = models.FloatField(null=True, blank=True)
    risk_adj_ri_treaty_out_fr_6 = models.FloatField(null=True, blank=True)
    coverage_units_ri_treaty_out_1 = models.FloatField(null=True, blank=True)
    coverage_units_ri_treaty_out_2 = models.FloatField(null=True, blank=True)
    coverage_units_ri_treaty_out_3 = models.FloatField(null=True, blank=True)
    coverage_units_ri_treaty_out_4 = models.FloatField(null=True, blank=True)
    coverage_units_ri_treaty_out_5 = models.FloatField(null=True, blank=True)
    coverage_units_ri_treaty_out_6 = models.FloatField(null=True, blank=True)

    class Meta:
        verbose_name = "Reinsurance Data"
        verbose_name_plural = "Reinsurance Data"

    def __str__(self):
        return f"{self.year} - {self.type} - {self.group}"


from django.db import models
import os


class Insurance_Files(models.Model):
    file = models.FileField(
        upload_to="Rscript/Inputs/Base/User_Inputs/FCFs/", null=True, blank=True
    )
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return str(self.file)


class Forward_Rate_Files(models.Model):
    file = models.FileField(
        upload_to="Rscript/Assumptions/TABLES/Curves/Base/Csv/", null=True, blank=True
    )
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return str(self.file)
