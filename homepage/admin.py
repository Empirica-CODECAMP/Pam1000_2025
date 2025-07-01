from django.contrib import admin

# Register your models here.
from .models import SetupInput,Setup,InputUpload

@admin.register(SetupInput)
class SetupInputAdmin(admin.ModelAdmin):
    list_display = ['date', 'rfr_pc', 'setup']
    # Add filters, search fields, etc. if needed
admin.site.register(Setup)

 

@admin.register(InputUpload)
class InputUploadAdmin(admin.ModelAdmin):
    list_display = ['category','input_type', 'date', 'file', 'uploaded_at']
    list_filter = ['input_type', 'date','category']
    search_fields = ['input_type']