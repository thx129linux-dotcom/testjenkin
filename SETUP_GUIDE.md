# Drupal + Jenkins CI/CD Deployment Configuration

# Configuration de déploiement Drupal avec Jenkins en Docker

## 🎯 Meilleure Méthode de Déploiement

Cette solution suit les meilleures pratiques:

### ✅ Architecture

- **Containerisation complète** (Docker/Docker Compose)
- **Pipeline CI/CD déclaratif** (Jenkinsfile)
- **Séparation des environnements** (dev/staging/prod)
- **Orchestration de services** (Drupal + Nginx + MariaDB + Redis + Jenkins)

### ✅ Sécurité

- Variables d'environnement pour les secrets
- Permissions correctes sur les fichiers
- Configuration des trusted hosts
- SSL/HTTPS supporté

### ✅ Performance

- Redis pour le cache
- OpCache PHP
- Compression Nginx
- Images Alpine optimisées

### ✅ Scalabilité

- Volumes Docker persistants
- Health checks sur tous les services
- Stratégies de restart
- Logging centralisé

---

## 📦 Fichiers Créés

### 1. **Jenkinsfile** (Pipeline CI/CD)

Pipeline déclaratif avec stages:

- Checkout
- Prepare
- Install Dependencies
- Build
- Tests
- Deploy
- Post-Deploy

### 2. **Scripts de Build/Deploy**

- `scripts/build.sh` - Construction du projet
- `scripts/deploy.sh` - Déploiement vers production
- `scripts/test.sh` - Tests et validation

### 3. **Configuration Docker**

- `docker-compose.yml` - Orchestration complète
- `Dockerfile.drupal` - Image PHP-FPM optimisée
- `jenkins/Dockerfile` - Jenkins avec outils Drupal
- `nginx.conf` - Configuration Nginx
- `default.conf` - Vhost Drupal
- `php.ini` - Configuration PHP

### 4. **Configuration Drupal**

- `web/sites/default/example.settings.local.php` - Settings Drupal
- `.env.example` - Variables d'environnement
- `jenkins/plugins.txt` - Plugins Jenkins

### 5. **Documentation**

- `DEPLOYMENT.md` - Guide complet de déploiement

---

## 🚀 Commandes Rapides

### Démarrage

```bash
cp .env.example .env
# Éditer .env avec vos paramètres
docker compose up -d --build
```

### Installation Drupal

```bash
docker compose exec drupal bash
composer install
php vendor/bin/drush site:install standard -y
```

### Jenkins

- URL: http://localhost:8084
- Password initial: `docker compose exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword`

---

## 🔧 Services Actifs

| Service      | URL                   | Port |
| ------------ | --------------------- | ---- |
| Drupal/Nginx | http://localhost:8080 | 80   |
| Jenkins      | http://localhost:8084 | 8080 |
| MailHog      | http://localhost:8025 | 1025 |
| MariaDB      | localhost             | 3306 |
| Redis        | localhost             | 6379 |

---

## ✨ Points Clés

✅ **Pipeline automatisé** - Jenkinsfile gère tout le CI/CD
✅ **Tests intégrés** - Validation de syntaxe PHP
✅ **Déploiement facile** - Scripts shell prêts
✅ **Environnements multiples** - develop/staging/production
✅ **Haute disponibilité** - Health checks + restart policies
✅ **Documentation complète** - DEPLOYMENT.md

---

## 📝 Prochaines Étapes

1. Modifier `.env` avec vos paramètres
2. Lancer `docker compose up -d --build`
3. Installer Drupal via Drush
4. Configurer Jenkins avec le repository Git
5. Tester le pipeline
6. Adapter les scripts au contexte de production

---

Voir **DEPLOYMENT.md** pour le guide complet.
