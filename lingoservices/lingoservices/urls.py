from django.contrib import admin
from django.contrib.sitemaps.views import sitemap
from django.urls import path, include



urlpatterns = [
    path('bassiroufall/', admin.site.urls),
    path("", include("lingoweb.urls")),
    path('home/', include("lingoweb.urls")),
]
