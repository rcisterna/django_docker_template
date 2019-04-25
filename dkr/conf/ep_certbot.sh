#!/usr/bin/env sh

# Si no está en producción, no hace nada y espera a ser terminado
if [ "$DDT_ENV" != "production" ]; then
	echo "### DDT: CERTBOT -- DEV"
	trap exit TERM; while :; do sleep 12h & wait $!; done;
    exit
fi

export LETSENCRYPT_DIR=/etc/letsencrypt

# Crea el certificado si no existe
if [ ! -e "${LETSENCRYPT_DIR}/cntx_ssl_done" ]; then
	echo "### DDT: CERTBOT -- NEW CERTIFICATE"
	rm -rf ${LETSENCRYPT_DIR}/live/${DDT_SSL_NAME} && \
	rm -rf ${LETSENCRYPT_DIR}/archive/${DDT_SSL_NAME} && \
	rm -rf ${LETSENCRYPT_DIR}/renewal/${DDT_SSL_NAME}.conf

	mkdir -p ${LETSENCRYPT_DIR}/live/${DDT_SSL_NAME}

	if [ ! -e "${LETSENCRYPT_DIR}/options-ssl-nginx.conf" ]; then
		wget -O ${LETSENCRYPT_DIR}/options-ssl-nginx.conf \
			https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/options-ssl-nginx.conf
	fi

	if [ ! -e "${LETSENCRYPT_DIR}/ssl-dhparams.pem" ]; then
		wget -O ${LETSENCRYPT_DIR}/ssl-dhparams.pem \
			https://raw.githubusercontent.com/certbot/certbot/master/certbot/ssl-dhparams.pem
	fi

    # Si se desean hacer pruebas, es necesario agregar argumento --staging
    # para no superar el rate limit semanal
	certbot certonly --non-interactive --webroot --webroot-path ${DDT_ROOT}/certbot \
		--cert-name ${DDT_SSL_NAME} --email ${DDT_SSL_MAIL} --agree-tos \
		--domains ${DDT_DOMAINS// /,} --force-renewal

	if [ $? -eq 0 ]; then
		echo ${DDT_DOMAINS} > ${LETSENCRYPT_DIR}/cntx_ssl_done
		sleep 3s
		echo "### DDT: CERTBOT -- CERTIFICATE SUCCESS"
	else
		echo "### DDT: CERTBOT -- CERTIFICATE FAILURE"
	fi
	exit
fi

# Actualiza el certificado si se creó para dominios distintos
if [[ $(< ${LETSENCRYPT_DIR}/cntx_ssl_done) != "$str" ]]; then
	echo "### DDT: CERTBOT -- UPDATE CERTIFICATE"
	certbot certonly --cert-name ${DDT_SSL_NAME} --domains ${DDT_DOMAINS// /,}

	if [ $? -eq 0 ]; then
		echo ${DDT_DOMAINS} > ${LETSENCRYPT_DIR}/cntx_ssl_done
		sleep 3s
		echo "### DDT: CERTBOT -- CERTIFICATE SUCCESS"
	else
		echo "### DDT: CERTBOT -- CERTIFICATE FAILURE"
	fi
	exit
fi

# Loop infinito para revisar renovación
echo "### DDT: CERTBOT -- RENEW LOOP"
trap exit TERM; while :; do certbot renew; sleep 12h & wait $!; done;
