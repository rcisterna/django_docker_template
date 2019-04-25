import os

from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model


class Command(BaseCommand):
    help = "Crea el superusuario por defecto si no existe"

    def handle(self, *args, **options):
        UserModel = get_user_model()
        if UserModel.objects.filter(username=os.environ["DDT_SU_USER"]).exists():
            return

        UserModel.objects.create_superuser(
            username=os.environ["DDT_SU_USER"], email=os.environ["DDT_SU_MAIL"], password=os.environ["DDT_SU_PASS"]
        )
