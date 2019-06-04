import os

from django.core.management.base import BaseCommand
from django.contrib.auth.models import Permission


class Command(BaseCommand):
    help = "Traduce los permisos a español a lo bruto"

    def handle(self, *args, **options):
        permissions = Permission.objects.all()

        # Reemplaza el texto inicial
        prefix_translations = {
            'Can add': 'Crear',
            'Can change': 'Editar',
            'Can delete': 'Eliminar',
            'Can view': 'Ver',
        }
        for en_prefix, es_prefix in prefix_translations.items():
            for perm in permissions.filter(name__startswith=en_prefix):
                perm.name = perm.name.replace(en_prefix, es_prefix).capitalize()
                perm.save()

        # Reemplaza texto (usualmente generado por django)
        ocurrence_translations = {
            'log entry': 'log',
            'group': 'grupo',
            'permission': 'permiso',
            'user': 'usuario',
            'content type': 'tipo de contenido',
            'session': 'sesión',
        }
        for en_prefix, es_prefix in ocurrence_translations.items():
            for perm in permissions.filter(name__icontains=en_prefix):
                perm.name = perm.name.replace(en_prefix, es_prefix).capitalize()
                perm.save()
