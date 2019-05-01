Template sencillo para Django 2.0+

## Contenedores
- postgresdb (postgres:10): Servicio de DB en PostgreSQL
- django (Dockerfile): Servicio de django + gunicorn
- certbot (certbot:latest): Servicio de renovación de certificados SSL (solo en producción)
- nginx (nginx:1.16.0): Servicio de reverse-proxy de nginx para gunicorn, con SSL (solo en producción)
- Auto creación de superusuario de Django (para acceso a admin)

## Uso
```bash
django-admin startproject \
	--template=https://github.com/rcisterna/django_docker_template/archive/master.zip \
	--extension=py,sh,toml,env,example,json,html,md \
	<projectname>

poetry lock
docker-compose up
```
