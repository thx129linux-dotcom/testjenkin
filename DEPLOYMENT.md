# Guide de Déploiement Drupal + Jenkins CI/CD

## 📋 Prérequis

- Docker & Docker Compose
- Git
- Accès au serveur de déploiement

## 🚀 Démarrage Rapide

### 1. Clone du Projet

```bash
git clone <repository-url> /var/www/testjenkins/drupal
cd /var/www/testjenkins/drupal
```

### 2. Configuration d'Environnement

```bash
cp .env.example .env
# Éditer .env avec vos paramètres
nano .env
```

### 3. Démarrage des Services Docker

```bash
docker compose up -d --build
```

Cette commande démarre:

- **Drupal** (PHP-FPM): http://localhost:8080
- **Nginx**: http://localhost:80
- **Jenkins**: http://localhost:8084
- **MariaDB**: localhost:3306
- **Redis**: localhost:6379
- **MailHog**: http://localhost:8025

### 4. Installation de Drupal

```bash
docker compose exec drupal bash
cd /var/www/html

# Installer les dépendances
composer install

# Installer Drupal
php vendor/bin/drush site:install standard -y
```

## 🔧 Configuration Jenkins

### 1. Accéder à Jenkins

1. Ouvrir http://localhost:8084
2. Récupérer le mot de passe initial:
   ```bash
   docker compose exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
   ```

### 2. Créer un Nouveau Job

1. **Nouvelle tâche** → **Pipeline**
2. Nom: `drupal-pipeline`
3. Connexion au Git:
   - Repository URL: `file:///var/jenkins_workspace`
   - Branch: `*/main`
4. Définition du Pipeline:
   - Sélectionner **Pipeline script from SCM**
   - Sélectionner **Git**
   - Path to Jenkinsfile: `Jenkinsfile`
5. **Enregistrer** et **Build**

### 3. Credentials

Créer des credentials pour SSH/Déploiement:

```bash
# Générer une clé SSH pour Jenkins
docker compose exec jenkins ssh-keygen -t rsa -N "" -f /var/jenkins_home/.ssh/id_rsa

# Copier la clé publique sur le serveur de déploiement
docker compose exec jenkins cat /var/jenkins_home/.ssh/id_rsa.pub
```

## 📁 Structure du Projet

```
drupal/
├── Jenkinsfile                 # Pipeline Jenkins
├── docker-compose.yml          # Configuration Docker Compose
├── Dockerfile.drupal           # Image Docker Drupal
├── nginx.conf                  # Configuration Nginx
├── default.conf                # Configuration Nginx (vhost)
├── php.ini                     # Configuration PHP
├── .env.example                # Variables d'environnement
├── scripts/
│   ├── build.sh               # Script de build
│   ├── deploy.sh              # Script de déploiement
│   ├── test.sh                # Script de tests
│   └── init-db.sql            # Initialisation BD
├── jenkins/
│   ├── Dockerfile             # Image Jenkins
│   ├── docker-compose.yml     # Ancien compose (remplacé)
│   └── plugins.txt            # Plugins Jenkins
├── web/                        # Drupal Web Root
├── vendor/                     # Dépendances Composer
└── README.md
```

## 🔄 Pipeline Jenkins

Le pipeline CI/CD exécute:

1. **Checkout** - Clone le code
2. **Prepare** - Préparation de l'environnement
3. **Install Dependencies** - Installation Composer
4. **Build** - Construction du projet
5. **Tests** - Validation et tests
6. **Deploy** - Déploiement (branche main)
7. **Post-Deploy** - Migrations et cache

### Exécution Manuelle

```bash
# Build
bash scripts/build.sh develop

# Test
bash scripts/test.sh

# Deploy
bash scripts/deploy.sh production
```

## 📊 Monitoring & Logs

### Logs Jenkins

```bash
docker compose logs -f jenkins
```

### Logs Drupal

```bash
docker compose logs -f drupal
docker compose logs -f nginx
```

### Base de Données

```bash
docker compose exec mariadb mysql -u drupal -pdrupal_password drupal
```

## 🛡️ Sécurité

### Avant la Production

1. Modifier les mots de passe dans `.env`
2. Générer un nouveau `DRUPAL_HASH_SALT`
3. Configurer HTTPS/SSL
4. Configurer les backups
5. Configurer les certificats SSL

```bash
# Générer un hash salt aléatoire
php -r "echo base64_encode(random_bytes(16));"
```

## 📦 Déploiement en Production

### Script de Déploiement SSH

```bash
bash scripts/deploy.sh production
```

### Options d'Environnement

```env
DRUPAL_ENV=production
DRUPAL_HASH_SALT=secure_random_salt_here
DB_HOST=db.example.com
DB_ROOT_PASSWORD=secure_password
```

## 🆘 Troubleshooting

### Jenkins ne démarre pas

```bash
docker compose logs jenkins
docker compose restart jenkins
```

### Drupal inaccessible

```bash
docker compose exec drupal php vendor/bin/drush status
docker compose exec mariadb mysql -u drupal -pdrupal_password drupal -e "SHOW TABLES;"
```

### Problèmes de permissions

```bash
docker compose exec drupal chown -R www-data:www-data web/sites/default/files
docker compose exec drupal chmod -R 755 web/sites/default/files
```

### Vider le cache Drupal

```bash
docker compose exec drupal php vendor/bin/drush cache:rebuild
# ou via Redis
docker compose exec redis redis-cli FLUSHALL
```

## 🔐 Accès aux Services

| Service | URL                   | Port |
| ------- | --------------------- | ---- |
| Drupal  | http://localhost:8080 | 80   |
| Nginx   | http://localhost:80   | 80   |
| Jenkins | http://localhost:8084 | 8080 |
| MailHog | http://localhost:8025 | 1025 |
| MariaDB | localhost             | 3306 |
| Redis   | localhost             | 6379 |

## 📝 Commandes Utiles

```bash
# Rebuild du cache Drupal
docker compose exec drupal drush cache:rebuild

# Import/Export de config
docker compose exec drupal drush config:export
docker compose exec drupal drush config:import

# Sauvegarde BD
docker compose exec mariadb mysqldump -u drupal -pdrupal_password drupal > backup.sql

# Restauration BD
docker compose exec mariadb mysql -u drupal -pdrupal_password drupal < backup.sql

# Status Drupal
docker compose exec drupal drush status
```

## ✅ Checklist Déploiement

- [ ] Clone du projet
- [ ] Configuration .env
- [ ] Docker Compose démarré
- [ ] Drupal installé
- [ ] Jenkins configuré
- [ ] Pipeline créé
- [ ] Credentials Jenkins ajoutées
- [ ] Build de test réussi
- [ ] Permissions Drupal/files correctes
- [ ] Backups configurés
- [ ] HTTPS/SSL configuré (prod)

## 📞 Support

Pour plus d'informations:

- [Documentation Drupal](https://www.drupal.org/docs)
- [Documentation Jenkins](https://www.jenkins.io/doc/)
- [Docker Compose](https://docs.docker.com/compose/)
