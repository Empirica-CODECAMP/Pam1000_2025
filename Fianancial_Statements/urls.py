from django.urls import path
from . import views

urlpatterns = [
    path("fetch-trial-balance/", views.fetch_trial_balance, name="fetch_trial_balance"),
    path("fetch-subledger/", views.fetch_subledger, name="fetch_subledger"),
]
