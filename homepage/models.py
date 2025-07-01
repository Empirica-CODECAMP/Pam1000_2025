from django.db import models
import os
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


class Setup(models.Model):
    # General Setup
    reporting_date_previous = models.DateField()
    reporting_date_current = models.DateField()
    reporting_currency = models.CharField(max_length=10)

    # Calculation Scope
    insurance_contracts = models.BooleanField()
    reinsurance_contracts = models.BooleanField()
    insurance_new_business = models.BooleanField()
    reinsurance_new_business = models.BooleanField()
    foreign_currency_needed = models.BooleanField()
    linked_cashflows = models.BooleanField()
    dependent_cashflows = models.BooleanField()
    loss_components = models.BooleanField()
    gic_external_model = models.BooleanField()

    # Options
    interest_rate_effects = models.CharField(max_length=50)
    disaggregate_change = models.BooleanField()
    simplify_ra = models.BooleanField()
    discount_csm = models.BooleanField()
    discount_acquisition_flows = models.BooleanField()
    discount_amortisation_pattern = models.CharField(max_length=100, blank=True)
    granular_yield = models.BooleanField()

    # #Inputs
    # date = models.DateField()
    # rfr_pc = models.CharField(max_length=50)

    def __str__(self):
        return f"{self.reporting_date_previous} to {self.reporting_date_current} Setup"

class SetupInput(models.Model):
    date = models.DateField()
    rfr_pc = models.FileField(upload_to='ecl_calculations/rfr_pc/')
    setup = models.ForeignKey(Setup, on_delete=models.CASCADE, related_name='setup_inputs')

    def __str__(self):
        return f"Setup Input for {self.setup}"


def upload_to_by_category(instance, filename):
    # Default to 'misc' if no category
    category = instance.category or 'misc'
    return os.path.join('uploads', 'input_files', category, filename)

class InputUpload(models.Model):

    INPUT_CATEGORIES = [
    ('core', 'Core Inputs'),
    ('insurance', 'Insurance'),
    ('reinsurance', 'Reinsurance'),
]

    INPUT_TYPE_CHOICES = [
    ('yield_curve', 'Yield Curve'),
    ('exchange_rate', 'Exchange Rate'),
    ('i_groups', 'I Groups'),
    ('i_equity', 'I Equity'),
    ('i_new_gen', 'I NEW GEN'),
    ('i_new_cfs', 'I NEW CFs'),
    ('i_if_gen', 'I IF GEN'),
    ('i_if_fcfs', 'I IF FCFs'),
    ('i_if_patterns', 'I IF PATTERNS'),  
    ('r_groups', 'R Groups'),
    ('r_equity', 'R EQUITY'),
    ('r_i_mapping', 'R I Mapping'),  
    ('r_new_gen', 'R NEW GEN'),      
    ('r_new_cfs', 'R NEW CFs'),
    ('r_new_lr', 'R NEW LR'),
    ('r_i_new_cfs', 'R I NEW CFs'),
    ('r_if_gen', 'R IF GEN'),
    ('r_if_fcfs', 'R IF FCFs'),
    ('r_if_patterns', 'R IF Patterns'),  
    ('r_i_if_fcfs', 'R I IF FCFs'),
    ('r_if_gen_lr', 'R IF GEN LR')
]
    category = models.CharField(max_length=50, choices=INPUT_CATEGORIES, null=True, blank=True)
    input_type = models.CharField(max_length=50, choices=INPUT_TYPE_CHOICES)
    date = models.DateField(null=True, blank=True)
    file = models.FileField(upload_to=upload_to_by_category)
    uploaded_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.get_input_type_display()} - {self.date or 'No Date'}"