#!/usr/bin/env sh
export DOLLAR=$
rm -f /etc/nginx/conf.d/default.conf

# Si no está en producción, se ejecuta con la configuración básica (sin SSL)
if [ "$DDT_ENV" != "production" ]; then
	echo "### DDT: NGINX -- DEV"
    envsubst < ${DDT_ROOT}/conf/nginx.basic.template > /etc/nginx/conf.d/local.conf
	nginx -g "daemon off;"
    exit
fi

# Si no están listos los certificados, se ejecuta con la configuración básica
# (sin SSL), y se reinicia apenas se hayan creado los certificados
if [ ! -e "/etc/letsencrypt/cntx_ssl_done" ]; then
	echo "### DDT: NGINX -- ACME-CHALLENGE"
    envsubst < ${DDT_ROOT}/conf/nginx.basic.template > /etc/nginx/conf.d/local.conf
	nginx -g "daemon on;"
	while [ ! -e "/etc/letsencrypt/cntx_ssl_done" ]; do sleep 1s; done
	nginx -s stop
	exit
fi

# Se ejecuta con la configuración SSL, mientras en el background queda un loop
# infinito para revisar renovación
echo "### DDT: NGINX -- PRODUCTION"
envsubst < ${DDT_ROOT}/conf/nginx.ssl.template > /etc/nginx/conf.d/local.conf
while :; do sleep 6h & wait $!; nginx -s reload; done & nginx -g "daemon off;"
