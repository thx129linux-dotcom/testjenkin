#!/bin/bash
# Script d'arrêt des services
set -e

echo "🛑 Arrêt des services Drupal + Jenkins..."

# Utiliser docker compose (V2) si disponible, sinon docker-compose (V1)
if command -v docker &> /dev/null && docker compose version &> /dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
elif command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
else
    echo "❌ Docker Compose n'est pas installé"
    exit 1
fi

$COMPOSE_CMD down -v

echo "✅ Services arrêtés"
