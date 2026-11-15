#!/bin/bash
# Déploiement de translingopro.com.
#
# Lancé par /home/mada/deploy_translingopro.sh (hors dépôt), lui-même appelé
# par GitHub Actions (.github/workflows/ci.yml) via une clé SSH restreinte.
# Le lanceur a déjà mis le clone à jour (git reset sur origin/main).
#
# Sur le serveur :
#   repo/  clone git de ce dépôt (mis à jour par le lanceur)
#   app/   code servi par gunicorn (= repo/lingoservices + db.sqlite3 + staticfiles)
#   venv/  environnement Python
#   .env   DJANGO_SECRET_KEY, DJANGO_DEBUG… (lu par systemd et par ce script)
set -euo pipefail
umask 022

BASE=/home/mada/apps/translingopro
REPO=$BASE/repo
APP=$BASE/app
VENV=$BASE/venv
BACKUPS=/home/mada/backups/translingopro
SERVICE=translingopro

# Tout fichier (re)créé par mada est du groupe mada : le service doit pouvoir
# le lire via « autres ». Les fichiers d'origine (groupe svc-translingopro)
# ne sont pas touchés ; app/ reste fermé aux autres comptes.
fix_perms() {
    find "$APP" \( -path "$APP/staticfiles" -o -path "$APP/db.sqlite3" \) -prune -o \
        -group mada \( -type d -exec chmod 755 {} + -o -type f -exec chmod 644 {} + \)
    chmod 750 "$APP"
}

echo "--- Début du déploiement : $(date) ---"
git -C "$REPO" log --oneline -1

# Sauvegarde du code et de la base avant d'y toucher (10 dernières gardées).
mkdir -p "$BACKUPS"
(umask 077; tar -czf "$BACKUPS/app-$(date +%F-%H%M%S).tgz" -C "$BASE" \
    --exclude=app/staticfiles --exclude='__pycache__' app)
ls -1t "$BACKUPS"/app-*.tgz | tail -n +11 | xargs -r rm -f

# Copie du code. Sans --delete : les fichiers propres au serveur restent.
# rsync remplace chaque fichier modifié par un nouveau fichier du groupe mada,
# que le service (svc-translingopro) ne lit que via les droits « autres » :
# d'où -p avec 644/755. app/ lui-même reste en 750 mada:svc-translingopro,
# ce qui suffit à fermer l'accès aux autres comptes.
rsync -rlpt --checksum --chmod=D755,F644 \
    --exclude=db.sqlite3 --exclude=staticfiles/ \
    --exclude='__pycache__/' --exclude='*.pyc' \
    "$REPO/lingoservices/" "$APP/"
fix_perms

# Mêmes variables que le service (format KEY=valeur, sans guillemets).
while IFS= read -r line; do
    [[ $line =~ ^[A-Za-z_][A-Za-z0-9_]*= ]] && export "$line"
done < "$BASE/.env"

cd "$APP"
# Pas de .pyc écrits par mada : gunicorn compile les siens au besoin.
export PYTHONDONTWRITEBYTECODE=1
"$VENV/bin/pip" install --disable-pip-version-check -q -r requirements.txt
"$VENV/bin/python" manage.py check
"$VENV/bin/python" manage.py migrate --noinput
"$VENV/bin/python" manage.py collectstatic --noinput -v 0

# gunicorn tourne sous svc-translingopro : seul un restart via sudo est
# possible (sudoers : NOPASSWD pour « systemctl restart translingopro »).
sudo -n systemctl restart "$SERVICE"

for _ in $(seq 1 15); do
    code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 \
        -H 'Host: translingopro.com' -H 'X-Forwarded-Proto: https' \
        http://127.0.0.1:8030/ || true)
    [ "$code" = 200 ] && break
    sleep 2
done
if [ "$code" != 200 ]; then
    echo "translingopro ne répond pas après le redémarrage (HTTP $code)" >&2
    systemctl status "$SERVICE" --no-pager -n 20 >&2 || true
    # Retour au code d'avant ce déploiement (la base n'est pas touchée).
    backup=$(ls -1t "$BACKUPS"/app-*.tgz | head -n 1)
    echo "Retour arrière depuis $backup" >&2
    tar -xzf "$backup" -C "$BASE" --exclude=app/db.sqlite3
    fix_perms
    sudo -n systemctl restart "$SERVICE"
    exit 1
fi

echo "--- Déploiement terminé ---"
