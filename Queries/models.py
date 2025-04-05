from django.db import models

# Create your models here.
from django.db import models


class UserQuery(models.Model):
    user = models.CharField(
        max_length=100
    )  # Optional: Replace with a ForeignKey to User model if you have one
    query_description = models.TextField()
    screenshot = models.ImageField(
        upload_to="user_queries/screenshots/", blank=True, null=True
    )
    submitted_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Query by {self.user} on {self.submitted_at}"


class DeveloperResponse(models.Model):
    user_query = models.ForeignKey(
        UserQuery, on_delete=models.CASCADE, related_name="responses"
    )
    response_description = models.TextField()
    screenshot = models.ImageField(
        upload_to="developer_responses/screenshots/", blank=True, null=True
    )
    responded_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Response to {self.user_query} on {self.responded_at}"
