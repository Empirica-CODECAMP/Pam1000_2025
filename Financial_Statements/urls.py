from django.urls import path
from . import views

urlpatterns = [
    path('', views.ecl_landing, name='ecl_landing'),
]
