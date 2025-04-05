# calculations/urls.py

from django.urls import path
from . import views

urlpatterns = [
    path("run-ifrs17-model/", views.run_ifrs17_model, name="run_ifrs17_model"),
    path("run_model/", views.run_model, name="run_model"),
    path("model_run_status/<int:pk>/", views.model_run_status, name="model_run_status"),
    path(
        "fcf_vars/", views.fcf_vars_page, name="fcf_vars_page"
    ),  # For rendering the HTML
    path(
        "fcf_vars/api", views.fcf_vars_api, name="fcf_vars_api"
    ),  # For CRUD operations     # This should be defined
]
