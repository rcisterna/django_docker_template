#!/usr/bin/env sh

if [ "$DDT_ENV" != "production" ]; then
	echo "### DDT: CERTBOT -- DEV"
	trap exit TERM; while :; do sleep 12h & wait $!; done;
    exit
fi

export LETSENCRYPT_DIR=/etc/letsencrypt
export CA_DIR=${LETSENCRYPT_DIR}/live/${DDT_SSL_NAME}

if [ ! -e "${LETSENCRYPT_DIR}/options-ssl-nginx.conf" ] || [ ! -e "${LETSENCRYPT_DIR}/ssl-dhparams.pem" ]; then
	echo "### DDT: CERTBOT -- FAKE CA"

	mkdir -p ${CA_DIR}

	wget -O ${LETSENCRYPT_DIR}/options-ssl-nginx.conf https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/options-ssl-nginx.conf
	wget -O ${LETSENCRYPT_DIR}/ssl-dhparams.pem https://raw.githubusercontent.com/certbot/certbot/master/certbot/ssl-dhparams.pem

	openssl req -x509 -nodes -newkey rsa:1024 -days 1 \
		-keyout "${CA_DIR}/privkey.pem" \
		-out "${CA_DIR}/fullchain.pem" \
		-subj "/CN=localhost"

	sleep 3s
	exit
fi

if [ ! -e "${LETSENCRYPT_DIR}/cntx_ssl_done" ]; then
	echo "### DDT: CERTBOT -- ACME-CHALLENGE"
	rm -rf ${CA_DIR} && \
	rm -rf ${LETSENCRYPT_DIR}/archive/${DDT_SSL_NAME} && \
	rm -rf ${LETSENCRYPT_DIR}/renewal/${DDT_SSL_NAME}.conf

    # Si se desean hacer pruebas, es necesario agregar argumento --staging
    # para no superar el rate limit semanal
	certbot certonly --non-interactive --webroot --webroot-path ${DDT_ROOT}/certbot \
		--cert-name ${DDT_SSL_NAME} --email ${DDT_SSL_MAIL} --agree-tos \
		--domains ${DDT_DOMAINS// /,} --force-renewal

	if [ $? -eq 0 ]; then
		touch ${LETSENCRYPT_DIR}/cntx_ssl_done
		sleep 3s
		echo "### DDT: CERTBOT -- ACME-CHALLENGE SUCCESS"
	else
		echo "### DDT: CERTBOT -- ACME-CHALLENGE FAILURE"
	fi
	exit
fi

echo "### DDT: CERTBOT -- PRODUCTION"
trap exit TERM; while :; do certbot renew; sleep 12h & wait $!; done;
