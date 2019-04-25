#!/usr/bin/env sh
export DOLLAR=$
rm -f /etc/nginx/conf.d/default.conf

if [ "$DDT_ENV" != "production" ]; then
	echo "### DDT: NGINX -- DEV"
    envsubst < ${DDT_ROOT}/conf/nginx.basic.template > /etc/nginx/conf.d/local.conf
	nginx -g "daemon off;"
    exit
fi

# Si existe cntx_fake_ssl, inicia el servidor solo mientras se crean los
# certificados reales, y luego termina para reiniciarse
if [ ! -e "/etc/letsencrypt/cntx_ssl_done" ]; then
	echo "### DDT: NGINX -- ACME-CHALLENGE"
    envsubst < ${DDT_ROOT}/conf/nginx.basic.template > /etc/nginx/conf.d/local.conf
	nginx -g "daemon on;"
	while [ ! -e "/etc/letsencrypt/cntx_ssl_done" ]; do sleep 1s; done
	nginx -s stop
	exit
fi

echo "### DDT: NGINX -- PRODUCTION"
envsubst < ${DDT_ROOT}/conf/nginx.ssl.template > /etc/nginx/conf.d/local.conf
while :; do sleep 6h & wait $!; nginx -s reload; done & nginx -g "daemon off;"
