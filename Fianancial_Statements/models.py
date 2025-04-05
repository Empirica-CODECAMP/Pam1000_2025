from django.db import models


class Subledger(models.Model):
    title = models.CharField(max_length=255)
    subledger_file = models.FileField(upload_to="financial_statements/subledgers/")
    # trial_balance_file = models.FileField(upload_to='financial_statements/trial_balances/')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.title


class TrialBalance(models.Model):
    title = models.CharField(max_length=255)
    # subledger_file = models.FileField(upload_to='financial_statements/subledgers/')
    trial_balance_file = models.FileField(
        upload_to="financial_statements/trial_balances/"
    )
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.title
