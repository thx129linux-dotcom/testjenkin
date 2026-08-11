#!/bin/bash
# README - Démarrage Rapide

echo "
╔════════════════════════════════════════════════════════════════╗
║   🚀 DRUPAL + JENKINS CI/CD - DÉMARRAGE RAPIDE               ║
╚════════════════════════════════════════════════════════════════╝

📋 CONFIGURATION INITIALE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
"

# Vérifier que .env existe
if [ ! -f ".env" ]; then
    echo "1️⃣  Créer la configuration .env"
    echo "   cp .env.example .env"
    echo "   nano .env  # Éditer avec vos paramètres"
else
    echo "✅ .env existe déjà"
fi

echo "
2️⃣  Démarrer les services Docker"
echo "   ./start.sh"
echo "   # ou: docker compose up -d --build"

echo "
3️⃣  Installer Drupal"
echo "   docker compose exec drupal bash"
echo "   cd /var/www/html"
echo "   composer install"
echo "   php vendor/bin/drush site:install standard -y"

echo "
🌐 ACCÈS AUX SERVICES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📍 Drupal:   http://localhost:8080
📍 Jenkins:  http://localhost:8084
📍 MailHog:  http://localhost:8025
📍 MariaDB:  localhost:3306 (User: drupal)
📍 Redis:    localhost:6379

📚 DOCUMENTATION COMPLÈTE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📖 SETUP_GUIDE.md      - Guide d'architecture et fichiers créés
📖 DEPLOYMENT.md       - Guide complet de déploiement
📖 Jenkinsfile         - Pipeline CI/CD déclaratif

🔧 COMMANDES UTILES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Logs
docker compose logs -f drupal
docker compose logs -f jenkins
docker compose logs -f nginx

# Drupal
docker compose exec drupal drush status
docker compose exec drupal drush cache:rebuild

# Jenkins - Password initial
docker compose exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword

# Arrêter
./stop.sh

📦 FICHIERS CRÉÉS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ Jenkinsfile                    - Pipeline CI/CD
✓ docker-compose.yml             - Orchestration services
✓ docker-compose.override.yml    - Configuration développement
✓ Dockerfile.drupal              - Image PHP-FPM
✓ jenkins/Dockerfile             - Image Jenkins améliorée
✓ nginx.conf + default.conf      - Configuration web
✓ php.ini                        - Configuration PHP
✓ scripts/build.sh               - Script de build
✓ scripts/deploy.sh              - Script de déploiement
✓ scripts/test.sh                - Tests et validation
✓ .env.example                   - Template configuration
✓ web/sites/default/example.settings.local.php
✓ DEPLOYMENT.md                  - Guide complet
✓ SETUP_GUIDE.md                 - Guide d'architecture

✨ PRÊT POUR LA PRODUCTION!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Tous les fichiers nécessaires sont prêts.
Il suffit de configurer .env et démarrer!

Questions? Voir DEPLOYMENT.md

"
