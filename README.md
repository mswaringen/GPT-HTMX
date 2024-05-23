# Fly-Cookiecutter-Django

#### _Blog Post: [Deploying Cookiecutter Django on Fly.io](https://sweezy.dev/deploying-cookiecutter-django-on-flyio.html)_

## Base project for deploying on Fly.io

Basic Cookiecutter Django project with the following changes

- Modifications to deploy to Fly.io
- Uses [celery-django-results](https://github.com/celery/django-celery-results) to save job status to Postgres and view results in Django Admin. This is used as a replacement for Flower in production.
- Includes a custom `test-task` view to create a worker task from a GET request as a simple test of the system


## Deploy to Fly.io

### Launch wizard
Run `fly launch` from the root directory

```
- YES to copy config to new app
- NO to overwriting Dockerfile
- YES to modifying configuration, click to open setting page, select Postgres, Redis, Tigris
```

### Import secrets
Run the following command to import the secrets to Fly:

   ```
   cat .envs/.production/.django | fly secrets import
   ```

### Deploy

Run `fly deploy`

If deployment was successful, create a superuser via `fly ssh console`

### Deploy with GH Actions

1) From the project source directory, get a Fly API deploy token by running

```
fly tokens create deploy -x 999999h
```

Copy the output, including the FlyV1 and space at the beginning.

2) Go to your repository on GitHub and select Settings. Under Secrets and variables, select Actions, and then create a new repository secret called FLY_API_TOKEN, paste the value previously created in step 1.

3) Workflow already included in `.github/workflows/fly.yml`

### Trigger Test-Task

Visit [http://localhost:8000/test-task](http://localhost:8000/test-task) (or production URL), then check Django Admin under `Celery Results / Task Results`