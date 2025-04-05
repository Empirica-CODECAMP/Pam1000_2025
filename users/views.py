from django.core import serializers
from django.shortcuts import render
from django.http import HttpResponseBadRequest, JsonResponse
import pandas as pd
import re
from .models import (
    Insurance,
    Portfolio,
    Reinsurance,
    Curves,
)  # Make sure to import the Portfolio model
from django.contrib import messages


def import_files_view(request):
    if request.method == "GET":
        # Fetch all portfolio names from the database
        portfolios = Portfolio.objects.all()
        portfolio_list = [portfolio.name for portfolio in portfolios]

        return render(request, "import_files.html", {"portfolios": portfolio_list})

    elif request.method == "POST":
        # Handling file uploads
        file = request.FILES.get("file")
        if not file or not file.name.endswith(".xlsx"):
            return HttpResponseBadRequest("Please upload a valid Excel file.")

        type = request.POST.get("type")  # Get the selected type from the form
        selected_portfolio = request.POST.get(
            "portfolio"
        )  # Get the selected portfolio from the form

        # Get the portfolio object from the database
        try:
            portfolio_instance = Portfolio.objects.get(name=selected_portfolio)
        except Portfolio.DoesNotExist:
            return HttpResponseBadRequest("Selected portfolio not found in the list.")

        # Load the Excel file and process it
        df = pd.ExcelFile(file)

        # Regex pattern to match sheet names with a four-digit year and group (Onerous, Non-onerous, or Remaining)
        pattern = r"(?i)(\d{4})\s*(Onerous|Non-onerous|Remaining|ODD)?"

        # Process matching sheets
        for sheet in df.sheet_names:
            match = re.search(pattern, sheet)
            if match:
                year = match.group(1)  # Extract the year
                group = match.group(
                    2
                ).lower()  # Extract the group and convert to lower case

                # Read the sheet into a DataFrame, skipping the first 3 rows
                data = pd.read_excel(file, sheet_name=sheet, skiprows=3)

                # Trim columns to exclude the first column (if necessary)
                data = data[data.columns[1:]]

                # Add necessary columns
                data["id"] = None
                data["year"] = year  # Assign the extracted year
                data["type"] = type  # Assign the provided type from the form
                data["group"] = group  # Assign the extracted group

                # Create instances of the Insurance model and save them to the database
                for index, row in data.iterrows():
                    insurance_instance = Insurance(
                        id=row["id"],
                        year=row["year"],
                        type=row["type"],
                        group=row["group"],
                        portfolio=portfolio_instance,  # Assign the Portfolio instance
                        time=row.get("Time"),  # Safely access the 'Time' column
                        PREM_INC=row.get("PREM_INC"),
                        DEATH_OUTGO=row.get("DEATH_OUTGO"),
                        DISAB_OUTGO=row.get("DISAB_OUTGO"),
                        INIT_EXP=row.get("INIT_EXP"),
                        REN_EXP=row.get("REN_EXP"),
                        INIT_COMM=row.get("INIT_COMM"),
                        REN_COMM=row.get("REN_COMM"),
                        PHIBEN_OUTGO=row.get("PHIBEN_OUTGO"),
                        PHIBEN_OUTGO_BLL=row.get("PHIBEN_OUTGO_BLL"),
                        CR_BEN_OUTGO=row.get("CR_BEN_OUTGO"),
                        RETR_OUTGO=row.get("RETR_OUTGO"),
                        DTH_OUTGO=row.get("DTH_OUTGO"),
                        DREADDIS_OUTGO=row.get("DREADDIS_OUTGO"),
                        TEMPDIS_OUTGO=row.get("TEMPDIS_OUTGO"),
                        RIDERC_OUTGO=row.get("RIDERC_OUTGO"),
                        RISK_ADJ=row.get("RISK_ADJ"),
                        COVERAGE_UNITS=row.get("COVERAGE_UNITS"),
                    )
                    insurance_instance.save()  # Save the instance to the database
                print(f"Data imported successfully from {sheet}!")
                messages.success(request, f"Data imported successfully from {sheet}!")
            else:
                print(f"No match found for sheet: {sheet}")

        # Render the HTML template with portfolio list after the import
        portfolios = Portfolio.objects.all()
        portfolio_list = [portfolio.name for portfolio in portfolios]

        return render(request, "import_files.html", {"portfolios": portfolio_list})

    return HttpResponseBadRequest("Invalid request method.")


def insurance_data(request):
    if request.method == "POST":
        year = request.POST.get("year")
        type = request.POST.get("type")
        group = request.POST.get("group")
        portfolio = request.POST.get("portfolio")

        # Fetch filtered data
        data = Insurance.objects.filter(
            year=year, type=type, group=group, portfolio=portfolio
        ).values()  # Use values to get a list of dictionaries

        return JsonResponse(list(data), safe=False, status=200)

    elif request.method == "GET":
        data = Insurance.objects.all().values()  # Use values here as well

        return JsonResponse(list(data), safe=False, status=200)

    else:
        return JsonResponse({"error": "Method not allowed"}, status=405)


def reinsurance_data(request):
    if request.method == "POST":
        year = request.POST.get("year")
        type = request.POST.get("type")
        group = request.POST.get("group")
        portfolio = request.POST.get("portfolio")

        # Fetch filtered data
        data = Reinsurance.objects.filter(
            year=year, type=type, group=group, portfolio=portfolio
        ).values()  # Use values to get a list of dictionaries

        return JsonResponse(list(data), safe=False, status=200)

    elif request.method == "GET":
        data = Reinsurance.objects.all().values()  # Use values here as well

        return JsonResponse(list(data), safe=False, status=200)

    else:
        return JsonResponse({"error": "Method not allowed"}, status=405)


def curves_data(request):
    if request.method == "POST":
        year = request.POST.get("year")
        type = request.POST.get("type")
        group = request.POST.get("group")
        portfolio = request.POST.get("portfolio")

        # Fetch filtered data
        data = Curves.objects.filter(
            year=year, type=type, group=group, portfolio=portfolio
        ).values()  # Use values to get a list of dictionaries

        return JsonResponse(list(data), safe=False, status=200)

    elif request.method == "GET":
        data = Curves.objects.all().values()  # Use values here as well

        return JsonResponse(list(data), safe=False, status=200)

    else:
        return JsonResponse({"error": "Method not allowed"}, status=405)


def index(request):
    return render(request, "index.html")
