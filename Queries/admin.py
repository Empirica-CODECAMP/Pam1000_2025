from django.contrib import admin

# Register your models here.
from django.contrib import admin
from .models import UserQuery, DeveloperResponse


@admin.register(UserQuery)
class UserQueryAdmin(admin.ModelAdmin):
    list_display = ("user", "submitted_at")
    search_fields = ("user", "query_description")
    readonly_fields = ("submitted_at",)
    list_filter = ("submitted_at",)


@admin.register(DeveloperResponse)
class DeveloperResponseAdmin(admin.ModelAdmin):
    list_display = ("user_query", "responded_at")
    search_fields = ("user_query__query_description", "response_description")
    readonly_fields = ("responded_at",)
    list_filter = ("responded_at",)
