#!/usr/bin/env python
import os
import sys
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'scoping_backend.settings')
django.setup()

from core.models import Client, Project

def create_test_data():
    # Nettoyer les données existantes
    Project.objects.all().delete()
    Client.objects.all().delete()
    
    # Créer les clients
    c1 = Client.objects.create(name='Ville d\'Ézanville', code='C0001', contact_email='contact@ezanville.fr')
    c2 = Client.objects.create(name='Promoteur ABC', code='C0002', contact_email='contact@promoteur-abc.fr')
    c3 = Client.objects.create(name='Architecte XYZ', code='C0003', contact_email='contact@architecte-xyz.fr')
    
    # Créer les projets
    Project.objects.create(name='Pôle Culturel', code='PRJ-001', client=c1)
    Project.objects.create(name='Résidence Les Jardins', code='PRJ-002', client=c2)
    Project.objects.create(name='Bureaux Modernes', code='PRJ-003', client=c2)
    Project.objects.create(name='École Primaire', code='PRJ-004', client=c3)
    
    print('Données de test créées!')
    print(f'Clients: {Client.objects.count()}')
    print(f'Projets: {Project.objects.count()}')
    
    # Afficher les données créées
    print('\nClients:')
    for c in Client.objects.all():
        print(f'- {c.name} ({c.code})')
    
    print('\nProjets:')
    for p in Project.objects.all():
        print(f'- {p.name} ({p.code}) - Client: {p.client.name}')

if __name__ == '__main__':
    create_test_data()
