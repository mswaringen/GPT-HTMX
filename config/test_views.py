from django.http import HttpResponse

from .celery_app import example_task


def test_task(request):
    example_task.delay()
    return HttpResponse("Task triggered, see Celery logs")