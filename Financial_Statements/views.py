# ecl_calculations/views.py
from django.shortcuts import render
from .models import (
    ECLReport, 
    StageAllocationReport, 
    LossAllowance, 
    CreditRiskExposure,
)

    
def ecl_landing(request):
    context = {
        "ecl_reports": ECLReport.objects.all(),
        "stage_allocations": StageAllocationReport.objects.all(),
        "loss_allowances": LossAllowance.objects.all(),
        "credit_exposures": CreditRiskExposure.objects.all(),
    }
    return render(request, "ecl.html", context)

