# 📚 Drupal CI/CD - Jenkins + GitHub Actions

Projet Drupal **complètement automatisé** avec **CI/CD intégré** via Jenkins et GitHub Actions.

## 🎯 Objectif

Pipeline CI/CD production-ready pour Drupal:

- ✅ Build automatique (Composer)
- ✅ Tests (syntaxe PHP, structure)
- ✅ Installation Drupal automatique
- ✅ Déploiement vers GitHub
- ✅ Docker image build & push
- ✅ Déploiement en production

---

## 🚀 Démarrage en 3 Étapes

### 1️⃣ Configuration

```bash
cd /var/www/testjenkins/drupal
cp .env.example .env
nano .env  # Éditer vos paramètres
```

### 2️⃣ Démarrage des services

```bash
./start.sh
# ou: docker compose up -d --build
```

### 3️⃣ Installation Drupal

```bash
docker compose exec drupal bash
composer install
php vendor/bin/drush site:install standard -y
```

---

## 🌐 Services

| Service | URL                   | Port |
| ------- | --------------------- | ---- |
| Drupal  | http://localhost:8080 | 80   |
| Nginx   | http://localhost:8081 | 80   |
| Jenkins | http://localhost:8084 | 8080 |
| MailHog | http://localhost:8025 | 1025 |
| MariaDB | localhost             | 3307 |
| Redis   | localhost             | 6379 |

---

## 📦 CI/CD Pipelines

### GitHub Actions (Cloud)

- **CI/CD**: Build, test, docker push
- **Deploy**: SSH deployment + health check
- **Install**: Installation Drupal
- **Quality**: Code quality checks

### Jenkins (Local)

- **Jenkinsfile**: Pipeline déclaratif complet
- **Stages**: 10 étapes de build à release
- **GitHub Push**: Tags & releases auto

---

## 📖 Documentation Complète

| Document            | Contenu                         |
| ------------------- | ------------------------------- |
| **README.md**       | Ce fichier - Vue d'ensemble     |
| **GITHUB_SETUP.md** | Configuration GitHub secrets    |
| **DEPLOYMENT.md**   | Guide déploiement (200+ lignes) |
| **SETUP_GUIDE.md**  | Architecture & fichiers         |
| **SUMMARY.md**      | Résumé avec diagrammes          |
| **Jenkinsfile**     | Pipeline Jenkins 10 stages      |

---

## 🔧 Scripts Configuration

```bash
# Configuration GitHub secrets
bash scripts/setup-github.sh

# Configuration Jenkins
bash scripts/setup-jenkins.sh http://localhost:8084

# Setup complet
bash scripts/setup-all.sh
```

---

## 🎓 Pour Commencer

1. **Lire**: [GITHUB_SETUP.md](GITHUB_SETUP.md) - Configuration GitHub
2. **Configurer**: Secrets GitHub + Jenkins credentials
3. **Tester**: Push sur develop pour voir CI/CD en action
4. **Déployer**: Merge sur main pour déploiement production

---

## 📞 Dépannage Rapide

```bash
# Logs Drupal
docker compose logs -f drupal

# Logs Jenkins
docker compose logs -f jenkins

# Status Drupal
docker compose exec drupal drush status

# Accès Jenkins
docker compose exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

---

**Voir les fichiers MD pour documentation complète! 📚**
