from django.shortcuts import render

# Create your views here.

from django.shortcuts import render, redirect
from .models import Portfolio


def add_portfolio(request):
    if request.method == "POST":
        name = request.POST["name"]
        code = request.POST["code"]
        Portfolio.objects.create(name=name, code=code)
        return redirect("portfolio_list")
    return render(request, "add_portfolio.html")


import rpy2.robjects as ro


def run_gmm_model(request):
    portfolio_id = request.POST["portfolio_id"]
    portfolio = Portfolio.objects.get(id=portfolio_id)
    r = ro.r
    # Execute R script with necessary inputs
    r(f'run_gmm("{portfolio.name}")')  # Example: passing portfolio name as argument
    return redirect("results")


from rest_framework.response import Response
from rest_framework.decorators import api_view
from .models import Portfolio
from .serializers import PortfolioSerializer


@api_view(["GET"])
def portfolio_list(request):
    portfolios = Portfolio.objects.all()
    serializer = PortfolioSerializer(portfolios, many=True)
    return Response(serializer.data)
