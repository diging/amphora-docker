#!/bin/bash

NAME="amphora"                                  # Name of the application
DJANGODIR=/usr/src/app/amphora             # Django project directory
SOCKFILE=/usr/src/app/run/jars.sock  # we will communicte using this unix socket
NUM_WORKERS=3                                     # how many worker processes should Gunicorn spawn
DJANGO_SETTINGS_MODULE=jars.settings             # which settings file should Django use
DJANGO_WSGI_MODULE=jars.wsgi                     # WSGI module name
DJANGO_CELERY_MODULE=jars.celery                     # WSGI module name

echo "Starting $NAME as `whoami`"

# Activate the virtual environment
cd $DJANGODIR
source env_secrets
export DJANGO_SETTINGS_MODULE=$DJANGO_SETTINGS_MODULE
export PYTHONPATH=$DJANGODIR:$PYTHONPATH
export C_FORCE_ROOT="true"

# Create the run directory if it doesn't exist
RUNDIR=$(dirname $SOCKFILE)
test -d $RUNDIR || mkdir -p $RUNDIR

# Start your Django Unicorn
# Programs meant to be run under supervisor should not daemonize themselves (do not use --daemon)
exec celery --app=${DJANGO_CELERY_MODULE}:app worker --loglevel=INFO
