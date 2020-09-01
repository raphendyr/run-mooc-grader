DEBUG = True

STATIC_ROOT = '/local/grader/static/'
MEDIA_ROOT = '/local/grader/media/'
SUBMISSION_PATH = '/local/grader/uploads'
PERSONALIZED_CONTENT_PATH = '/local/grader/ex-meta'
STATIC_URL_HOST_INJECT = 'http://localhost:8080'

CONTAINER_MODE = True
CONTAINER_SCRIPT = '/srv/docker-compose-run.sh'

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'grader',
    },
}

CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
        'LOCATION': 'unique-snowflake',
    },
}

LOGGING['loggers'].update({
    '': {
        'level': 'INFO',
        'handlers': ['console'],
        'propagate': True,
    },
    'django': {
        'level': 'INFO',
    },
    #'django.db.backends': {
    #    'level': 'DEBUG',
    #},
})

# kate: space-indent on; indent-width 4;
# vim: set expandtab ts=4 sw=4:
