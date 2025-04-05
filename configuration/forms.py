from django import forms
from .models import InsuranceCashflowVariables, ReinsuranceCashflowVariables


class InsuranceVariablesForm(forms.ModelForm):
    premium = forms.CharField(required=False)
    claims = forms.CharField(required=False)
    admin = forms.CharField(required=False)
    acquisition = forms.CharField(required=False)

    class Meta:
        model = InsuranceCashflowVariables
        fields = [
            "premium",
            "claims",
            "admin",
            "acquisition",
        ]  # Include the fields you want to update


class ReinsuranceVariablesForm(forms.ModelForm):
    premium = forms.CharField(required=False)
    claims = forms.CharField(required=False)
    admin = forms.CharField(required=False)
    acquisition = forms.CharField(required=False)

    class Meta:
        model = ReinsuranceCashflowVariables
        fields = [
            "premium",
            "claims",
            "admin",
            "acquisition",
        ]  # Include the fields you want to update
