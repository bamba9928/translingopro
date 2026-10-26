# TranslingoPro

Website of **Bassirou Fall**, professional interpreter and translator based in
Dakar, Senegal, working in English, French and Wolof.

Live site: <https://translingopro.com>

## Features

- One-page presentation of the services: interpretation, document translation,
  business liaison, medical interpretation, tourist guide and escort, legal and
  NGO support.
- Curriculum vitae page.
- Contact form: messages are stored in the database and read from the Django
  admin.
- `sitemap.xml`, `robots.txt` and a custom 404 page.

## Tech stack

- Python 3.14 and Django 5.2 (LTS)
- SQLite
- WhiteNoise for static files
- Gunicorn behind nginx in production

## Project structure

```
.
├── .github/            CI, security scans and Dependabot
├── .githooks/          Gitleaks pre-commit hook
└── lingoservices/      Django project
    ├── lingoservices/  settings, URLs, WSGI entry point
    ├── lingoweb/       app: views, contact model, admin, sitemap
    ├── templates/      HTML pages
    ├── static/         CSS and images
    └── requirements.txt
```

## Getting started

Requirements: Python 3.12 or later.

```bash
cd lingoservices
python -m venv .venv
source .venv/bin/activate        # Windows: .venv\Scripts\activate
pip install -r requirements.txt
export DJANGO_DEBUG=true         # Windows PowerShell: $env:DJANGO_DEBUG="true"
python manage.py migrate
python manage.py createsuperuser # to read contact messages in the admin
python manage.py runserver
```

The site is then available at <http://127.0.0.1:8000>.

## Configuration

Settings are read from environment variables, never from the repository.

| Variable | Required | Description |
|---|---|---|
| `DJANGO_SECRET_KEY` | Outside debug mode | Signs sessions, CSRF tokens and password reset links. Without it, the site refuses to start unless debug mode is on. |
| `DJANGO_DEBUG` | No | `true`, `1` or `yes` enables debug mode, for local development only. Off by default. |
| `DJANGO_SECURE_HSTS_SECONDS` | No | HSTS duration in seconds. Defaults to one year outside debug mode. |

Generate a secret key with:

```bash
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

Outside debug mode, the site redirects to HTTPS and uses HSTS and secure
cookies. It expects the reverse proxy to send `X-Forwarded-Proto`.

## Tests

```bash
cd lingoservices
DJANGO_SECRET_KEY=test python manage.py test --top-level-directory .
```

`--top-level-directory .` is needed because `lingoservices/__init__.py` turns
the project folder into a package, which otherwise breaks test discovery.

## Continuous integration and security

Every pull request and every push to `main` runs:

- **CI**: `manage.py check`, a check that migrations are up to date, and the
  tests.
- **Security**: Gitleaks scans the whole git history for secrets, and Trivy
  scans dependencies, configuration and files. Trivy results appear in the
  repository's *Security* tab. This workflow also runs every Monday.
- **CodeQL**: static analysis of the Python code.

Dependabot opens a single grouped pull request for security updates of the
Python dependencies, and a monthly one for GitHub Actions. All actions are
pinned to a commit SHA, and the repository settings require it.

### Secret check before each commit

The `.githooks/pre-commit` hook runs Gitleaks on staged changes and blocks the
commit if it finds a secret (key, token, password). Enable it once per clone,
with Gitleaks installed (`winget install gitleaks` on Windows):

```bash
git config core.hooksPath .githooks
```

If a finding is a verified false positive, add the fingerprint it prints to
`.gitleaksignore`.

## Deployment

Production runs on a VPS: Gunicorn is managed by a systemd service and served
behind nginx over HTTPS. Environment variables come from an environment file
loaded by that service, outside the repository. Deployment is manual: nothing
is deployed automatically from GitHub.

## License

Apache License 2.0. See [LICENSE](LICENSE).

## Author

Developed by Mouhamadou Bamba Dieng for Bassirou Fall.
