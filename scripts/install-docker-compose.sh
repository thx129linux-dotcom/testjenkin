#!/bin/bash
# Installation/upgrade de Docker Compose V2

set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  📦 INSTALLATION DOCKER COMPOSE V2                            ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Vérifier si Docker est installé
if ! command -v docker &> /dev/null; then
    echo "❌ Docker n'est pas installé"
    echo "Installer Docker d'abord: https://docs.docker.com/engine/install/"
    exit 1
fi

echo "✅ Docker détecté"
echo ""

# Vérifier si Docker Compose V2 est déjà installé
if docker compose version &> /dev/null 2>&1; then
    echo "✅ Docker Compose V2 est déjà installé:"
    docker compose version
    exit 0
fi

echo "📦 Installation de Docker Compose V2..."
echo ""

# Détecter le système
OS=$(uname -s)
ARCH=$(uname -m)

# Corriger l'architecture pour les noms de fichier
if [ "$ARCH" = "aarch64" ]; then
    ARCH="arm64"
elif [ "$ARCH" = "x86_64" ]; then
    ARCH="x86_64"
fi

echo "Système: $OS / $ARCH"
echo ""

# Installer via le gestionnaire de paquets si disponible
if [ "$OS" = "Linux" ]; then
    if command -v apt-get &> /dev/null; then
        echo "1️⃣  Détecté: Debian/Ubuntu"
        echo "   Installation via apt-get..."
        sudo apt-get update
        sudo apt-get install -y docker-compose-plugin
        echo "✅ Instalé"
    elif command -v yum &> /dev/null; then
        echo "1️⃣  Détecté: RHEL/CentOS/Fedora"
        echo "   Installation via yum..."
        sudo yum install -y docker-compose-plugin
        echo "✅ Installé"
    elif command -v pacman &> /dev/null; then
        echo "1️⃣  Détecté: Arch Linux"
        echo "   Installation via pacman..."
        sudo pacman -S docker-compose
        echo "✅ Installé"
    else
        echo "⚠️  Gestionnaire de paquets non reconnu"
        echo "   Installation manuelle..."
        DOCKER_VERSION=$(docker version --format '{{.Server.Version}}')
        COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -oP '"tag_name": "\K[^"]*')

        sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-${OS}-${ARCH}" \
            -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        echo "✅ Installé"
    fi
elif [ "$OS" = "Darwin" ]; then
    echo "1️⃣  Détecté: macOS"
    echo "   Docker Desktop pour macOS inclut Docker Compose V2"
    echo "   Mettre à jour Docker Desktop:"
    echo "   https://www.docker.com/products/docker-desktop"
else
    echo "❌ Système non supporté"
    exit 1
fi

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  ✅ INSTALLATION COMPLÉTÉE                                    ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Vérifier l'installation
echo "Vérification:"
docker compose version
echo ""
echo "✅ Docker Compose V2 est maintenant prêt!"
echo ""
