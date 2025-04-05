from django.shortcuts import render
from .models import (
    RunSettings,
    InsuranceCashflowVariables,
    ReinsuranceCashflowVariables,
)
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt


# Create your views here.
@csrf_exempt
def runsettings(request):
    # Retrieve all RunSettings objects
    data = RunSettings.objects.all()

    # Convert queryset to a list of dictionaries
    data_list = list(
        data.values()
    )  # This creates a list of dictionaries where each dictionary represents a RunSettings instance

    return JsonResponse(
        data_list, safe=False
    )  # Set safe=False to allow returning a list


from django.shortcuts import render, redirect
from .forms import InsuranceVariablesForm, ReinsuranceVariablesForm

from django.contrib import messages
import logging

# Set up logging
logger = logging.getLogger(__name__)


def variables(request):
    if request.method == "POST":
        # Handle the form submission for insurance or reinsurance data
        insurance_form = InsuranceVariablesForm(request.POST, prefix="insurance")
        reinsurance_form = ReinsuranceVariablesForm(request.POST, prefix="reinsurance")

        # Initialize form submission flag
        form_valid = True

        # Validate and save insurance form
        if insurance_form.is_valid():
            try:
                insurance_form.save()  # Save the new insurance data to the database
                messages.success(request, "Insurance data saved successfully!")
            except Exception as e:
                form_valid = False
                print(f"Error saving insurance data: {str(e)}")
                messages.error(request, f"Error saving insurance data: {str(e)}")
        else:
            form_valid = False
            print(f"Insurance form errors: {insurance_form.errors}")
            messages.error(request, f"Insurance form errors: {insurance_form.errors}")

        # Validate and save reinsurance form
        if reinsurance_form.is_valid():
            try:
                reinsurance_form.save()  # Save the new reinsurance data to the database
                messages.success(request, "Reinsurance data saved successfully!")
            except Exception as e:
                form_valid = False
                print(f"Error saving reinsurance data: {str(e)}")
                messages.error(request, f"Error saving reinsurance data: {str(e)}")
        else:
            form_valid = False
            print(f"Reinsurance form errors: {reinsurance_form.errors}")
            messages.error(
                request, f"Reinsurance form errors: {reinsurance_form.errors}"
            )

        # Redirect to the same page if both forms are valid or after logging the errors
        if form_valid:
            return redirect("variables")

    # If GET request, fetch the data and display forms
    ins_var = insurance_variables(request)
    reins_var = reinsurance_variables(request)

    # Create empty forms to display on GET request
    insurance_form = InsuranceVariablesForm(prefix="insurance")
    reinsurance_form = ReinsuranceVariablesForm(prefix="reinsurance")

    return render(
        request,
        "variables.html",
        {
            "insurance_variables": ins_var,
            "reinsurance_variables": reins_var,
            "insurance_form": insurance_form,
            "reinsurance_form": reinsurance_form,
        },
    )


def insurance_variables(request):
    data = InsuranceCashflowVariables.objects.all()
    # Convert queryset to a list of dictionaries
    data_list = list(
        data.values()
    )  # This creates a list of dictionaries where each dictionary represents a RunSettings instance

    return JsonResponse(
        data_list, safe=False
    )  # Set safe=False to allow returning a list


def reinsurance_variables(request):
    data = ReinsuranceCashflowVariables.objects.all()
    # Convert queryset to a list of dictionaries
    data_list = list(
        data.values()
    )  # This creates a list of dictionaries where each dictionary represents a RunSettings instance

    return JsonResponse(
        data_list, safe=False
    )  # Set safe=False to allow returning a list


def main_page(request):
    return render(request, "main.html")
