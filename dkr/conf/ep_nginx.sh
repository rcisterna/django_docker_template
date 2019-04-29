#!/usr/bin/env sh
export DOLLAR=$
rm -f /etc/nginx/conf.d/default.conf

# Espera que el servicio de django haya sido lanzado
echo "### DDT: NGINX -- WAITING FOR DJANGO"
export DJANGO_STATUS_CMD="wget --server-response --spider http://django:8000 2>&1 | grep "HTTP/" | awk '{print $2}'"
while [ -z "$(eval ${DJANGO_STATUS_CMD})" ]; do sleep 1s; done

# Si no está en producción, se ejecuta con la configuración básica (sin SSL)
if [ "$DDT_ENV" != "production" ]; then
	echo "### DDT: NGINX -- DEV"
    envsubst < ${DDT_ROOT}/conf/nginx.basic.template > /etc/nginx/conf.d/local.conf
	nginx -g "daemon off;"
    exit
fi

export LETSENCRYPT_DIR=/etc/letsencrypt

# Si los certificados se crearon para dominios distintos, los elimina
if [ -e "${LETSENCRYPT_DIR}/cntx_ssl_done" ] && [[ "$(cat ${LETSENCRYPT_DIR}/cntx_ssl_done)" != "${DDT_DOMAINS}" ]]; then
	echo "### DDT: NGINX -- OBSOLETE CERTIFICATE"
	rm -rf ${LETSENCRYPT_DIR}/cntx_ssl_done
fi

# Si no están listos los certificados, se ejecuta con la configuración básica
# (sin SSL), y se reinicia apenas se hayan creado los certificados
if [ ! -e "${LETSENCRYPT_DIR}/cntx_ssl_done" ]; then
	echo "### DDT: NGINX -- ACME-CHALLENGE"
    envsubst < ${DDT_ROOT}/conf/nginx.basic.template > /etc/nginx/conf.d/local.conf
	nginx -g "daemon on;"
	while [ ! -e "${LETSENCRYPT_DIR}/cntx_ssl_done" ]; do sleep 0.5s; done
	nginx -s stop
	exit
fi

# Se ejecuta con la configuración SSL, mientras en el background queda un loop
# infinito para revisar renovación
echo "### DDT: NGINX -- PRODUCTION"
envsubst < ${DDT_ROOT}/conf/nginx.ssl.template > /etc/nginx/conf.d/local.conf
while :; do sleep 6h & wait $!; nginx -s reload; done & nginx -g "daemon off;"
