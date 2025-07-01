# pas/forms.py
from django import forms
from .models import Setup, SetupInput, InputUpload

class SetupForm(forms.ModelForm):
    class Meta:
        model = Setup
        fields = '__all__'
        widgets = {
            'reporting_date_previous': forms.DateInput(attrs={'type': 'date'}),
            'reporting_date_current': forms.DateInput(attrs={'type': 'date'}),
            'date': forms.DateInput(attrs={'type': 'date'}),
            'insurance_contracts': forms.Select(choices=[(True, 'Yes'), (False, 'No')]),
            'reinsurance_contracts': forms.Select(choices=[(True, 'Yes'), (False, 'No')]),
            'insurance_new_business': forms.Select(choices=[(True, 'Yes'), (False, 'No')]),
            'reinsurance_new_business': forms.Select(choices=[(True, 'Yes'), (False, 'No')]),
            'foreign_currency_needed': forms.Select(choices=[(True, 'Yes'), (False, 'No')]),
            'linked_cashflows': forms.Select(choices=[(True, 'Yes'), (False, 'No')]),
            'dependent_cashflows': forms.Select(choices=[(True, 'Yes'), (False, 'No')]),
            'loss_components': forms.Select(choices=[(True, 'Yes'), (False, 'No')]),
            'gic_external_model': forms.Select(choices=[(True, 'Yes'), (False, 'No')]),
            'disaggregate_change': forms.Select(choices=[(True, 'Yes'), (False, 'No')]),
            'simplify_ra': forms.Select(choices=[(True, 'Yes'), (False, 'No')]),
            'discount_csm': forms.Select(choices=[(True, 'Yes'), (False, 'No')]),
            'discount_acquisition_flows': forms.Select(choices=[(True, 'Yes'), (False, 'No')]),
            'granular_yield': forms.Select(choices=[(True, 'Yes'), (False, 'No')]),

        }

class SetupInputForm(forms.ModelForm):
    class Meta:
        model = SetupInput
        fields = ['date', 'rfr_pc', 'setup']
        widgets = {
            'date': forms.DateInput(attrs={'type': 'date'}),
            'rfr_pc': forms.ClearableFileInput(),
        }

class InputUploadForm(forms.ModelForm):
    
    class Meta:
        model = InputUpload
        fields = ['category','input_type', 'date', 'file']
        widgets = {
            'date': forms.DateInput(attrs={'type': 'date'}),
        }