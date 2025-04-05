from django.urls import path
from .views import *

urlpatterns = [
    path("runsettings/", runsettings, name="runsettings"),
    path("variables/", variables, name="variables"),
    path("", main_page, name="main_page"),
    path("insurance_variables/", insurance_variables, name="insurance_variables"),
    path("reinsurance_variables/", reinsurance_variables, name="reinsurance_variables"),
]
