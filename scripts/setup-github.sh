#!/bin/bash
# Script de configuration GitHub Secrets pour CI/CD

set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  🚀 CONFIGURATION GITHUB SECRETS POUR DRUPAL CI/CD            ║"
echo "╚════════════════════════════════════════════════════════════════╝"

# Récupérer le repo GitHub
GITHUB_REPO=$(git config --get remote.origin.url | sed 's|.*://||' | sed 's|.git||' | sed 's|.*:||')

if [ -z "$GITHUB_REPO" ]; then
    echo "❌ Impossible de récupérer le repository GitHub"
    echo "Assurez-vous que vous êtes dans un repository Git"
    exit 1
fi

echo "📍 Repository: $GITHUB_REPO"
echo ""
echo "Pour configurer les secrets manuellement:"
echo "1. Allez à: https://github.com/$GITHUB_REPO/settings/secrets/actions"
echo "2. Ajoutez les secrets suivants:"
echo ""

# Secrets pour deployment
echo "🔑 SECRETS DEPLOYMENT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. DEPLOY_KEY"
echo "   Description: Clé SSH privée pour déploiement"
echo "   Générer: ssh-keygen -t rsa -N '' -f ~/.ssh/deploy_key"
echo "   Copier: cat ~/.ssh/deploy_key"
echo ""

echo "2. DEPLOY_HOST ou DEPLOY_IP"
echo "   Description: Adresse ou IP du serveur de déploiement"
echo "   Exemple: deploy.example.com ou 203.0.113.10"
echo ""

echo "3. DEPLOY_USER"
echo "   Description: Utilisateur SSH pour déploiement"
echo "   Exemple: drupal"
echo ""

echo "4. DEPLOY_PATH"
echo "   Description: Chemin du déploiement sur le serveur"
echo "   Exemple: /var/www/drupal-production"
echo ""

echo "5. HEALTH_CHECK_URL"
echo "   Description: URL pour vérifier la santé après déploiement"
echo "   Exemple: https://www.example.com/health"
echo ""

# Secrets Jenkins
echo "🤖 SECRETS JENKINS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "6. GITHUB_TOKEN"
echo "   Description: Token GitHub pour GitHub API"
echo "   Générer: https://github.com/settings/tokens"
echo "   Permissions: repo, workflow"
echo ""

echo "7. DRUPAL_ADMIN_PASSWORD"
echo "   Description: Mot de passe admin Drupal initial"
echo "   Générée aléatoirement si non défini"
echo ""

# Database
echo "🗄️  DATABASE SECRETS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "8. DB_PASSWORD"
echo "   Description: Mot de passe base de données"
echo ""

# Docker
echo "🐳 DOCKER REGISTRY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Les images Docker sont poussées vers GitHub Container Registry (GHCR)"
echo "Authentification automatique avec GITHUB_TOKEN"
echo ""

# Environments
echo "🌍 ENVIRONMENTS GITHUB"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Créer deux environments dans GitHub:"
echo "1. https://github.com/$GITHUB_REPO/settings/environments"
echo ""
echo "   Environment: staging"
echo "   - Deployment branches and tags: All branches and tags"
echo "   - Secrets: DEPLOY_KEY, DEPLOY_HOST ou DEPLOY_IP, DEPLOY_USER, DEPLOY_PATH"
echo ""
echo "   Environment: production"
echo "   - Deployment branches and tags: All branches and tags"
echo "   - Required reviewers: Add team members"
echo "   - Secrets: DEPLOY_KEY, DEPLOY_HOST ou DEPLOY_IP, DEPLOY_USER, DEPLOY_PATH"
echo ""

# Jenkins Configuration
echo "🤖 CONFIGURATION JENKINS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Dans Jenkins, créer les credentials suivants:"
echo "1. Manage Jenkins > Manage Credentials"
echo ""
echo "   ID: github-credentials"
echo "   Type: Username with password"
echo "   Username: votre_username_github"
echo "   Password: votre_personal_access_token"
echo ""
echo "   ID: github-token"
echo "   Type: Secret text"
echo "   Secret: votre_personal_access_token"
echo ""

# Commandes pour configurer via CLI
echo "📝 CONFIGURATION VIA CLI (OPTIONNEL)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Installer GitHub CLI: https://cli.github.com"
echo ""
echo "Puis utiliser:"
echo ""
echo "  gh secret set DEPLOY_KEY --body @~/.ssh/deploy_key -R $GITHUB_REPO"
echo "  gh secret set DEPLOY_HOST --body 'deploy.example.com' -R $GITHUB_REPO"
echo "  # ou"
echo "  gh secret set DEPLOY_IP --body '203.0.113.10' -R $GITHUB_REPO"
echo "  gh secret set DEPLOY_USER --body 'drupal' -R $GITHUB_REPO"
echo "  gh secret set DEPLOY_PATH --body '/var/www/drupal' -R $GITHUB_REPO"
echo "  gh secret set GITHUB_TOKEN --body 'votre_token' -R $GITHUB_REPO"
echo ""

# Webhook GitHub
echo "🔗 GITHUB WEBHOOKS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Les workflows GitHub Actions se déclenchent automatiquement:"
echo "- Lors d'un push sur main/develop"
echo "- Lors d'une pull request"
echo "- Via workflow_dispatch manual trigger"
echo ""
echo "✅ Configuration GitHub prête!"
echo ""
echo "📚 Prochaines étapes:"
echo "   1. Configurez les secrets dans GitHub Settings"
echo "   2. Configurez Jenkins credentials"
echo "   3. Testez un push/PR"
echo "   4. Vérifiez les Actions dans GitHub UI"
echo ""
