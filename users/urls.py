from django.urls import path
from .views import import_files_view, insurance_data, reinsurance_data, curves_data

urlpatterns = [
    path("import-files/", import_files_view, name="import_files_page"),
    path("insurance-data/", insurance_data, name="insurance_data"),
    path("reinsurance-data/", reinsurance_data, name="reinsurance_data"),
    path("curves-data/", curves_data, name="curves_data"),
]
