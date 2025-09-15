import uuid
from django.db import models
from django.contrib.auth.models import User
from django.contrib.postgres.fields import JSONField

class TimeStampedModel(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        abstract = True

class Client(TimeStampedModel):
    name = models.CharField(max_length=200)
    code = models.CharField(max_length=50, unique=True)
    contact_email = models.EmailField(blank=True)

    def __str__(self):
        return self.name

class Project(TimeStampedModel):
    name = models.CharField(max_length=200)
    code = models.CharField(max_length=50, unique=True)
    client = models.ForeignKey(Client, related_name='projects', on_delete=models.PROTECT)
    description = models.TextField(blank=True)
    start_date = models.DateField(null=True, blank=True)
    end_date = models.DateField(null=True, blank=True)

    def __str__(self):
        return f"{self.code} – {self.name}"

class Document(TimeStampedModel):
    project = models.ForeignKey(Project, related_name='documents', on_delete=models.CASCADE)
    title = models.CharField(max_length=200)
    doc_type = models.CharField(max_length=50, blank=True)
    url = models.URLField(blank=True)

class ProjectUser(TimeStampedModel):
    project = models.ForeignKey(Project, related_name='project_users', on_delete=models.CASCADE)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    role = models.CharField(max_length=100)

# IFC hierarchy
class IfcProject(TimeStampedModel):
    project = models.OneToOneField(Project, related_name='ifc_project', on_delete=models.CASCADE)
    ifc_guid = models.CharField(max_length=64, blank=True)

class IfcSite(TimeStampedModel):
    ifc_project = models.ForeignKey(IfcProject, related_name='sites', on_delete=models.CASCADE)
    name = models.CharField(max_length=200)

class IfcBuilding(TimeStampedModel):
    site = models.ForeignKey(IfcSite, related_name='buildings', on_delete=models.CASCADE)
    name = models.CharField(max_length=200)

class IfcStorey(TimeStampedModel):
    building = models.ForeignKey(IfcBuilding, related_name='storeys', on_delete=models.CASCADE)
    elevation = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    name = models.CharField(max_length=200)

class IfcSpace(TimeStampedModel):
    storey = models.ForeignKey(IfcStorey, related_name='spaces', on_delete=models.CASCADE)
    name = models.CharField(max_length=200)
    number = models.CharField(max_length=50, blank=True)

class IfcElement(TimeStampedModel):
    space = models.ForeignKey(IfcSpace, related_name='elements', on_delete=models.CASCADE)
    category = models.CharField(max_length=100)
    type_name = models.CharField(max_length=200)

class IfcRelation(TimeStampedModel):
    element = models.ForeignKey(IfcElement, related_name='relations', on_delete=models.CASCADE)
    relation_type = models.CharField(max_length=100)
    target_guid = models.CharField(max_length=64)

# Lots → Prestations → Quantities
class Lot(TimeStampedModel):
    project = models.ForeignKey(Project, related_name='lots', on_delete=models.CASCADE)
    code = models.CharField(max_length=50)
    title = models.CharField(max_length=200)

class EnsemblePrestation(TimeStampedModel):
    lot = models.ForeignKey(Lot, related_name='ensembles', on_delete=models.CASCADE)
    title = models.CharField(max_length=200)

class Prestation(TimeStampedModel):
    ensemble = models.ForeignKey(EnsemblePrestation, related_name='prestations', on_delete=models.CASCADE)
    ref = models.CharField(max_length=100)
    description = models.TextField()
    unit = models.CharField(max_length=20, default='u')

class PrestationQty(TimeStampedModel):
    prestation = models.ForeignKey(Prestation, related_name='quantities', on_delete=models.CASCADE)
    qty = models.DecimalField(max_digits=18, decimal_places=3)
    source = models.CharField(max_length=100, blank=True)  # calcul, relevé, import IFC

# Audit trail
class AuditLog(TimeStampedModel):
    ACTION_CHOICES = (
        ('create', 'create'),
        ('update', 'update'),
        ('delete', 'delete'),
    )
    model = models.CharField(max_length=100)
    object_id = models.CharField(max_length=64)
    action = models.CharField(max_length=10, choices=ACTION_CHOICES)
    changes = models.JSONField(default=dict, blank=True)
    user = models.ForeignKey(User, null=True, blank=True, on_delete=models.SET_NULL)

    class Meta:
        ordering = ['-created_at']
