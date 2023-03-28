FROM python:2

WORKDIR /usr/src/app

RUN mkdir run
RUN mkdir logs/
RUN mkdir bin

RUN apt-get update && apt-get upgrade -y && apt-get autoremove && apt-get autoclean
# most of these are for lxml which needs a bunch of dependancies installed
RUN apt-get install -y \
    libffi-dev \
    libssl-dev \
    default-libmysqlclient-dev \
    libxml2-dev \
    libxslt-dev \
    libjpeg-dev \
    libfreetype6-dev \
    zlib1g-dev \
    net-tools \
    git-all \
    supervisor \
        redis-server\
    vim

COPY scripts/amphora-gunicorn.sh bin/
COPY scripts/amphora-celery.sh bin/
COPY scripts/amphora-celery-beat.sh bin/
COPY scripts/amphora-supervisord.conf /etc/supervisor/conf.d/

RUN chmod u+x bin/amphora-gunicorn.sh
RUN chmod u+x bin/amphora-celery.sh
RUN chmod u+x bin/amphora-celery-beat.sh

RUN git clone https://github.com/diging/amphora.git
WORKDIR /usr/src/app/amphora
RUN pip install --upgrade setuptools
RUN pip install -r requirements.txt

COPY env_secrets .
CMD /bin/bash -c "service redis-server start; service supervisor start; tail -f /dev/null"
