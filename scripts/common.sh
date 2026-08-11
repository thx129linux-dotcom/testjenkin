#!/bin/bash
# Fichier de configuration commune pour tous les scripts
# À sourcer au début de chaque script: source "scripts/common.sh"

# Détecter la commande Docker Compose correcte
setup_compose_cmd() {
    if command -v docker &> /dev/null && docker compose version &> /dev/null 2>&1; then
        export COMPOSE_CMD="docker compose"
        return 0
    elif command -v docker-compose &> /dev/null; then
        export COMPOSE_CMD="docker-compose"
        return 0
    else
        echo "❌ Docker Compose n'est pas installé"
        echo "   Installer: bash scripts/install-docker-compose.sh"
        return 1
    fi
}

# Couleurs pour la sortie
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonctions utilitaires
info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

# Vérifier les prérequis
check_docker() {
    if ! command -v docker &> /dev/null; then
        error "Docker n'est pas installé"
        return 1
    fi
    success "Docker détecté"
    return 0
}

check_compose() {
    if ! setup_compose_cmd; then
        return 1
    fi
    success "Docker Compose détecté: $COMPOSE_CMD"
    return 0
}

# Get current directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Initialiser automatiquement
setup_compose_cmd || exit 1
