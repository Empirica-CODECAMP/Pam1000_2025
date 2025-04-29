
from django.shortcuts import render, get_object_or_404
from .models import *
def home(request):
    return render(request, 'home.html')
def base(request):
    return render(request, 'pas12_base.html')

# Credit Views
def credit_claim_list(request):
    claims = CreditClaim.objects.using('pas12').select_related('policy').all()
    return render(request, 'credit/claim_list.html', {'claims': claims})

def credit_claim_detail(request, pk):
    claim = get_object_or_404(CreditClaim.objects.using('pas12'), pk=pk)
    return render(request, 'credit/claim_detail.html', {'claim': claim})

# def credit_client_list(request):
#     clients = CreditClient.objects.using('pas12').all()
#     return render(request, 'credit/client_list.html', {'clients': clients})
from django.core.paginator import Paginator

def credit_client_list(request):
    client_list = CreditClient.objects.using('pas12').all().order_by('surname')
    paginator = Paginator(client_list, 25)  # Show 25 clients per page
    
    page_number = request.GET.get('page')
    page_obj = paginator.get_page(page_number)
    
    return render(request, 'credit/client_list.html', {
        'clients': page_obj,
        'page_obj': page_obj,
        'is_paginated': True,
        
    })

def credit_client_detail(request, pk):
    client = get_object_or_404(CreditClient.objects.using('pas12'), pk=pk)
    return render(request, 'credit/client_detail.html', {'client': client})

def credit_collections_list(request):
    collections = CreditCollections.objects.using('pas12').select_related('policy').all()
    return render(request, 'credit/collections_list.html', {'collections': collections})

def credit_policy_list(request):
    policies = CreditPolicy.objects.using('pas12').select_related('client', 'insurer').all()
    return render(request, 'credit/policy_list.html', {'policies': policies})

def credit_policy_detail(request, pk):
    policy = get_object_or_404(CreditPolicy.objects.using('pas12'), pk=pk)
    return render(request, 'credit/policy_detail.html', {'policy': policy})

# Customer Support Views
def customer_support_claimform_list(request):
    claimforms = CustomersupportClaimform.objects.all()
    return render(request, 'customer_support/claimform_list.html', {'claimforms': claimforms})

def customer_support_complaint_list(request):
    complaints = CustomersupportComplaint.objects.all()
    return render(request, 'customer_support/complaint_list.html', {'complaints': complaints})