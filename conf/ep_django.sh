#!/usr/bin/env sh
echo "### DDT: DJANGO -- SUPERUSER"
python ${DDT_ROOT}/src/manage.py sucreator || exit 1

echo "### DDT: DJANGO -- GUNICORN"
python ${DDT_ROOT}/src/manage.py collectstatic --no-input \
&& python ${DDT_ROOT}/src/manage.py migrate --no-input \
&& gunicorn -c ${DDT_ROOT}/src/conf/gunicorn.py {{ project_name }}.wsgi:application
