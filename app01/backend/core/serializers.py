from rest_framework import serializers
from . import models as m

class ClientSerializer(serializers.ModelSerializer):
    class Meta:
        model = m.Client
        fields = '__all__'

class ProjectSerializer(serializers.ModelSerializer):
    client = ClientSerializer(read_only=True)
    client_id = serializers.PrimaryKeyRelatedField(
        queryset=m.Client.objects.all(), source='client', write_only=True
    )

    class Meta:
        model = m.Project
        fields = ('id','name','code','description','start_date','end_date','client','client_id','created_at','updated_at')

class AuditLogSerializer(serializers.ModelSerializer):
    user = serializers.StringRelatedField()

    class Meta:
        model = m.AuditLog
        fields = '__all__'

class DocumentSerializer(serializers.ModelSerializer):
    class Meta:
        model = m.Document
        fields = '__all__'

class ProjectUserSerializer(serializers.ModelSerializer):
    class Meta:
        model = m.ProjectUser
        fields = '__all__'

# IFC serializers
class IfcRelationSerializer(serializers.ModelSerializer):
    class Meta:
        model = m.IfcRelation
        fields = '__all__'

class IfcElementSerializer(serializers.ModelSerializer):
    relations = IfcRelationSerializer(many=True, read_only=True)

    class Meta:
        model = m.IfcElement
        fields = '__all__'

class IfcSpaceSerializer(serializers.ModelSerializer):
    elements = IfcElementSerializer(many=True, read_only=True)

    class Meta:
        model = m.IfcSpace
        fields = '__all__'

class IfcStoreySerializer(serializers.ModelSerializer):
    spaces = IfcSpaceSerializer(many=True, read_only=True)

    class Meta:
        model = m.IfcStorey
        fields = '__all__'

class IfcBuildingSerializer(serializers.ModelSerializer):
    storeys = IfcStoreySerializer(many=True, read_only=True)

    class Meta:
        model = m.IfcBuilding
        fields = '__all__'

class IfcSiteSerializer(serializers.ModelSerializer):
    buildings = IfcBuildingSerializer(many=True, read_only=True)

    class Meta:
        model = m.IfcSite
        fields = '__all__'

class IfcProjectSerializer(serializers.ModelSerializer):
    sites = IfcSiteSerializer(many=True, read_only=True)

    class Meta:
        model = m.IfcProject
        fields = '__all__'

# Lot / Prestation serializers
class LotSerializer(serializers.ModelSerializer):
    class Meta:
        model = m.Lot
        fields = '__all__'

class EnsemblePrestationSerializer(serializers.ModelSerializer):
    class Meta:
        model = m.EnsemblePrestation
        fields = '__all__'

class PrestationQtySerializer(serializers.ModelSerializer):
    class Meta:
        model = m.PrestationQty
        fields = '__all__'

class PrestationSerializer(serializers.ModelSerializer):
    quantities = PrestationQtySerializer(many=True, read_only=True)

    class Meta:
        model = m.Prestation
        fields = '__all__'
