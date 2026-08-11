# 🚀 Configuration GitHub Secrets & Deployment

## 📋 Secrets Requis dans GitHub

### 1. Aller à Settings > Secrets and variables > Actions

### 2. Ajouter les secrets suivants:

#### 🔑 Deployment Secrets

**`DEPLOY_KEY`** (Requis)

- Type: SSH private key
- Générer: `ssh-keygen -t rsa -N '' -f ~/.ssh/deploy_key`
- Ajouter la clé publique au serveur: `~/.ssh/authorized_keys`

**`DEPLOY_HOST`** (Requis)

- Exemple: `deploy.example.com`
- Adresse du serveur de production

**`DEPLOY_USER`** (Requis)

- Exemple: `drupal`
- Utilisateur SSH pour le déploiement

**`DEPLOY_PATH`** (Requis)

- Exemple: `/var/www/drupal-production`
- Chemin du déploiement sur le serveur

**`HEALTH_CHECK_URL`** (Optionnel)

- Exemple: `https://www.example.com/health`
- URL pour vérifier la santé après déploiement

#### 🔐 Authentification

**`GITHUB_TOKEN`** (Auto-disponible)

- Générée automatiquement par GitHub
- Utilisée pour push, releases, etc.

#### 🗄️ Database (si nécessaire pour Actions)

**`DB_PASSWORD`**

- Mot de passe base de données

#### 🐳 Docker (optionnel)

**`DOCKER_USERNAME`** & **`DOCKER_PASSWORD`**

- Pour pousser les images sur Docker Hub
- Optionnel si vous utilisez GitHub Container Registry

---

## 🌍 Environments GitHub

1. Créer deux environments: **staging** et **production**
2. Pour production: Ajouter des reviewers requis
3. Dans chaque environment, ajouter les secrets spécifiques

### Staging Environment

```
Settings > Environments > New environment
Name: staging
Required reviewers: Laisser vide
Secrets: DEPLOY_KEY, DEPLOY_HOST, DEPLOY_USER, DEPLOY_PATH
```

### Production Environment

```
Settings > Environments > New environment
Name: production
Required reviewers: Ajouter vos reviewers
Secrets: DEPLOY_KEY, DEPLOY_HOST, DEPLOY_USER, DEPLOY_PATH
```

---

## 🤖 Configuration Jenkins

### 1. Credentials Jenkins

**Pour GitHub:**

```
Manage Jenkins > Manage Credentials > Add Credential

Type: Username with password
Username: votre_github_username
Password: votre_personal_access_token
ID: github-credentials
```

**Token GitHub:**

```
Type: Secret text
Secret: votre_personal_access_token
ID: github-token
```

### 2. GitHub Webhook

1. GitHub Repo > Settings > Webhooks > Add webhook
2. Payload URL: `http://jenkins-url:8084/github-webhook/`
3. Content type: `application/json`
4. Events: Push events, Pull requests

### 3. Job Configuration

```
New Item > drupal-pipeline > Pipeline

Configuration:
- GitHub project: https://github.com/YOUR_USER/drupal
- Trigger: GitHub hook trigger for GITScm polling
- Pipeline: Pipeline script from SCM
  - SCM: Git
  - Repository: https://github.com/YOUR_USER/drupal.git
  - Script Path: Jenkinsfile
```

---

## 📚 Workflows GitHub Actions

### 1. **CI/CD Pipeline** (`.github/workflows/ci-cd.yml`)

- Déclenché sur: push main/develop, PR
- Teste le code, compile, build Docker image
- Pousse l'image vers GHCR

### 2. **Deploy** (`.github/workflows/deploy.yml`)

- Déclenché sur: push main avec tags
- Déploie via SSH sur le serveur
- Health check après déploiement
- Exécute migrations drush

### 3. **Install Drupal** (`.github/workflows/drupal-install.yml`)

- Manual trigger (workflow_dispatch)
- Installe une nouvelle instance Drupal
- Commit les settings générés

### 4. **Code Quality** (`.github/workflows/quality.yml`)

- Vérifie syntaxe PHP
- Exécute PHPStan
- Vérifications de sécurité

---

## 🔑 Générer un Personal Access Token GitHub

1. GitHub.com > Settings > Developer settings > Personal access tokens > Tokens (classic)
2. Generate new token (classic)
3. Nom: `Jenkins Drupal CI/CD`
4. Expiration: 90 jours ou No expiration
5. Scopes:
   - ✓ `repo` (Full control of private repositories)
   - ✓ `admin:repo_hook` (Full control of repository hooks)
   - ✓ `workflow` (Update GitHub Action workflows)
6. Generate token
7. **Copier le token immédiatement** (vous ne pourrez plus le voir)

---

## 🔄 Flux de Déploiement

### Développement

1. Push sur branche `develop`
2. GitHub Actions lance CI/CD
3. Tests + build
4. Image Docker push sur GHCR

### Staging

1. Créer une release
2. Tagger: `staging-*`
3. GitHub Actions déploie sur staging
4. Health check

### Production

1. Merger sur `main`
2. Créer une tag de release: `v1.0.0`
3. GitHub Actions déploie si autorisé
4. Drush migrations auto

---

## ✅ Checklist Setup

- [ ] Secrets GitHub configurés
- [ ] Environments créés (staging + production)
- [ ] Jenkins Webhook configuré
- [ ] Jenkins Credentials ajoutées
- [ ] GitHub Personal Access Token généré
- [ ] Clé SSH de déploiement créée
- [ ] Authorized_keys sur serveur de déploiement
- [ ] Test push sur develop
- [ ] Test workflow manuellement
- [ ] Vérifier logs GitHub Actions
- [ ] Vérifier logs Jenkins
- [ ] Déploiement en staging OK
- [ ] Déploiement en production prêt

---

## 📞 Dépannage

### Le workflow ne se déclenche pas

- Vérifier le webhook dans GitHub Settings
- Vérifier les logs GitHub Actions (Actions tab)
- Vérifier que le fichier `.github/workflows/*.yml` existe

### Déploiement échoue

- Vérifier DEPLOY_KEY (permissions 600)
- Vérifier que la clé publique est dans `~/.ssh/authorized_keys`
- Tester SSH manuel: `ssh -i key.pem user@host`

### Jenkins ne build pas

- Vérifier que le webhook est configuré
- Vérifier Jenkins URL dans GitHub Webhook
- Vérifier les logs Jenkins

---

## 🎉 Prêt!

Tous les workflows sont maintenant configurés. À chaque push:

1. GitHub Actions teste le code
2. Si OK, build l'image Docker
3. Si sur main: déploie automatiquement (ou attend approbation pour prod)
4. Exécute migrations Drupal
5. Vérifie la santé du site
