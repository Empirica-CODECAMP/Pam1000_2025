from django.db import models

# Create your models here.


class ActuarialReport(models.Model):
    title = models.CharField(max_length=255)
    description = models.TextField(blank=True, null=True)
    file = models.FileField(upload_to="actuarial_reports/")
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.title


# @auto-update
# ActuarialReport:
#     for files in self.file:
#     if self.file in "media/Rscript/Output":
#         os.listfiles("media/Rscript/Output")
#         ActuarialReport(update)
#         time.sleep(10)
