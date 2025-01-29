# Mouhamadou Bamba Dieng
from django.shortcuts import render

def custom_404_view(request, exception):
    return render(request, '404.html', status=404)

def home(request):
    return render(request, 'home.html')
def curriculum_vitae(request):
    return render(request, 'curriculum_vitae.html')







