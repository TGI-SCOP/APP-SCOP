from rest_framework import viewsets, filters
from rest_framework.response import Response
from rest_framework.decorators import action
from django_filters.rest_framework import DjangoFilterBackend
from . import models as m
from . import serializers as s

class BaseViewSet(viewsets.ModelViewSet):
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]

    def _log(self, request, instance, action):
        try:
            # Collect changed fields if update
            changes = {}
            if action == 'update' and hasattr(instance, 'get_deferred_fields'):
                pass
            m.AuditLog.objects.create(
                model=instance.__class__.__name__,
                object_id=str(getattr(instance, 'id', '')),
                action=action,
                changes=changes,
                user=request.user if request and request.user.is_authenticated else None,
            )
        except Exception:
            # Ne bloque jamais la requête si la journalisation échoue
            pass

    def perform_create(self, serializer):
        instance = serializer.save()
        request = getattr(self, 'request', None)
        self._log(request, instance, 'create')

    def perform_update(self, serializer):
        instance = serializer.save()
        request = getattr(self, 'request', None)
        self._log(request, instance, 'update')

    def perform_destroy(self, instance):
        request = getattr(self, 'request', None)
        self._log(request, instance, 'delete')
        instance.delete()

class ClientViewSet(BaseViewSet):
    queryset = m.Client.objects.all().order_by('name')
    serializer_class = s.ClientSerializer
    search_fields = ['name', 'code']

class ProjectViewSet(BaseViewSet):
    queryset = m.Project.objects.select_related('client').all().order_by('code')
    serializer_class = s.ProjectSerializer
    search_fields = ['name', 'code', 'client__name']
    ordering_fields = ['code', 'name', 'start_date', 'end_date']
    filter_backends = BaseViewSet.filter_backends + [DjangoFilterBackend]
    filterset_fields = {
        'client': ['exact'],
        'code': ['exact', 'icontains'],
    }

class DocumentViewSet(BaseViewSet):
    queryset = m.Document.objects.select_related('project').all()
    serializer_class = s.DocumentSerializer
    search_fields = ['title', 'doc_type', 'project__code']

class ProjectUserViewSet(BaseViewSet):
    queryset = m.ProjectUser.objects.select_related('project', 'user').all()
    serializer_class = s.ProjectUserSerializer

# IFC viewsets
class IfcProjectViewSet(BaseViewSet):
    queryset = m.IfcProject.objects.select_related('project').all()
    serializer_class = s.IfcProjectSerializer

class IfcSiteViewSet(BaseViewSet):
    queryset = m.IfcSite.objects.select_related('ifc_project').all()
    serializer_class = s.IfcSiteSerializer

class IfcBuildingViewSet(BaseViewSet):
    queryset = m.IfcBuilding.objects.select_related('site').all()
    serializer_class = s.IfcBuildingSerializer

class IfcStoreyViewSet(BaseViewSet):
    queryset = m.IfcStorey.objects.select_related('building').all()
    serializer_class = s.IfcStoreySerializer

class IfcSpaceViewSet(BaseViewSet):
    queryset = m.IfcSpace.objects.select_related('storey').all()
    serializer_class = s.IfcSpaceSerializer

class IfcElementViewSet(BaseViewSet):
    queryset = m.IfcElement.objects.select_related('space').all()
    serializer_class = s.IfcElementSerializer

class IfcRelationViewSet(BaseViewSet):
    queryset = m.IfcRelation.objects.select_related('element').all()
    serializer_class = s.IfcRelationSerializer

# Lots / Prestations viewsets
class LotViewSet(BaseViewSet):
    queryset = m.Lot.objects.select_related('project').all()
    serializer_class = s.LotSerializer

class EnsemblePrestationViewSet(BaseViewSet):
    queryset = m.EnsemblePrestation.objects.select_related('lot').all()
    serializer_class = s.EnsemblePrestationSerializer

class PrestationViewSet(BaseViewSet):
    queryset = m.Prestation.objects.select_related('ensemble').all()
    serializer_class = s.PrestationSerializer

class PrestationQtyViewSet(BaseViewSet):
    queryset = m.PrestationQty.objects.select_related('prestation').all()
    serializer_class = s.PrestationQtySerializer

class AuditLogViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = m.AuditLog.objects.select_related('user').all()
    serializer_class = s.AuditLogSerializer
    filter_backends = [filters.SearchFilter, DjangoFilterBackend, filters.OrderingFilter]
    search_fields = ['model', 'object_id', 'user__username']
    filterset_fields = ['model', 'object_id', 'action', 'user']
    ordering = ['-created_at']
