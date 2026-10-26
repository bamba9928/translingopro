# Mouhamadou Bamba Dieng
# lingoglobalservices
# lingoglobalservices
# Bassirou Fall: Interpreter & Translator in Senegal
# Providing professional translation and interpretation services across multiple languages in # # Senegal and beyond.

## Configuration

Deux variables d'environnement :

- `DJANGO_SECRET_KEY` : obligatoire hors développement. Générer une valeur avec
  `python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"`.
- `DJANGO_DEBUG=true` (ou `1`, `yes`) : uniquement en local, pour le mode debug
  (sans clé, une clé de développement est alors utilisée). Hors debug, HTTPS,
  HSTS et cookies sécurisés sont actifs.
- `DJANGO_SECURE_HSTS_SECONDS` : facultatif, durée HSTS (un an par défaut).

En production, ces variables sont dans `~/apps/translingopro/.env`, chargé par
le service systemd `translingopro`.

## Vérification des secrets avant commit

Le hook `.githooks/pre-commit` lance Gitleaks sur les modifications indexées et
bloque le commit s'il y trouve un secret (clé, jeton, mot de passe). À activer
une fois par clone, Gitleaks étant installé (`winget install gitleaks` sous
Windows) :

```bash
git config core.hooksPath .githooks
```

Faux positif vérifié : ajouter l'empreinte affichée dans `.gitleaksignore`.
