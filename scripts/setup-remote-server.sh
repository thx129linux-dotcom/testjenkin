#!/bin/bash
set -euo pipefail

SERVER_IP="${1:-}"
DEPLOY_DIR="${2:-/var/www/drupal-production}"
DB_NAME="${3:-drupal}"
DB_USER="${4:-drupal}"
DB_PASSWORD="${5:-drupal_password_change_me}"
PHP_VERSION="8.3"
APACHE_SITE_NAME="drupal-production"
WEB_ROOT="$DEPLOY_DIR/web"
APACHE_CONF="/etc/apache2/sites-available/${APACHE_SITE_NAME}.conf"

if [ "$(id -u)" -ne 0 ]; then
    echo "❌ Ce script doit être exécuté avec sudo ou en root."
    exit 1
fi

if [ -z "$SERVER_IP" ]; then
    echo "Usage: sudo bash scripts/setup-remote-server.sh <server_ip> [deploy_dir] [db_name] [db_user] [db_password]"
    echo "Exemple: sudo bash scripts/setup-remote-server.sh 149.56.101.183 /var/www/drupal-production drupal drupal 'motdepassefort'"
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

echo "========== PRÉPARATION SERVEUR DISTANT =========="
echo "IP serveur     : $SERVER_IP"
echo "Répertoire web : $WEB_ROOT"
echo "Base MariaDB   : $DB_NAME"
echo "Utilisateur DB : $DB_USER"

echo "✓ Installation des paquets système..."
apt-get update
apt-get install -y \
    apache2 \
    mariadb-server \
    unzip \
    git \
    curl \
    php${PHP_VERSION} \
    php${PHP_VERSION}-cli \
    php${PHP_VERSION}-common \
    php${PHP_VERSION}-mysql \
    php${PHP_VERSION}-gd \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-zip \
    php${PHP_VERSION}-intl \
    php${PHP_VERSION}-bcmath \
    php${PHP_VERSION}-soap \
    php${PHP_VERSION}-opcache \
    libapache2-mod-php${PHP_VERSION}

update-alternatives --set php "/usr/bin/php${PHP_VERSION}" || true

echo "✓ Activation des services..."
systemctl enable apache2
systemctl enable mariadb
systemctl restart apache2
systemctl restart mariadb

echo "✓ Création des répertoires de déploiement..."
mkdir -p "$DEPLOY_DIR"
mkdir -p "$DEPLOY_DIR/web/sites/default/files"
mkdir -p "$DEPLOY_DIR/private"
mkdir -p /var/www/backups

chown -R www-data:www-data "$DEPLOY_DIR/web/sites/default/files"
chmod -R 755 "$DEPLOY_DIR"
chmod -R 775 "$DEPLOY_DIR/web/sites/default/files"

echo "✓ Configuration MariaDB..."
mysql <<SQL
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
SQL

echo "✓ Création du VirtualHost Apache..."
cat > "$APACHE_CONF" <<EOF
<VirtualHost *:80>
    ServerName ${SERVER_IP}
    ServerAlias www.${SERVER_IP}
    DocumentRoot ${WEB_ROOT}

    <Directory ${WEB_ROOT}>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
        DirectoryIndex index.php index.html
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/${APACHE_SITE_NAME}-error.log
    CustomLog \${APACHE_LOG_DIR}/${APACHE_SITE_NAME}-access.log combined
</VirtualHost>
EOF

echo "✓ Activation du site Apache..."
a2enmod rewrite headers
a2enmod "php${PHP_VERSION}" || true
a2ensite "${APACHE_SITE_NAME}.conf"
if [ -f /etc/apache2/sites-enabled/000-default.conf ]; then
    a2dissite 000-default.conf
fi

apache2ctl configtest
systemctl reload apache2

echo "✓ État des services..."
systemctl --no-pager --full status apache2 | sed -n '1,8p'
systemctl --no-pager --full status mariadb | sed -n '1,8p'

echo "========== CONFIGURATION TERMINÉE =========="
echo "DocumentRoot Apache : $WEB_ROOT"
echo "Base MariaDB        : $DB_NAME"
echo "Utilisateur MariaDB : $DB_USER"
echo "VHost Apache        : $APACHE_CONF"
echo ""
echo "Étapes suivantes :"
echo "1. Déployer le code avec Jenkins vers $DEPLOY_DIR"
echo "2. Vérifier settings.php dans $DEPLOY_DIR/web/sites/default"
echo "3. Tester l'accès HTTP: curl -I http://$SERVER_IP"
