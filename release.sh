#!/usr/bin/env sh

python manage.py collectstatic --noinput 
python manage.py migrate

# exit 123