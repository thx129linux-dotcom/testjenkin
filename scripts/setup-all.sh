#!/bin/bash
# Script complet de configuration du projet pour déploiement

set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║   🚀 SETUP COMPLET DRUPAL + JENKINS + GITHUB CI/CD           ║"
echo "╚════════════════════════════════════════════════════════════════╝"

echo ""
echo "📋 ÉTAPE 1: Initialisation Git"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Vérifier que nous sommes dans un repo git
if [ ! -d ".git" ]; then
    echo "Git repository non trouvé. Initialisation..."
    git init
    echo "✅ Repository git créé"
else
    echo "✅ Repository git détecté"
fi

echo ""
echo "📋 ÉTAPE 2: Configuration du répertoire"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Créer les répertoires nécessaires
mkdir -p logs
mkdir -p scripts
mkdir -p web/sites/default/files
mkdir -p private
mkdir -p .github/workflows

chmod +x scripts/*.sh

echo "✅ Répertoires et permissions configurés"

echo ""
echo "📋 ÉTAPE 3: Fichiers de configuration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Vérifier .env
if [ ! -f ".env" ]; then
    cp .env.example .env
    echo "✅ .env créé (à personnaliser)"
else
    echo "✅ .env existe déjà"
fi

# Vérifier .gitignore
if [ ! -f ".gitignore" ]; then
    echo "⚠️ .gitignore manquant"
else
    echo "✅ .gitignore configuré"
fi

echo ""
echo "📋 ÉTAPE 4: Vérification des fichiers essentiels"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

FILES=(
    "Jenkinsfile:Pipeline Jenkins"
    "docker-compose.yml:Orchestration Docker"
    ".github/workflows/ci-cd.yml:GitHub Actions CI/CD"
    ".github/workflows/deploy.yml:GitHub Actions Deploy"
    ".github/workflows/drupal-install.yml:GitHub Actions Drupal Install"
    "scripts/build.sh:Script de build"
    "scripts/deploy.sh:Script de déploiement"
    "scripts/test.sh:Script de tests"
)

for file_info in "${FILES[@]}"; do
    IFS=':' read -r file desc <<< "$file_info"
    if [ -f "$file" ]; then
        echo "✅ $desc"
    else
        echo "⚠️ $file manquant"
    fi
done

echo ""
echo "📋 ÉTAPE 5: Configuration GitHub (manuel)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "Pour configurer GitHub secrets:"
echo "  bash scripts/setup-github.sh"
echo ""
echo "Pour configurer Jenkins:"
echo "  bash scripts/setup-jenkins.sh http://localhost:8084"
echo ""

echo "📋 ÉTAPE 6: Premier déploiement"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "Pour démarrer localement:"
echo "  ./start.sh"
echo ""
echo "Pour installer Drupal:"
echo "  docker compose exec drupal bash"
echo "  composer install"
echo "  php vendor/bin/drush site:install standard -y"
echo ""

echo "📋 ÉTAPE 7: Push vers GitHub"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "Pour pousser vers GitHub:"
echo ""
echo "  git remote add origin https://github.com/YOUR_USERNAME/drupal.git"
echo "  git add ."
echo "  git commit -m 'Initial commit: Drupal + Jenkins + GitHub Actions CI/CD'"
echo "  git branch -M main"
echo "  git push -u origin main"
echo ""

echo "✨ CONFIGURATION COMPLÈTE!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📚 Documentation:"
echo "  - GITHUB_SETUP.md: Configuration GitHub secrets"
echo "  - DEPLOYMENT.md: Guide complet de déploiement"
echo "  - SETUP_GUIDE.md: Architecture du projet"
echo "  - README.md: Accueil du projet"
echo ""
echo "🔗 URLs par défaut:"
echo "  - Drupal: http://localhost:8080"
echo "  - Jenkins: http://localhost:8084"
echo "  - MailHog: http://localhost:8025"
echo ""
echo "✅ Prêt pour CI/CD avec Jenkins + GitHub!"
echo ""
