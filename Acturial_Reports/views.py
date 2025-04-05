from django.shortcuts import render
from .models import ActuarialReport


def actuarial_report_list(request):
    actuarial_reports = ActuarialReport.objects.all()
    return render(
        request, "actuarial_report_list.html", {"actuarial_reports": actuarial_reports}
    )
