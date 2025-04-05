from django.shortcuts import render

# Create your views here.
from django.http import JsonResponse


def fetch_trial_balance(request):
    # Logic to fetch the Trial Balance Excel
    data = {
        "title": "Trial Balance",
        "file_url": "/path/to/trial_balance.xlsx",
    }
    return JsonResponse(data)


def fetch_subledger(request):
    # Logic to fetch the Subledger Excel
    data = {
        "title": "Subledger",
        "file_url": "/path/to/subledger.xlsx",
    }
    return JsonResponse(data)
