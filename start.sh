#!/bin/bash
# Script de démarrage du projet Drupal + Jenkins
set -e

echo "🚀 Démarrage du projet Drupal + Jenkins CI/CD"
echo "=============================================="

# Vérifier les prérequis
if ! command -v docker &> /dev/null; then
    echo "❌ Docker n'est pas installé"
    exit 1
fi

# Utiliser docker compose (V2) si disponible, sinon docker-compose (V1)
if command -v docker &> /dev/null && docker compose version &> /dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
    echo "✅ Utilisation de Docker Compose V2"
elif command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
    echo "⚠️  Utilisation de Docker Compose V1 (version ancienne)"
else
    echo "❌ Docker Compose n'est pas installé"
    echo "   Installer: apt-get install docker-compose-plugin"
    exit 1
fi

# Créer .env s'il n'existe pas
if [ ! -f ".env" ]; then
    echo "📝 Création de .env..."
    cp .env.example .env
    echo "⚠️  Veuillez éditer .env avec vos paramètres"
fi

# Créer les répertoires nécessaires
echo "📁 Création des répertoires..."
mkdir -p scripts
mkdir -p web/sites/default/files
mkdir -p logs
mkdir -p private

# Permissions
chmod +x scripts/*.sh

# Arrêter les services existants
echo "🛑 Arrêt des services existants..."
$COMPOSE_CMD down 2>/dev/null || true

# Build et démarrage
echo "🔨 Construction des images Docker..."
$COMPOSE_CMD up -d --build

# Attendre que les services soient prêts
echo "⏳ Attente du démarrage des services..."
sleep 10

# Vérifications
echo "✅ Vérification des services..."
$COMPOSE_CMD ps

echo ""
echo "✅ DÉMARRAGE RÉUSSI!"
echo ""
echo "📋 Étapes suivantes:"
echo ""
echo "1️⃣  Accéder à Drupal:"
echo "   http://localhost:8080"
echo ""
echo "2️⃣  Accéder à Jenkins:"
echo "   http://localhost:8084"
echo "   Password: $($COMPOSE_CMD exec -T jenkins cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null || echo 'À récupérer')"
echo ""
echo "3️⃣  Installer Drupal:"
echo "   docker compose exec drupal bash"
echo "   composer install"
echo "   php vendor/bin/drush site:install standard -y"
echo ""
echo "4️⃣  Services disponibles:"
echo "   - Drupal: http://localhost:8080"
echo "   - Jenkins: http://localhost:8084"
echo "   - MailHog: http://localhost:8025"
echo "   - MariaDB: localhost:3306"
echo "   - Redis: localhost:6379"
echo ""
