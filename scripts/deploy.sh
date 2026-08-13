#!/bin/bash
set -euo pipefail

ENVIRONMENT="${1:-develop}"
DEPLOY_HOST="${2:-}"
DEPLOY_USER="${3:-deploy}"
DEPLOY_DIR="${4:-/var/www/drupal-${ENVIRONMENT}}"
SSH_KEY_FILE="${5:-}"
BACKUP_DIR="/var/www/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "========== DRUPAL DEPLOY SCRIPT =========="
echo "Environnement: $ENVIRONMENT"
echo "Hôte cible: ${DEPLOY_HOST:-local}"
echo "Répertoire cible: $DEPLOY_DIR"
echo "Timestamp: $TIMESTAMP"

# Charger les variables d'environnement
if [ -f ".env" ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

if [ -n "$DEPLOY_HOST" ]; then
    SSH_OPTS="-o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
    if [ -n "$SSH_KEY_FILE" ]; then
        SSH_OPTS="$SSH_OPTS -i $SSH_KEY_FILE"
    fi

    echo "✓ Vérification accès SSH non-interactif..."
    if ! ssh $SSH_OPTS "$DEPLOY_USER@$DEPLOY_HOST" "echo 'SSH OK'" >/dev/null 2>&1; then
        echo "❌ Connexion SSH non-interactive impossible vers $DEPLOY_USER@$DEPLOY_HOST."
        echo "   Vérifiez la clé SSH Jenkins, l'utilisateur et authorized_keys côté serveur."
        exit 1
    fi

    REMOTE_SUDO_CMD=""
    if ssh $SSH_OPTS "$DEPLOY_USER@$DEPLOY_HOST" "command -v sudo >/dev/null 2>&1 && sudo -n true" >/dev/null 2>&1; then
        REMOTE_SUDO_CMD="sudo -n"
        echo "✓ sudo non-interactif disponible sur le serveur distant."
    elif ssh $SSH_OPTS "$DEPLOY_USER@$DEPLOY_HOST" "[ \"\$(id -u)\" -eq 0 ]" >/dev/null 2>&1; then
        REMOTE_SUDO_CMD=""
        echo "✓ Connexion distante en root (sudo non requis)."
    else
        echo "⚠️ sudo non-interactif indisponible sur le serveur distant."
        echo "   Le script continue sans sudo ; certaines opérations (chown) seront ignorées."
    fi

    if [ ! -d "vendor" ]; then
        echo "❌ Répertoire vendor introuvable. Exécutez d'abord composer install."
        exit 1
    fi

    if [ ! -x "vendor/bin/drush" ]; then
        echo "❌ Drush introuvable dans vendor/bin/drush. Vérifiez l'installation Composer."
        exit 1
    fi

    echo "✓ Préparation du serveur distant..."
    ssh $SSH_OPTS "$DEPLOY_USER@$DEPLOY_HOST" "mkdir -p '$DEPLOY_DIR'"

    if ! ssh $SSH_OPTS "$DEPLOY_USER@$DEPLOY_HOST" "mkdir -p '$BACKUP_DIR'"; then
        if [ -n "$REMOTE_SUDO_CMD" ]; then
            if ! ssh $SSH_OPTS "$DEPLOY_USER@$DEPLOY_HOST" "$REMOTE_SUDO_CMD mkdir -p '$BACKUP_DIR'"; then
                echo "⚠️ Création du répertoire de backup échouée ($BACKUP_DIR). Les backups distants seront ignorés."
            fi
        else
            echo "⚠️ Création du répertoire de backup échouée ($BACKUP_DIR). Les backups distants seront ignorés."
        fi
    fi

    echo "✓ Backup distant (si existant)..."
    # Le backup ne doit jamais bloquer un déploiement : on le tente, on avertit en cas d'échec.
    if ! ssh $SSH_OPTS "$DEPLOY_USER@$DEPLOY_HOST" "if [ -d '$DEPLOY_DIR/web' ]; then ${REMOTE_SUDO_CMD:+$REMOTE_SUDO_CMD }tar -czf '$BACKUP_DIR/drupal-$ENVIRONMENT-$TIMESTAMP.tar.gz' '$DEPLOY_DIR'; fi"; then
        echo "⚠️ Backup distant échoué (non bloquant)."
    fi

    echo "✓ Synchronisation des sources..."
    rsync -avz --delete -e "ssh $SSH_OPTS" \
        --exclude=".git" \
        --exclude="node_modules" \
        --exclude="vendor" \
        --exclude="web/sites/*/files" \
        --exclude="web/sites/*/private" \
        --exclude=".env.local" \
        . "$DEPLOY_USER@$DEPLOY_HOST:$DEPLOY_DIR/"

    echo "✓ Synchronisation des dépendances vendor..."
    rsync -avz --delete -e "ssh $SSH_OPTS" vendor/ "$DEPLOY_USER@$DEPLOY_HOST:$DEPLOY_DIR/vendor/"

    echo "✓ Permissions et bootstrap fichiers sur serveur..."
    ssh $SSH_OPTS "$DEPLOY_USER@$DEPLOY_HOST" "mkdir -p '$DEPLOY_DIR/web/sites/default/files' '$DEPLOY_DIR/logs'"

    if [ -n "$REMOTE_SUDO_CMD" ]; then
        ssh $SSH_OPTS "$DEPLOY_USER@$DEPLOY_HOST" "$REMOTE_SUDO_CMD chown -R www-data:www-data '$DEPLOY_DIR/web/sites/default/files' && $REMOTE_SUDO_CMD chmod -R 755 '$DEPLOY_DIR/web/sites/default/files' '$DEPLOY_DIR/logs'"
    else
        echo "⚠️ Étape chown ignorée (sudo non disponible)."
        ssh $SSH_OPTS "$DEPLOY_USER@$DEPLOY_HOST" "chmod -R 755 '$DEPLOY_DIR/web/sites/default/files' '$DEPLOY_DIR/logs'" || true
    fi

    echo "✓ Vérification des fichiers settings sur serveur..."
    ssh $SSH_OPTS "$DEPLOY_USER@$DEPLOY_HOST" "if [ ! -f '$DEPLOY_DIR/web/sites/default/settings.php' ]; then cp '$DEPLOY_DIR/web/sites/default/default.settings.php' '$DEPLOY_DIR/web/sites/default/settings.php'; fi"
    ssh $SSH_OPTS "$DEPLOY_USER@$DEPLOY_HOST" "if [ ! -f '$DEPLOY_DIR/web/sites/default/settings.local.php' ] && [ -f '$DEPLOY_DIR/web/sites/default/example.settings.local.php' ]; then cp '$DEPLOY_DIR/web/sites/default/example.settings.local.php' '$DEPLOY_DIR/web/sites/default/settings.local.php'; fi"

    echo "✓ Opérations post-déploiement Drupal sur serveur..."
    # Plus de "|| true" ici : si updatedb/config:import échoue, le déploiement
    # doit être marqué en échec dans Jenkins plutôt que de faire croire à un succès.
    ssh $SSH_OPTS "$DEPLOY_USER@$DEPLOY_HOST" "cd '$DEPLOY_DIR' && php vendor/bin/drush -y updatedb && php vendor/bin/drush -y config:import && php vendor/bin/drush cache:rebuild"
else
    # Déploiement local (fallback)
    if [ ! -d "vendor" ]; then
        echo "❌ Répertoire vendor introuvable. Exécutez d'abord composer install."
        exit 1
    fi

    mkdir -p "$DEPLOY_DIR"
    mkdir -p "$BACKUP_DIR"

    if [ -d "$DEPLOY_DIR/web" ]; then
        echo "✓ Création d'une sauvegarde..."
        if ! tar -czf "$BACKUP_DIR/drupal-$ENVIRONMENT-$TIMESTAMP.tar.gz" "$DEPLOY_DIR"; then
            echo "⚠️ Backup local échoué (non bloquant)."
        fi
    fi

    echo "✓ Copie des fichiers..."
    rsync -av --delete \
        --exclude=".git" \
        --exclude="node_modules" \
        --exclude="vendor" \
        --exclude="web/sites/*/files" \
        --exclude="web/sites/*/private" \
        --exclude=".env.local" \
        . "$DEPLOY_DIR/"

    echo "✓ Copie des dépendances..."
    cp -r vendor "$DEPLOY_DIR/"

    echo "✓ Définition des permissions..."
    if command -v sudo >/dev/null 2>&1 && sudo -n true >/dev/null 2>&1; then
        sudo -n chown -R www-data:www-data "$DEPLOY_DIR/web/sites/default/files"
        sudo -n chmod -R 755 "$DEPLOY_DIR/web/sites/default/files"
        sudo -n chmod -R 755 "$DEPLOY_DIR/logs"
    elif [ "$(id -u)" -eq 0 ]; then
        chown -R www-data:www-data "$DEPLOY_DIR/web/sites/default/files"
        chmod -R 755 "$DEPLOY_DIR/web/sites/default/files"
        chmod -R 755 "$DEPLOY_DIR/logs"
    else
        echo "⚠️ sudo non-interactif indisponible localement. Étape chown ignorée."
        chmod -R 755 "$DEPLOY_DIR/web/sites/default/files" "$DEPLOY_DIR/logs" || true
    fi

    echo "✓ Vérification de la configuration..."
    if [ ! -f "$DEPLOY_DIR/web/sites/default/settings.php" ]; then
        cp "$DEPLOY_DIR/web/sites/default/default.settings.php" "$DEPLOY_DIR/web/sites/default/settings.php"
    fi

    if [ ! -f "$DEPLOY_DIR/web/sites/default/settings.local.php" ] && [ -f "$DEPLOY_DIR/web/sites/default/example.settings.local.php" ]; then
        cp "$DEPLOY_DIR/web/sites/default/example.settings.local.php" "$DEPLOY_DIR/web/sites/default/settings.local.php"
    fi

    echo "✓ Exécution des opérations post-déploiement..."
    cd "$DEPLOY_DIR"
    if [ -x "vendor/bin/drush" ]; then
        php vendor/bin/drush -y updatedb
        php vendor/bin/drush -y config:import
        php vendor/bin/drush cache:rebuild
    else
        echo "❌ drush non trouvé, impossible de finaliser le déploiement local."
        exit 1
    fi
fi

echo "========== DÉPLOIEMENT RÉUSSI =========="
echo "Version déployée à: $DEPLOY_DIR"
