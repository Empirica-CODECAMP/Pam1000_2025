from django.db import models
from datetime import datetime

current_year = datetime.now().year
YEAR_CHOICES = [
    (r, r) for r in range(2000, current_year + 5)
]  # From 2000 to 5 years in the future


# 1. Model for uploading the Pam1000 file
class Pam1000(models.Model):
    title = models.TextField()
    upload_file = models.FileField(
        upload_to="pam1000_files/", null=True, blank=True
    )  # Upload Pam1000 file
    created_at = models.DateTimeField(
        auto_now_add=True
    )  # Track when the file was uploaded

    def __str__(self):
        return f"Pam1000 File - {self.title}"

    class Meta:
        verbose_name_plural = "Pam1000"


# 2. Model for Budget/ORSA Setup
class BudgetSetup(models.Model):
    setup_name = models.CharField(max_length=100)  # Name of the ORSA setup
    description = models.TextField(
        null=True, blank=True
    )  # Optional description of the setup
    creation_date = models.DateTimeField(
        auto_now_add=True
    )  # Date when the setup was created
    last_modified = models.DateTimeField(
        auto_now=True
    )  # Automatically updated when modified
    orsa_file = models.FileField(
        upload_to="orsa_setups/", null=True, blank=True
    )  # ORSA setup file

    def __str__(self):
        return self.setup_name

    class Meta:
        verbose_name_plural = "BudgetSetup"


# 3. Model for running the Model (with logging and fetching results)
class ModelRun(models.Model):
    model_name = models.CharField(max_length=100)  # Name of the model being run
    run_date = models.DateTimeField(auto_now_add=True)  # Date when the model was run
    input_parameters = (
        models.TextField()
    )  # Store input parameters (could be JSON or serialized data)
    Run_Nr = models.IntegerField(choices=YEAR_CHOICES, default=2024)  # Run number
    PrevRun_Nr = models.IntegerField(
        choices=YEAR_CHOICES, default=2024
    )  # Previous Run number
    NBRun_Nr = models.IntegerField(
        choices=YEAR_CHOICES, default=2024
    )  # New Business Run number
    status = models.CharField(
        max_length=50,
        choices=[
            ("pending", "Pending"),
            ("running", "Running"),
            ("completed", "Completed"),
            ("failed", "Failed"),
        ],
    )  # Run status
    result_file = models.FileField(
        upload_to="model_results/", null=True, blank=True
    )  # Store the result file (optional)
    error_message = models.TextField(
        null=True, blank=True
    )  # Capture any error messages if the run failed

    def __str__(self):
        return f"{self.model_name} run on {self.run_date.strftime('%Y-%m-%d')}"

    class Meta:
        verbose_name_plural = "ModelRun"


# 4. Model for storing logs of the ModelRun process
class RunLog(models.Model):
    model_run = models.ForeignKey(
        ModelRun, on_delete=models.CASCADE, related_name="logs"
    )  # Link logs to a specific model run
    log_entry = models.TextField()  # Detailed log entry
    timestamp = models.DateTimeField(auto_now_add=True)  # Log timestamp

    def __str__(self):
        return f"Log for {self.model_run.model_name} at {self.timestamp.strftime('%Y-%m-%d %H:%M:%S')}"

    class Meta:
        verbose_name_plural = "RunLog"


# # 5. Optional: Store calculation results in a structured format (if needed)
# class CalculationResult(models.Model):
#     model_run = models.OneToOneField(ModelRun, on_delete=models.CASCADE, related_name='result')  # Link the result to a model run
#     result_data = models.JSONField()  # Store calculation results as JSON
#     created_at = models.DateTimeField(auto_now_add=True)  # Timestamp of result creation

#     def __str__(self):
#         return f"Result for {self.model_run.model_name} - {self.created_at.strftime('%Y-%m-%d')}"
# models.py
from django.db import models
from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import ModelRun


@receiver(post_save, sender=ModelRun)
def auto_run_model(sender, instance, created, **kwargs):
    from .views import run_model2

    if created:
        # Trigger the model run automatically after creation
        run_model2(instance)


class CashflowVariables(models.Model):
    premiums = models.CharField(max_length=255, null=True, blank=True)
    claims = models.CharField(max_length=255, null=True, blank=True)
    admin = models.CharField(max_length=255, null=True, blank=True)
    acquisitions = models.CharField(max_length=255, null=True, blank=True)
    type = models.CharField(
        max_length=255,
        null=True,
        blank=True,
        choices=[
            ("Insurance", "Insurance"),
            ("Reinsurance", "Insurance"),
        ],
        default="Insurance",
    )

    def __str__(self):
        return f"{self.premiums} - {self.claims} - {self.admin} - {self.acquisitions} - {self.type}"
