# Mouhamadou Bamba Dieng
# lingoglobalservices
# lingoglobalservices
# Bassirou Fall: Interpreter & Translator in Senegal
# Providing professional translation and interpretation services across multiple languages in # # Senegal and beyond.

## Configuration

Deux variables d'environnement :

- `DJANGO_SECRET_KEY` : obligatoire hors développement. Générer une valeur avec
  `python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"`.
- `DJANGO_DEBUG=True` : uniquement en local, pour le mode debug (sans clé, une
  clé de développement est alors utilisée).
