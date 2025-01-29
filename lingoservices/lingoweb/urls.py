# Mouhamadou Bamba Dieng
from django.urls import path
from . import views
from django.conf import settings
from django.conf.urls.static import static
from django.contrib.sitemaps.views import sitemap
from .sitemaps import StaticViewSitemap
from django.views.generic import TemplateView

sitemaps = {
    'static': StaticViewSitemap,
}




urlpatterns = [
    path('', views.home, name='home'),
    path('curriculum_vitae', views.curriculum_vitae, name='curriculum_vitae'),
    path('sitemap.xml', sitemap, {'sitemaps': sitemaps}, name='sitemap'),
    path('robots.txt', TemplateView.as_view(template_name="robots.txt", content_type="text/plain")),
] + static(settings.STATIC_URL, document_root=settings.STATICFILES_DIRS[0])
