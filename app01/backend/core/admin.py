from django.contrib import admin
from . import models as m

# Register all models quickly
for mdl in [
    m.Client, m.Project, m.Document, m.ProjectUser,
    m.IfcProject, m.IfcSite, m.IfcBuilding, m.IfcStorey, m.IfcSpace, m.IfcElement, m.IfcRelation,
    m.Lot, m.EnsemblePrestation, m.Prestation, m.PrestationQty,
]:
    admin.site.register(mdl)
