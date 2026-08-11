#!/bin/bash
# Quick GitHub Setup - Étapes rapides pour configurer GitHub CI/CD

echo "
╔════════════════════════════════════════════════════════════════╗
║  🚀 CONFIGURATION GITHUB RAPIDE - 5 MINUTES                   ║
╚════════════════════════════════════════════════════════════════╝

ℹ️  Ce script affiche les étapes rapides pour configurer GitHub.
   Pour détails complets: voir GITHUB_SETUP.md

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🌐 ÉTAPE 1: Créer Repository GitHub
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Aller à: https://github.com/new
2. Nom: drupal
3. Description: Drupal CI/CD avec Jenkins
4. Initialize: NON (we have existing code)
5. Create repository

Copier le lien du repo (ex: https://github.com/YOUR_USER/drupal.git)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔑 ÉTAPE 2: Générer Personal Access Token
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. GitHub.com > Settings > Developer settings > Personal access tokens
2. Tokens (classic) > Generate new token (classic)
3. Nom: Jenkins Drupal CI/CD
4. Scopes:
   ✓ repo
   ✓ admin:repo_hook
   ✓ workflow

⚠️  Copier le token immédiatement (vous ne pourrez plus le voir)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📤 ÉTAPE 3: Push le code sur GitHub
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

cd /var/www/testjenkins/drupal

git remote add origin https://github.com/YOUR_USER/drupal.git
git add .
git commit -m \"Initial commit: Drupal CI/CD complete\"
git branch -M main
git push -u origin main

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔐 ÉTAPE 4: Configurer GitHub Secrets
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. GitHub.com > YOUR_REPO > Settings > Secrets and variables > Actions

2. New repository secret > Ajouter:

   DEPLOY_HOST = votre_serveur.com
   DEPLOY_USER = drupal
   DEPLOY_PATH = /var/www/drupal-production
   DEPLOY_KEY  = [Clé SSH privée]
   GITHUB_TOKEN = [Token personnel créé]

(Voir GITHUB_SETUP.md pour détails complets)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ ÉTAPE 5: Vérifier GitHub Actions
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. GitHub.com > YOUR_REPO > Actions

Vous devriez voir les workflows:
  ✓ CI/CD Drupal - Build & Test
  ✓ Deploy to Production
  ✓ Install Drupal
  ✓ Code Quality & Security

Si push sur main > Cliquer sur le workflow en cours > Voir logs

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🤖 ÉTAPE 6 (Optionnel): Configurer Jenkins
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Jenkins.com > http://localhost:8084

2. Manage Jenkins > Manage Credentials

3. Add credential (Username with password):
   Username: YOUR_GITHUB_USER
   Password: YOUR_PERSONAL_TOKEN
   ID: github-credentials

4. New Item > drupal-pipeline > Pipeline
   - Configuration du Git repo
   - Branch: develop, main
   - Script path: Jenkinsfile

5. GitHub > Webhook Settings:
   Payload URL: http://localhost:8084/github-webhook/
   Content type: application/json
   Triggers: Push, Pull requests

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 COMMANDS RAPIDES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# SSH Keygen pour DEPLOY_KEY
ssh-keygen -t rsa -N '' -f ~/.ssh/deploy_key
cat ~/.ssh/deploy_key

# Ajouter clé publique sur serveur
cat ~/.ssh/deploy_key.pub >> ~/.ssh/authorized_keys

# Créer une branche et pusher
git checkout -b feature/my-feature
git push -u origin feature/my-feature

# Tag et release
git tag v1.0.0
git push origin --tags

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✨ C'EST PRÊT!

Workflows disponibles:
  1️⃣  CI/CD: À chaque push sur main/develop
  2️⃣  Deploy: À chaque tag de release
  3️⃣  Install: Manuel (workflow_dispatch)
  4️⃣  Quality: Code quality checks

📚 Pour plus de détails: GITHUB_SETUP.md

"
