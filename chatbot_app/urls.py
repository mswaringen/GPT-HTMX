from django.urls import path
from .views import chat_view, delete_message_view

urlpatterns = [
    path('', chat_view, name='chat_view'),
    path('delete/', delete_message_view, name='delete_message_view'),
]
