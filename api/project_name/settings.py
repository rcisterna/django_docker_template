#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Settings."""

import os

# Django settings for {{ project_name }} project.

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
INSIDE_DOCKER = os.environ.get('DDT_IN_DKR', 'false') == 'true'

SECRET_KEY = os.environ['DDT_SECRET_KEY'] if INSIDE_DOCKER else 50 * '-'
DEBUG = os.environ['DDT_ENV'] != 'production' if INSIDE_DOCKER else True

CORS_ORIGIN_ALLOW_ALL = DEBUG
CORS_ORIGIN_WHITELIST = os.environ['DDT_VUE_DOMAINS'].split() if INSIDE_DOCKER else []

SESSION_COOKIE_SECURE = CSRF_COOKIE_SECURE = os.environ['DDT_ENV'] == 'production' if INSIDE_DOCKER else False
ALLOWED_HOSTS = os.environ['DDT_API_DOMAINS'].split() if INSIDE_DOCKER else []


# Application definition

AUTH_USER_MODEL = 'authentication.User'

INSTALLED_APPS = [
    'authentication',
    'commands',
    'corsheaders',
    'rest_framework',
    'rest_framework.authtoken',
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
]

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = '{{ project_name }}.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = '{{ project_name }}.wsgi.application'

# REST Framework

REST_FRAMEWORK = {
    'DEFAULT_PERMISSION_CLASSES': (
        'rest_framework.permissions.IsAuthenticated',
    ),
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework.authentication.TokenAuthentication',
        'rest_framework.authentication.SessionAuthentication',
    ),
    'DEFAULT_RENDERER_CLASSES': (
        'rest_framework.renderers.JSONRenderer',
        'rest_framework.renderers.BrowsableAPIRenderer',
    ),
    'DATETIME_FORMAT': '%d-%m-%Y %H:%M:%S',
    'DATE_FORMAT': '%d-%m-%Y',
    'TIME_FORMAT': '%H:%M:%S',
    'DATETIME_INPUT_FORMATS': ['%d-%m-%Y-%H:%M', '%d/%m/%Y-%H:%M', '%d-%m-%Y-%H:%M:%S', '%d/%m/%Y-%H:%M:%S'],
    'DATE_INPUT_FORMATS': ['%d-%m-%Y', '%d/%m/%Y'],
    'TIME_INPUT_FORMATS': ['%H:%M', '%H:%M:%S'],
}


# Database

DATABASES = {
    'default': {},
}

if INSIDE_DOCKER:
    DATABASES['default']['ENGINE'] = 'django.db.backends.postgresql_psycopg2'
    DATABASES['default']['NAME'] = os.environ['POSTGRES_DB']
    DATABASES['default']['USER'] = os.environ['POSTGRES_USER']
    DATABASES['default']['PASSWORD'] = os.environ['POSTGRES_PASSWORD']
    DATABASES['default']['HOST'] = 'postgresdb'
    DATABASES['default']['PORT'] = '5432'
else:
    DATABASES['default']['ENGINE'] = 'django.db.backends.sqlite3'
    DATABASES['default']['NAME'] = os.path.join(BASE_DIR, 'db.sqlite3')

# Password validation

AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]


# Internationalization

LANGUAGE_CODE = 'es-cl'

TIME_ZONE = 'America/Santiago'

USE_I18N = True

USE_L10N = True

USE_TZ = True


# Static files (CSS, JavaScript, Images)

STATIC_URL = '/static/'
STATIC_ROOT = os.path.join(os.environ['DDT_ROOT'] if INSIDE_DOCKER else BASE_DIR, 'static')
MEDIA_ROOT = os.path.join(os.environ['DDT_ROOT'] if INSIDE_DOCKER else BASE_DIR, 'media')
