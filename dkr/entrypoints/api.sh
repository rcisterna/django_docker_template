#!/usr/bin/env sh

# Espera por la base de datos
echo "### DDT: API -- WAITING FOR DB"
python ${DDT_ROOT}/src/manage.py wait_db || exit 1

# Revisa si faltan migraciones que crear
echo "### DDT: API -- CHECK PENDING MIGRATIONS"
python ${DDT_ROOT}/src/manage.py makemigrations --check --dry-run --no-input || exit 1

# Intenta migrar
echo "### DDT: API -- MIGRATE"
python ${DDT_ROOT}/src/manage.py migrate --no-input || exit 1

# Intenta crear el superusuario por defecto
echo "### DDT: API -- SUPERUSER"
python ${DDT_ROOT}/src/manage.py sucreator || exit 1

# Recolecta los archivos estáticos y ejecuta servidor gunicorn
echo "### DDT: API -- GUNICORN"
python ${DDT_ROOT}/src/manage.py collectstatic --no-input \
&& gunicorn {{ project_name }}.wsgi:application \
	--name {{ project_name }} \
	--log-level $([[ "$DDT_ENV" != "production" ]] && echo "info" || echo "warning") \
	--error-logfile '-' \
	--access-logfile '-' \
	--workers 2 \
	--bind 0.0.0.0:8000
