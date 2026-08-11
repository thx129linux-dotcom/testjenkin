#!/bin/bash
set -e

echo "========== DRUPAL TEST SCRIPT =========="

# Charger les variables d'environnement
if [ -f ".env" ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Test 1: Vérification de la syntaxe PHP
echo "✓ Vérification de la syntaxe PHP..."
ERRORS=0
for file in $(find web/modules/custom web/themes/custom -name "*.php" -type f 2>/dev/null | head -50); do
    if ! php -l "$file" > /dev/null 2>&1; then
        echo "❌ ERREUR: Syntaxe invalide dans $file"
        ((ERRORS++))
    fi
done

if [ $ERRORS -gt 0 ]; then
    echo "❌ $ERRORS erreurs de syntaxe trouvées"
    exit 1
fi

# Test 2: Vérification de la structure
echo "✓ Vérification de la structure Drupal..."
if [ ! -f "web/index.php" ]; then
    echo "❌ ERREUR: web/index.php manquant"
    exit 1
fi

if [ ! -d "web/core" ]; then
    echo "❌ ERREUR: web/core manquant"
    exit 1
fi

# Test 3: Validation du composer.lock
echo "✓ Vérification de composer.lock..."
if ! composer validate --no-check-publish > /dev/null 2>&1; then
    echo "❌ ERREUR: composer.json invalide"
    exit 1
fi

# Test 4: Vérification des modules custom
echo "✓ Vérification des modules custom..."
for module_dir in web/modules/custom/*/; do
    if [ -f "${module_dir}${module_dir##*/}.info.yml" ]; then
        echo "  ✓ Module: $(basename "$module_dir")"
    fi
done

echo "========== TOUS LES TESTS RÉUSSIS =========="
