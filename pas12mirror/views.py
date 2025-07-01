
import os
from django.http import JsonResponse
from django.shortcuts import render, get_object_or_404
from .models import *
import csv

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



from django.db.models import Sum
from homepage.models import Setup
import os
import csv
from django.http import JsonResponse
from django.views.decorators.clickjacking import xframe_options_exempt
from django.utils.timezone import now
from django.shortcuts import render
from .models import (
    CreditClient, CreditCollections, CreditClaim, CreditPolicy,
    FuneralClients, FuneralCollections, FuneralClaim,
    MotorClient, MotorCollections, MotorClaim, MotorMotorinsurance,
    HealthClient, HealthPayment, HealthClaim, HealthPolicy
)

@xframe_options_exempt
def pas12_summary_view(request):
    rows = []
    current_year = 2024  # Can be made dynamic if needed
    setup_instance = Setup.objects.last()


    # CREDIT LIFE SECTION
    credit_policies = CreditPolicy.objects.using('pas12').select_related('client').all()
    for policy in credit_policies:
        payments_past = CreditCollections.objects.using('pas12').filter(
            policy=policy, payment_date__year__lt=current_year
        ).aggregate(Sum('premium'))['premium__sum'] or 0

        payments_current = CreditCollections.objects.using('pas12').filter(
            policy=policy, payment_date__year=current_year
        ).aggregate(Sum('premium'))['premium__sum'] or 0

        claims_past = CreditClaim.objects.using('pas12').filter(
            policy=policy, claim_date__year__lt=current_year
        ).aggregate(Sum('claim_amount'))['claim_amount__sum'] or 0

        claims_current = CreditClaim.objects.using('pas12').filter(
            policy=policy, claim_date__year=current_year
        ).aggregate(Sum('claim_amount'))['claim_amount__sum'] or 0

        gic_code = policy.gic if hasattr(policy, 'gic') and policy.gic else 'GIC_DEFAULT'

        rows.append({
            'reporting_date': setup_instance.reporting_date_current if setup_instance else None,
            'gic_code': gic_code,
            'premiums_past': payments_past,
            'premiums_current': payments_current,
            'premium_receipts_future': 0,
            'acquisition_expense_past_current': 0,
            'acquisition_expense_future': 0,
            'investment_component_payments': 0,
            'claims_prior_periods': claims_past,
            'claims_current_period': claims_current,
            'insurance_type': 'Credit Life',
        })

    # FUNERAL SECTION
    funeral_clients = FuneralClients.objects.using('pas12').all()
    for client in funeral_clients:
        payments = FuneralCollections.objects.using('pas12').filter(
            client=client
        ).order_by('-payment_date')

        if payments:
            latest = payments[0]
            gic_code = latest.gic if hasattr(latest, 'gic') and latest.gic else '-'
            
            rows.append({
                'reporting_date': setup_instance.reporting_date_current if setup_instance else None,
                'gic_code': gic_code,
                'premiums_past': 0,
                'premiums_current': latest.payment_amount,
                'premium_receipts_future': 0,
                'acquisition_expense_past_current': 0,
                'acquisition_expense_future': 0,
                'investment_component_payments': 0,
                'claims_prior_periods': 0,
                'claims_current_period': 0,
                'insurance_type': 'Funeral',
            })
            if len(payments) > 1:
                previous = payments[1]
                gic_code = previous.gic if hasattr(previous, 'gic') and previous.gic else '-'
                
                rows.append({
                    'reporting_date': setup_instance.reporting_date_current if setup_instance else None,
                    'gic_code': gic_code,
                    'premiums_past': previous.payment_amount,
                    'premiums_current': 0,
                    'premium_receipts_future': 0,
                    'acquisition_expense_past_current': 0,
                    'acquisition_expense_future': 0,
                    'investment_component_payments': 0,
                    'claims_prior_periods': 0,
                    'claims_current_period': 0,
                    'insurance_type': 'Funeral',
                })

        claims = FuneralClaim.objects.using('pas12').filter(
            client=client
        ).order_by('-claim_date')

        if claims:
            latest = claims[0]
            gic_code = latest.gic if hasattr(latest, 'gic') and latest.gic else '-'
            
            rows.append({
                'reporting_date': setup_instance.reporting_date_current if setup_instance else None,
                'gic_code': gic_code,
                'premiums_past': 0,
                'premiums_current': 0,
                'premium_receipts_future': 0,
                'acquisition_expense_past_current': 0,
                'acquisition_expense_future': 0,
                'investment_component_payments': 0,
                'claims_prior_periods': 0,
                'claims_current_period': latest.claim_amount if latest.claim_amount else 0,
                'insurance_type': 'Funeral',
            })
            if len(claims) > 1:
                previous = claims[1]
                gic_code = previous.gic if hasattr(previous, 'gic') and previous.gic else '-'
                
                rows.append({
                    'reporting_date': setup_instance.reporting_date_current if setup_instance else None,
                    'gic_code': gic_code,
                    'premiums_past': 0,
                    'premiums_current': 0,
                    'premium_receipts_future': 0,
                    'acquisition_expense_past_current': 0,
                    'acquisition_expense_future': 0,
                    'investment_component_payments': 0,
                    'claims_prior_periods': previous.claim_amount if previous.claim_amount else 0,
                    'claims_current_period': 0,
                    'insurance_type': 'Funeral',
                })

    # MOTOR SECTION
    motor_policies = MotorMotorinsurance.objects.using('pas12').select_related('client').all()
    for policy in motor_policies:
        payments_past = MotorCollections.objects.using('pas12').filter(
            client=policy.client, payment_date__year__lt=current_year
        ).aggregate(Sum('payment_amount'))['payment_amount__sum'] or 0

        payments_current = MotorCollections.objects.using('pas12').filter(
            client=policy.client, payment_date__year=current_year
        ).aggregate(Sum('payment_amount'))['payment_amount__sum'] or 0

        claims_past = MotorClaim.objects.using('pas12').filter(
            client=policy.client, claim_date__year__lt=current_year
        ).aggregate(Sum('claim_amount'))['claim_amount__sum'] or 0

        claims_current = MotorClaim.objects.using('pas12').filter(
            client=policy.client, claim_date__year=current_year
        ).aggregate(Sum('claim_amount'))['claim_amount__sum'] or 0

        # Get GIC from collections or claims if available
        gic_code = 'GIC_DEFAULT'
        latest_collection = MotorCollections.objects.using('pas12').filter(
            client=policy.client
        ).order_by('-payment_date').first()
        if latest_collection and hasattr(latest_collection, 'gic') and latest_collection.gic:
            gic_code = latest_collection.gic
        
        latest_claim = MotorClaim.objects.using('pas12').filter(
            client=policy.client
        ).order_by('-claim_date').first()
        if latest_claim and hasattr(latest_claim, 'gic') and latest_claim.gic:
            gic_code = latest_claim.gic

        rows.append({
            'reporting_date': setup_instance.reporting_date_current if setup_instance else None,
            'gic_code': gic_code,
            'premiums_past': payments_past,
            'premiums_current': payments_current,
            'premium_receipts_future': 0,
            'acquisition_expense_past_current': 0,
            'acquisition_expense_future': 0,
            'investment_component_payments': 0,
            'claims_prior_periods': claims_past,
            'claims_current_period': claims_current,
            'insurance_type': 'Motor',
        })

    # HEALTH SECTION
    health_policies = HealthPolicy.objects.using('pas12').select_related('client').all()
    for policy in health_policies:
        payments_past = HealthPayment.objects.using('pas12').filter(
            policy=policy, payment_date__year__lt=current_year
        ).aggregate(Sum('amount'))['amount__sum'] or 0

        payments_current = HealthPayment.objects.using('pas12').filter(
            policy=policy, payment_date__year=current_year
        ).aggregate(Sum('amount'))['amount__sum'] or 0

        claims_past = HealthClaim.objects.using('pas12').filter(
            policy=policy, claim_date__year__lt=current_year
        ).aggregate(Sum('claim_amount'))['claim_amount__sum'] or 0

        claims_current = HealthClaim.objects.using('pas12').filter(
            policy=policy, claim_date__year=current_year
        ).aggregate(Sum('claim_amount'))['claim_amount__sum'] or 0

        # Get GIC from claims if available
        gic_code = 'GIC_DEFAULT'
        latest_claim = HealthClaim.objects.using('pas12').filter(
            policy=policy
        ).order_by('-claim_date').first()
        if latest_claim and hasattr(latest_claim, 'gic') and latest_claim.gic:
            gic_code = latest_claim.gic

        rows.append({
            'reporting_date': setup_instance.reporting_date_current if setup_instance else None,
            'gic_code': gic_code,
            'premiums_past': payments_past,
            'premiums_current': payments_current,
            'premium_receipts_future': 0,
            'acquisition_expense_past_current': 0,
            'acquisition_expense_future': 0,
            'investment_component_payments': 0,
            'claims_prior_periods': claims_past,
            'claims_current_period': claims_current,
            'insurance_type': 'Health',
        })

    # Define CSV file path - saving to desktop
    desktop_path = os.path.join(os.path.expanduser('~'), 'Desktop')
    csv_filename = 'pas12_summary.csv'
    csv_file_path = os.path.join(desktop_path, csv_filename)
    
    # Ensure directory exists
    os.makedirs(desktop_path, exist_ok=True)

    # Save to CSV file
    try:
        with open(csv_file_path, 'w', newline='', encoding='utf-8') as csvfile:
            fieldnames = [
                'reporting_date', 'gic_code', 
                'premiums_past', 'premiums_current', 'premium_receipts_future',
                'acquisition_expense_past_current', 'acquisition_expense_future',
                'investment_component_payments',
                'claims_prior_periods', 'claims_current_period',
                'insurance_type'
            ]
            writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
            
            writer.writeheader()
            for row in rows:
                writer.writerow(row)
        
        file_created = os.path.exists(csv_file_path)
    except Exception as e:
        file_created = False
        error_message = str(e)

    # Prepare response
    context = {
        'data': rows,
        'current_year': current_year,
        'csv_generated': file_created,
        'csv_file_path': csv_file_path,
        'generated_at': now().strftime("%Y-%m-%d %H:%M:%S")
    }

    if not file_created:
        context['error_message'] = error_message
        return render(request, 'pas12_error.html', context)

    if request.headers.get('x-requested-with') == 'XMLHttpRequest' or request.GET.get('format') == 'json':
        return JsonResponse(rows, safe=False)

    return render(request, 'pas12_summary.html', context)