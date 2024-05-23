# define an alias for the specific python version used in this file.
FROM docker.io/python:3.12.3-slim-bookworm as python

# Python build stage
FROM python as python-build-stage

ARG BUILD_ENVIRONMENT=production

# Install apt packages
RUN apt-get update && apt-get install --no-install-recommends -y \
  # dependencies for building Python packages
  build-essential \
  # psycopg dependencies
  libpq-dev

# Requirements are installed here to ensure they will be cached.
COPY ./requirements .

# Create Python Dependency and Sub-Dependency Wheels.
RUN pip wheel --wheel-dir /usr/src/app/wheels  \
  -r ${BUILD_ENVIRONMENT}.txt


# Python 'run' stage
FROM python as python-run-stage

ARG BUILD_ENVIRONMENT=production
ARG APP_HOME=/code

ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1
ENV BUILD_ENV ${BUILD_ENVIRONMENT}

WORKDIR ${APP_HOME}

RUN addgroup --system django \
    && adduser --system --ingroup django django


# Install required system dependencies
RUN apt-get update && apt-get install --no-install-recommends -y \
  # psycopg dependencies
  libpq-dev \
  # Translations dependencies
  gettext \
  # cleaning up unused files
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && rm -rf /var/lib/apt/lists/*

# All absolute dir copies ignore workdir instruction. All relative dir copies are wrt to the workdir instruction
# copy python dependency wheels from python-build-stage
COPY --from=python-build-stage /usr/src/app/wheels  /wheels/

# use wheels to install python dependencies
RUN pip install --no-cache-dir --no-index --find-links=/wheels/ /wheels/* \
  && rm -rf /wheels/

COPY . /code

# Set dummy vars for building purposes
# ENV DJANGO_SETTINGS_MODULE "config.settings.production"
# ENV DATABASE_URL "temp"
# ENV DJANGO_SECRET_KEY "non-secret-key-for-building-purposes"
# ENV REDIS_URL "temp"
# ENV DJANGO_ADMIN_URL "temp"
# ENV DJANGO_ALLOWED_HOSTS "temp"
# ENV MAILJET_API_KEY "temp"
# ENV MAILJET_SECRET_KEY "temp"
# ENV SENTRY_DSN ""
# ENV DJANGO_AWS_ACCESS_KEY_ID "temp"
# ENV DJANGO_AWS_SECRET_ACCESS_KEY "temp"
# ENV DJANGO_AWS_STORAGE_BUCKET_NAME "temp"

# RUN python manage.py collectstatic --noinput

EXPOSE 8000

CMD ["gunicorn", "--bind", ":8000", "--workers", "1", "config.wsgi"]

# CMD ["/bin/bash", "-c", "python manage.py collectstatic --noinput; gunicorn --bind :8000 --workers 1 config.wsgi"]
# CMD ["/bin/bash", "-c", "python manage.py collectstatic --noinput && gunicorn --bind :8000 --workers 1 config.wsgi"]
