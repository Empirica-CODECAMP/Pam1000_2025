from django.urls import path
from . import views

urlpatterns = [
    
        path('home/', views.home, name='pas12_home'),


    path('base',views.base, name='pas12_base'),
    # Credit URLs
    path('credit/claims/', views.credit_claim_list, name='credit_claim_list'),
    path('credit/claims/<int:pk>/', views.credit_claim_detail, name='credit_claim_detail'),
    path('credit/clients/', views.credit_client_list, name='credit_client_list'),
    path('credit/clients/<int:pk>/', views.credit_client_detail, name='credit_client_detail'),
    path('credit/collections/', views.credit_collections_list, name='credit_collections_list'),
    path('credit/policies/', views.credit_policy_list, name='credit_policy_list'),
    path('credit/policies/<int:pk>/', views.credit_policy_detail, name='credit_policy_detail'),
]