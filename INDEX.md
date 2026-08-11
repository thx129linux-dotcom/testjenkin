# 📖 INDEX - Documentation Drupal CI/CD

Guide de navigation pour tous les fichiers du projet.

---

## 🚀 DÉMARRER ICI

### Pour les utilisateurs non-technique

1. **[README.md](README.md)** - Vue d'ensemble simple et rapide

### Pour configurer GitHub

1. **[QUICK_GITHUB_SETUP.sh](QUICK_GITHUB_SETUP.sh)** - Étapes en 5 minutes
2. **[GITHUB_SETUP.md](GITHUB_SETUP.md)** - Configuration détaillée

### Pour comprendre l'architecture

1. **[SETUP_GUIDE.md](SETUP_GUIDE.md)** - Architecture et fichiers
2. **[SUMMARY.md](SUMMARY.md)** - Résumé avec diagrammes

### Pour le déploiement production

1. **[DEPLOYMENT.md](DEPLOYMENT.md)** - Guide complet (200+ lignes)

### Après tout

1. **[FINAL_SUMMARY.md](FINAL_SUMMARY.md)** - Résumé de ce qui a été fait

---

## 🔧 FICHIERS DE CONFIGURATION

### Pipeline CI/CD

| Fichier                                  | Lignes | Description                         |
| ---------------------------------------- | ------ | ----------------------------------- |
| **Jenkinsfile**                          | 199    | Pipeline Jenkins avec 10 stages     |
| **.github/workflows/ci-cd.yml**          | 131    | GitHub Actions: Build & Test        |
| **.github/workflows/deploy.yml**         | 87     | GitHub Actions: Déploiement SSH     |
| **.github/workflows/drupal-install.yml** | 74     | GitHub Actions: Installation Drupal |
| **.github/workflows/quality.yml**        | 58     | Code quality & security checks      |

### Scripts d'Automatisation

| Fichier                      | Description                  |
| ---------------------------- | ---------------------------- |
| **scripts/build.sh**         | Build Drupal + Composer      |
| **scripts/deploy.sh**        | Déploiement SSH avec backup  |
| **scripts/test.sh**          | Tests et validation          |
| **scripts/setup-all.sh**     | Setup complet du projet      |
| **scripts/setup-github.sh**  | Configuration GitHub secrets |
| **scripts/setup-jenkins.sh** | Configuration Jenkins        |
| **start.sh**                 | Démarrer les services Docker |
| **stop.sh**                  | Arrêter les services Docker  |

### Docker & Infrastructure

| Fichier                         | Description                 |
| ------------------------------- | --------------------------- |
| **docker-compose.yml**          | Orchestration 7 services    |
| **docker-compose.override.yml** | Configuration développement |
| **Dockerfile.drupal**           | Image PHP-FPM 8.3 optimisée |
| **jenkins/Dockerfile**          | Image Jenkins avec outils   |
| **nginx.conf**                  | Configuration Nginx         |
| **default.conf**                | Vhost Drupal                |
| **php.ini**                     | Configuration PHP           |

### Configuration

| Fichier                                          | Description                                  |
| ------------------------------------------------ | -------------------------------------------- |
| **.env.example**                                 | Variables d'environnement (à copier en .env) |
| **.gitignore**                                   | Fichiers à ignorer dans Git                  |
| **web/sites/default/example.settings.local.php** | Drupal settings (Redis, Mail, DB)            |

---

## 📚 DOCUMENTATION

### Documentation Principale

| Fichier                   | Longueur   | Contenu                                    |
| ------------------------- | ---------- | ------------------------------------------ |
| **README.md**             | Court      | Vue d'ensemble et démarrage rapide         |
| **QUICK_GITHUB_SETUP.sh** | Très court | Étapes GitHub en 5 minutes                 |
| **GITHUB_SETUP.md**       | Moyen      | Configuration GitHub détaillée             |
| **SETUP_GUIDE.md**        | Moyen      | Architecture et fichiers créés             |
| **DEPLOYMENT.md**         | Long       | Guide complet de déploiement (200+ lignes) |
| **SUMMARY.md**            | Moyen      | Résumé avec diagrammes                     |
| **FINAL_SUMMARY.md**      | Moyen      | Ce qui a été créé et résumé                |
| **INDEX.md**              | Ce fichier | Navigation dans la documentation           |

---

## 🎯 WORKFLOW DE DÉMARRAGE

```
1. README.md (comprendre le projet)
    ↓
2. QUICK_START.sh (démarrer localement)
    ↓
3. Créer repo GitHub
    ↓
4. QUICK_GITHUB_SETUP.sh (configurer GitHub - 5 min)
    ↓
5. GITHUB_SETUP.md (détails si nécessaire)
    ↓
6. Push le code
    ↓
7. Voir GitHub Actions en action
    ↓
8. DEPLOYMENT.md (pour production)
```

