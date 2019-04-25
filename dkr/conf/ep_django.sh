#!/usr/bin/env sh

# Intenta migrar
echo "### DDT: DJANGO -- MIGRATE"
python ${DDT_ROOT}/src/manage.py migrate --no-input || exit 1

# Intenta crear el superusuario por defecto
echo "### DDT: DJANGO -- SUPERUSER"
python ${DDT_ROOT}/src/manage.py sucreator || exit 1

# Recolecta los archivos estáticos y ejecuta servidor gunicorn
echo "### DDT: DJANGO -- GUNICORN"
python ${DDT_ROOT}/src/manage.py collectstatic --no-input \
&& gunicorn -c ${DDT_ROOT}/conf/gunicorn.py {{ project_name }}.wsgi:application
