FROM jenkins/jenkins:lts-jdk17

USER root

# Installation des dépendances système
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    unzip \
    zip \
    rsync \
    openssh-client \
    openssh-server \
    ca-certificates \
    build-essential \
    \
    # PHP et extensions
    php-cli \
    php-xml \
    php-mbstring \
    php-curl \
    php-gd \
    php-mysql \
    php-pgsql \
    php-sqlite3 \
    php-zip \
    php-intl \
    php-bcmath \
    php-json \
    php-dom \
    php-tokenizer \
    \
    # Outils supplémentaires
    mariadb-client \
    postgresql-client \
    docker.io \
    && rm -rf /var/lib/apt/lists/*

# Composer - Dernière version
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    chmod +x /usr/local/bin/composer

# Drush - téléchargement direct
RUN curl -L -o /usr/local/bin/drush https://github.com/drush-ops/drush-launcher/releases/latest/download/drush.phar && \
    chmod +x /usr/local/bin/drush || echo "Drush optionnel - installé via composer dans les projets"

# Copier la liste des plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt

# Installer les plugins Jenkins
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

# Configuration SSH
RUN mkdir -p /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# Ajuster les permissions Docker
RUN usermod -aG docker jenkins

# Création des répertoires de travail
RUN mkdir -p /var/jenkins_home/workspace && \
    chown -R jenkins:jenkins /var/jenkins_home

USER jenkins

# Télécharger les outils Jenkins CLI
RUN curl -fsSL https://github.com/jenkinsci/jenkins-cli/releases/latest | grep -oP 'href="\K[^"]*jenkins-cli.jar' | head -1 | xargs -I {} curl -fsSL -o /usr/share/jenkins/jenkins-cli.jar https://github.com{}

EXPOSE 8080 50000