---

## 🔄 WORKFLOWS CI/CD

### Déclenché par: Push sur develop/main

```
GitHub Actions (Gratuit):
  1. CI/CD: Build + Test + Docker push
  2. Deploy: SSH deployment + health check
  3. Quality: Code quality checks
  4. Install: Manual trigger pour installer Drupal

Jenkins (Local):
  1. Webhook: Détecte push
  2. 10 Stages: From checkout to release
  3. GitHub Push: Tags et releases auto
```

---

## 📦 SERVICES DISPONIBLES

| Service     | URL                   | Port | Port Web |
| ----------- | --------------------- | ---- | -------- |
| **Drupal**  | http://localhost:8080 | 80   | 8080     |
| **Nginx**   | http://localhost      | 80   | 80       |
| **Jenkins** | http://localhost:8084 | 8080 | 8084     |
| **MailHog** | http://localhost:8025 | 1025 | 8025     |
| **MariaDB** | localhost             | 3306 | -        |
| **Redis**   | localhost             | 6379 | -        |

---

## 🔐 CONFIGURATION GITHUB SECRETS

Voir **GITHUB_SETUP.md** pour la liste complète.

Secrets essentiels:

- `DEPLOY_KEY` - Clé SSH privée
- `DEPLOY_HOST` - Serveur déploiement
- `DEPLOY_USER` - User SSH
- `DEPLOY_PATH` - Path serveur
- `GITHUB_TOKEN` - API token (auto)

---

## 🤖 CONFIGURATION JENKINS

Voir **scripts/setup-jenkins.sh** pour étapes détaillées.

Credentials:

- `github-credentials` - Username/password
- `github-token` - Secret token
- Webhook: `http://localhost:8084/github-webhook/`

---

## 🆘 QUICK TROUBLESHOOTING

### Drupal inaccessible

```bash
docker compose logs drupal
docker compose ps
```

### Jenkins ne démarre pas

```bash
docker compose logs jenkins
docker compose restart jenkins
```

### GitHub Actions échoue

→ Vérifier les secrets dans GitHub Settings

### Déploiement échoue

→ Vérifier DEPLOY_KEY permissions et webhook

---

## 📝 FICHIERS CLÉS PAR RÔLE

### DevOps / Infrastructure

- Jenkinsfile
- docker-compose.yml
- scripts/deploy.sh
- DEPLOYMENT.md

### Developer

- README.md
- SETUP_GUIDE.md
- scripts/build.sh
- scripts/test.sh

### GitHub Admin

- GITHUB_SETUP.md
- .github/workflows/
- QUICK_GITHUB_SETUP.sh

### Manager/Lead

- SUMMARY.md
- FINAL_SUMMARY.md
- DEPLOYMENT.md

---

## ✨ POINTS CLÉS

✅ **1242 lignes de code** de pipeline CI/CD
✅ **10 stages** Jenkins complets
✅ **4 workflows** GitHub Actions
✅ **7 services** Docker orchestrés
✅ **6 guides** documentation
✅ **8 scripts** d'automatisation

---

## 🎓 CONCEPTS IMPORTANTS

### Jenkinsfile

Pipeline déclaratif décrivant tous les stages du build.

### GitHub Actions Workflows

Alternative cloud-native, déclenche sur push/PR automatiquement.

### Docker Compose

Orchestre 7 services (Drupal, Nginx, Jenkins, MariaDB, Redis, MailHog, SSL).

### Drush CLI

Outil d'administration Drupal pour migrations, config, cache.

### Health Checks

Vérifications automatiques après déploiement.

---

## 🚀 PROCHAINES ÉTAPES

1. Lire **README.md**
2. Exécuter **QUICK_START.sh**
3. Créer repo GitHub
4. Exécuter **QUICK_GITHUB_SETUP.sh**
5. Configurer secrets GitHub
6. Pusher le code
7. Voir CI/CD en action
8. Consulter **DEPLOYMENT.md** pour production

---

## 📞 CHEAT SHEET

```bash
# Start/Stop
./start.sh
./stop.sh

# Drupal
docker compose exec drupal drush status
docker compose exec drupal drush cache:rebuild

# Jenkins
docker compose exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword

# Logs
docker compose logs -f [service]

# Git
git tag v1.0.0 && git push origin --tags
```

---

## 🎉 VOUS ÊTES PRÊT!

Tous les fichiers sont en place. Commencez par **README.md**.

Pour des questions: Consultez la documentation appropriée.

Bon déploiement! 🚀
