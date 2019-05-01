import time
from datetime import datetime, timedelta

from django.db import connection
from django.db.utils import OperationalError
from django.core.management.base import BaseCommand


class Command(BaseCommand):
    help = "Espera a que la base de datos esté disponible"

    def add_arguments(self, parser):
        parser.add_argument('--time', help="Tiempo maximo de espera, en segundos", type=int, default=30)

    def handle(self, *args, **options):
        """Handle the command"""
        tmax = timedelta(seconds=options['time'])
        tstart = datetime.now()
        connected = False
        while tmax > (datetime.now() - tstart):
            try:
                connection.ensure_connection()
            except OperationalError:
                time.sleep(1)
            else:
                connected = True
                break

        if connected:
            self.stdout.write(self.style.SUCCESS('Base de datos disponible.'))
        else:
            self.stdout.write(self.style.ERROR('Base de datos no disponible en f{options["time"]} segundos.'))
