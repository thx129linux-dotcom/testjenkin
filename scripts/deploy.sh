#!/bin/bash
set -e

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
    SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
    if [ -n "$SSH_KEY_FILE" ]; then
        SSH_OPTS="$SSH_OPTS -i $SSH_KEY_FILE"
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
    ssh $SSH_OPTS "$DEPLOY_USER@$DEPLOY_HOST" "mkdir -p '$DEPLOY_DIR' '$BACKUP_DIR'"

    echo "✓ Backup distant (si existant)..."
    ssh $SSH_OPTS "$DEPLOY_USER@$DEPLOY_HOST" "if [ -d '$DEPLOY_DIR/web' ]; then tar -czf '$BACKUP_DIR/drupal-$ENVIRONMENT-$TIMESTAMP.tar.gz' '$DEPLOY_DIR' || true; fi"

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
    ssh $SSH_OPTS "$DEPLOY_USER@$DEPLOY_HOST" "mkdir -p '$DEPLOY_DIR/web/sites/default/files' '$DEPLOY_DIR/logs' && \
        chown -R www-data:www-data '$DEPLOY_DIR/web/sites/default/files' || true && \
        chmod -R 755 '$DEPLOY_DIR/web/sites/default/files' '$DEPLOY_DIR/logs' || true"

    echo "✓ Vérification des fichiers settings sur serveur..."
    ssh $SSH_OPTS "$DEPLOY_USER@$DEPLOY_HOST" "if [ ! -f '$DEPLOY_DIR/web/sites/default/settings.php' ]; then cp '$DEPLOY_DIR/web/sites/default/default.settings.php' '$DEPLOY_DIR/web/sites/default/settings.php'; fi"
    ssh $SSH_OPTS "$DEPLOY_USER@$DEPLOY_HOST" "if [ ! -f '$DEPLOY_DIR/web/sites/default/settings.local.php' ] && [ -f '$DEPLOY_DIR/web/sites/default/example.settings.local.php' ]; then cp '$DEPLOY_DIR/web/sites/default/example.settings.local.php' '$DEPLOY_DIR/web/sites/default/settings.local.php'; fi"

    echo "✓ Opérations post-déploiement Drupal sur serveur..."
    ssh $SSH_OPTS "$DEPLOY_USER@$DEPLOY_HOST" "cd '$DEPLOY_DIR' && if [ -x 'vendor/bin/drush' ]; then php vendor/bin/drush -y updatedb || true; php vendor/bin/drush -y config:import || true; php vendor/bin/drush cache:rebuild || true; else echo '⚠️ drush non trouvé sur serveur'; fi"
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
        tar -czf "$BACKUP_DIR/drupal-$ENVIRONMENT-$TIMESTAMP.tar.gz" "$DEPLOY_DIR" || true
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
    chown -R www-data:www-data "$DEPLOY_DIR/web/sites/default/files" || true
    chmod -R 755 "$DEPLOY_DIR/web/sites/default/files" || true
    chmod -R 755 "$DEPLOY_DIR/logs" || true

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
        php vendor/bin/drush -y updatedb || true
        php vendor/bin/drush -y config:import || true
        php vendor/bin/drush cache:rebuild || true
    else
        echo "  ⚠️  drush non trouvé, opérations drush ignorées"
    fi
fi

echo "========== DÉPLOIEMENT RÉUSSI =========="
echo "Version déployée à: $DEPLOY_DIR"
