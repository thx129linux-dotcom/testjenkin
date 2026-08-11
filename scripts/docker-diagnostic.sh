#!/bin/bash
# Diagnostic et correction des problèmes Docker

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  🔧 DIAGNOSTIC DOCKER - Troubleshooting                       ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Vérifier Docker
echo "1️⃣  Vérification de Docker..."
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version)
    echo "   ✅ $DOCKER_VERSION"
else
    echo "   ❌ Docker non installé"
    exit 1
fi

# Vérifier si Docker daemon fonctionne
echo ""
echo "2️⃣  Vérification du Docker daemon..."
if docker ps &> /dev/null; then
    echo "   ✅ Docker daemon est en cours d'exécution"
else
    echo "   ❌ Docker daemon n'est pas accessible"
    echo ""
    echo "   Solutions possibles:"
    echo "   - Redémarrer Docker: sudo systemctl restart docker"
    echo "   - Ajouter l'utilisateur au groupe docker:"
    echo "     sudo usermod -aG docker \$USER"
    echo "   - Puis se reconnecter à la session"
    exit 1
fi

# Vérifier Docker Compose
echo ""
echo "3️⃣  Vérification de Docker Compose..."

if docker compose version &> /dev/null 2>&1; then
    COMPOSE_VERSION=$(docker compose version)
    echo "   ✅ Docker Compose V2 détecté: $COMPOSE_VERSION"
    COMPOSE_CMD="docker compose"
elif command -v docker-compose &> /dev/null; then
    COMPOSE_VERSION=$(docker-compose --version)
    echo "   ⚠️  Docker Compose V1 détecté (ancienne version): $COMPOSE_VERSION"
    echo ""
    echo "   Problème possible: docker-compose 1.29.2 a une incompatibilité"
    echo ""
    echo "   Solutions:"
    echo "   A) Installer Docker Compose V2 (recommandé):"
    echo "      sudo apt-get install docker-compose-plugin"
    echo ""
    echo "   B) Mettre à jour docker-compose V1:"
    echo "      sudo curl -L \"https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-\$(uname -s)-\$(uname -m)\" -o /usr/local/bin/docker-compose"
    echo "      sudo chmod +x /usr/local/bin/docker-compose"
    echo ""
    COMPOSE_CMD="docker-compose"
else
    echo "   ❌ Docker Compose n'est pas installé"
    echo ""
    echo "   Installation:"
    echo "   sudo apt-get install docker-compose-plugin"
    exit 1
fi

# Tester docker-compose avec un projet simple
echo ""
echo "4️⃣  Test Docker Compose..."
cd /var/www/testjenkins/drupal

if $COMPOSE_CMD ps &> /dev/null; then
    echo "   ✅ Docker Compose fonctionne correctement"
else
    echo "   ⚠️  Erreur lors de l'exécution de Docker Compose"
    echo ""
    echo "   Essayer:"
    echo "   $COMPOSE_CMD down && $COMPOSE_CMD up -d --build"
fi

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  ✅ DIAGNOSTIC COMPLÉTÉ                                       ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "Prochaines étapes:"
echo "1. Si tous les tests sont verts: ./start.sh"
echo "2. Si des erreurs: suivre les solutions proposées"
echo ""
