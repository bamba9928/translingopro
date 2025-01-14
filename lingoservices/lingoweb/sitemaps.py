from django.contrib.sitemaps import Sitemap
from django.urls import reverse


class StaticViewSitemap(Sitemap):
    priority = 0.8
    changefreq = 'daily'

    def items(self):
        # Inclure les vues statiques (About, Services, etc.)
        return ['home', 'curriculum_vitae']

    def location(self, item):
        return reverse(item)


class ArticleSitemap(Sitemap):
    priority = 0.6
    changefreq = 'weekly'



    def lastmod(self, obj):
        return obj.updated_at
