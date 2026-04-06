# Mouhamadou Bamba Dieng
from django.shortcuts import render, redirect
from django.contrib import messages
from .models import ContactMessage


def custom_404_view(request, exception):
    return render(request, '404.html', status=404)


def home(request):
    if request.method == 'POST':
        name = request.POST.get('name', '').strip()
        email = request.POST.get('email', '').strip()
        message = request.POST.get('message', '').strip()

        if name and email and message:
            ContactMessage.objects.create(
                name=name,
                email=email,
                message=message,
            )
            messages.success(request, 'Your message has been sent successfully! I will get back to you shortly.')
            return redirect('home')

    return render(request, 'home.html')


def curriculum_vitae(request):
    return render(request, 'curriculum_vitae.html')
