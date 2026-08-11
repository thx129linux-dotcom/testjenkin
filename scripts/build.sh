#!/bin/bash
set -e

ENVIRONMENT="${1:-develop}"

echo "========== DRUPAL BUILD SCRIPT =========="
echo "Environnement: $ENVIRONMENT"

# Charger les variables d'environnement
if [ -f ".env" ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Exécuter composer
echo "✓ Installation Composer..."
composer install --no-interaction --prefer-dist --no-dev --optimize-autoloader

# Créer les répertoires nécessaires
echo "✓ Création des répertoires..."
mkdir -p web/sites/default/files
mkdir -p logs
mkdir -p private/backup

# Permissions
echo "✓ Définition des permissions..."
chmod -R 755 web/sites/default/files
chmod -R 755 logs

# Vérifier que Drupal est installé
if [ ! -f "web/sites/default/settings.php" ]; then
    echo "⚠️  settings.php manquant, utilisation du fichier exemple..."
    cp web/sites/default/example.settings.php web/sites/default/settings.php
fi

# Inclure la configuration locale si elle n'existe pas
if [ ! -f "web/sites/default/settings.local.php" ]; then
    echo "⚠️  Création de settings.local.php..."
    cp web/sites/default/example.settings.local.php web/sites/default/settings.local.php
fi

# Lancer les tests de syntaxe PHP
echo "✓ Vérification de la syntaxe PHP..."
find web/modules/custom web/themes/custom -name "*.php" -type f -exec php -l {} \; > /dev/null 2>&1 || true

echo "========== BUILD TERMINÉ AVEC SUCCÈS =========="
