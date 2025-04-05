from django import forms
from .models import ModelRun


class ModelRunForm(forms.ModelForm):
    class Meta:
        model = ModelRun
        fields = ["model_name", "Run_Nr", "PrevRun_Nr", "NBRun_Nr"]
