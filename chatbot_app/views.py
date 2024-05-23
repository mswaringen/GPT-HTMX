from django.shortcuts import render
from .models import Message
import requests
import os

OPENAI_API_KEY = os.environ['OPENAI_API_KEY']

def chat_view(request):
    if request.method == "POST":
        user_message = request.POST.get('message')
        bot_message = get_ai_response(user_message)
        Message.objects.create(user_message=user_message, bot_message=bot_message)
    messages = Message.objects.all()
    
    if request.headers.get('HX-Request'):
        # Render only the messages part if it's an HTMX request
        return render(request, 'partials/messages.html', {'messages': messages})
    else:
        # Render the full template for normal requests
        return render(request, 'chat.html', {'messages': messages})
    

def delete_message_view(request):
    if request.method == "DELETE":
        Message.objects.all().delete()
        messages = Message.objects.all()
        return render(request, 'partials/messages.html', {'messages': messages})


def get_ai_response(user_input: str) -> str:
    # Set up the API endpoint and headers
    endpoint = "https://api.openai.com/v1/chat/completions"
    headers = {
        "Authorization": f"Bearer {OPENAI_API_KEY}",
        "Content-Type": "application/json",
    }

    # Data payload
    messages = get_existing_messages()
    messages.append({"role": "user", "content": f"{user_input}"})
    data = {
        "model": "gpt-3.5-turbo",
        "messages": messages,
        "temperature": 0.7
    }
    response = requests.post(endpoint, headers=headers, json=data)
    response_data = response.json()
    print(f'{response_data = }')
    ai_message = response_data['choices'][0]['message']['content']
    return ai_message


def get_existing_messages() -> list:
    """
    Get all messages from the database and format them for the API.
    """
    formatted_messages = []

    for message in Message.objects.values('user_message', 'bot_message'):
        formatted_messages.append({"role": "user", "content": message['user_message']})
        formatted_messages.append({"role": "assistant", "content": message['bot_message']})

    return formatted_messages