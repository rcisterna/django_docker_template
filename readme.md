Template sencillo para PostgreSQL, Django, Vue.js, NGINX y Certbot

## Contenedores
- postgresdb (postgres:11-alpine): Servicio de DB en PostgreSQL
- api (dockerfile-api basado en python:3.7-alpine): Servicio de django + gunicorn
- vue (dockerfile-vue basado en node:lts-alpine): Servicio de vuejs + http-server
- nginx (nginx:1.16-alpine): Servicio de reverse-proxy para gunicorn y http-server, con SSL (solo en producción)
- certbot (certbot:latest): Servicio de renovación de certificados SSL (solo en producción)

## Uso
```bash
django-admin startproject \
--template=https://github.com/rcisterna/django_docker_template/archive/master.zip \
--extension=py,sh,toml,env,example,json,html,md \
<projectname>

cd api && poetry lock && cd -
cd vue && npm install --package-lock-only && cd -
docker-compose up
```
