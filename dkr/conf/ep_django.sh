#!/usr/bin/env sh
echo "### DDT: DJANGO -- MIGRATE"
python ${DDT_ROOT}/src/manage.py migrate --no-input || exit 1

echo "### DDT: DJANGO -- SUPERUSER"
python ${DDT_ROOT}/src/manage.py sucreator || exit 1

echo "### DDT: DJANGO -- GUNICORN"
python ${DDT_ROOT}/src/manage.py collectstatic --no-input \
&& gunicorn -c ${DDT_ROOT}/conf/gunicorn.py pypi.wsgi:application
