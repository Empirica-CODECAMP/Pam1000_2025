from django.db import models

from django.contrib.auth.models import User


class Calculation(models.Model):
    name = models.CharField(max_length=200)  # Name of the calculation
    parameters = models.JSONField()  # Parameters for the model run
    run_date = models.DateTimeField(
        auto_now_add=True
    )  # Date and time when the calculation was run
    result = (
        models.TextField()
    )  # Calculation result (if textual) or link to a file if necessary

    def __str__(self):
        return self.name


class Query(models.Model):
    user = models.ForeignKey(
        User, on_delete=models.CASCADE
    )  # Assuming you're using Django's User model
    query_text = models.TextField()  # The actual query
    response_text = models.TextField(null=True, blank=True)  # Developer's response
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Query by {self.user.username}"


class Organise(models.Model):
    report_name = models.CharField(max_length=200)  # Name of the report/data
    fetch_date = models.DateTimeField(auto_now_add=True)  # When the data was fetched
    status = models.CharField(max_length=100)  # Status, e.g., 'Fetched', 'Pending'

    def __str__(self):
        return self.report_name


class Result(models.Model):
    result_name = models.CharField(max_length=200)
    result_data = models.JSONField()  # Storing results in JSON format
    report_link = models.URLField(null=True, blank=True)  # Link to download reports

    def __str__(self):
        return self.result_name


class ActuarialReport(models.Model):
    report_name = models.CharField(max_length=200)
    report_file = models.FileField(
        upload_to="reports/"
    )  # Upload the actual report file
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.report_name


class FinancialStatement(models.Model):
    name = models.CharField(max_length=200)  # e.g., Trial Balance, Subledger, etc.
    year = models.IntegerField()  # Year of the statement
    statement_file = models.FileField(
        upload_to="financial_statements/"
    )  # Upload path for the statement file
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.name} - {self.year}"
