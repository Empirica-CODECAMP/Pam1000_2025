# Generated by Django 5.0.6 on 2024-10-15 13:48

from django.db import migrations, models


class Migration(migrations.Migration):
    initial = True

    dependencies = []

    operations = [
        migrations.CreateModel(
            name="ActuarialReport",
            fields=[
                (
                    "id",
                    models.BigAutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                ("title", models.CharField(max_length=255)),
                ("description", models.TextField(blank=True, null=True)),
                ("file", models.FileField(upload_to="actuarial_reports/")),
                ("created_at", models.DateTimeField(auto_now_add=True)),
            ],
        ),
    ]
