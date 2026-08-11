pipeline {
    agent any

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timestamps()
        timeout(time: 60, unit: 'MINUTES')
        disableConcurrentBuilds()
    }

    parameters {
        choice(name: 'ENVIRONMENT', choices: ['develop', 'staging', 'production'], description: 'Environnement de déploiement')
        booleanParam(name: 'RUN_TESTS', defaultValue: true, description: 'Exécuter les tests')
        booleanParam(name: 'INSTALL_DRUPAL', defaultValue: false, description: 'Installer Drupal frais')
        booleanParam(name: 'PUSH_GITHUB', defaultValue: true, description: 'Push vers GitHub après build')
        booleanParam(name: 'CREATE_RELEASE', defaultValue: false, description: 'Créer une release GitHub')
        string(name: 'SERVER_IP', defaultValue: '', description: 'IP du serveur cible (ex: 203.0.113.10)')
        string(name: 'DEPLOY_USER', defaultValue: 'deploy', description: 'Utilisateur SSH du serveur cible')
        string(name: 'DEPLOY_PATH', defaultValue: '/var/www/drupal-production', description: 'Répertoire de déploiement sur le serveur')
    }

    environment {
        BUILD_TIMESTAMP = sh(script: "date +%Y%m%d_%H%M%S", returnStdout: true).trim()
        GIT_COMMIT_SHORT = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
        GITHUB_REPO = sh(script: "git config --get remote.origin.url | sed 's|.*/||' | sed 's|\\.git||'", returnStdout: true).trim()
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    env.BUILD_VERSION = sh(script: 'git describe --tags --always 2>/dev/null || echo "v1.0.0"', returnStdout: true).trim()
                    env.BRANCH_NAME = sh(script: 'git rev-parse --abbrev-ref HEAD', returnStdout: true).trim()
                }
                echo "✅ Checkout complété"
                echo "   Branche: ${env.BRANCH_NAME}"
                echo "   Version: ${env.BUILD_VERSION}"
                echo "   Commit: ${env.GIT_COMMIT_SHORT}"
            }
        }

        stage('Prepare') {
            steps {
                script {
                    echo "========== PRÉPARATION BUILD =========="
                    echo "Version: ${env.BUILD_VERSION}"
                    echo "Environnement: ${params.ENVIRONMENT}"
                    echo "Timestamp: ${env.BUILD_TIMESTAMP}"
                }
                sh '''
                    # Vérifier que les fichiers essentiels existent
                    if [ ! -f "composer.json" ]; then
                        echo "❌ ERREUR: composer.json manquant!"
                        exit 1
                    fi

                    # Créer les répertoires de logs
                    mkdir -p logs
                    mkdir -p web/sites/default/files
                    mkdir -p private
                    chmod -R 755 web/sites/default/files

                    echo "✅ Répertoires créés"
                '''
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                    echo "========== INSTALLATION DES DÉPENDANCES =========="
                    composer install --no-interaction --prefer-dist --no-dev --optimize-autoloader
                    echo "✅ Dépendances installées"
                '''
            }
        }

        stage('Install Drupal') {
            when {
                expression { params.INSTALL_DRUPAL == true }
            }
            steps {
                sh '''
                    echo "========== INSTALLATION DE DRUPAL =========="

                    # Créer/copier settings.php
                    if [ ! -f "web/sites/default/settings.php" ]; then
                        echo "Création de settings.php..."
                        cp web/sites/default/default.settings.php web/sites/default/settings.php
                        chmod 644 web/sites/default/settings.php
                    fi

                    # Créer settings.local.php
                    if [ ! -f "web/sites/default/settings.local.php" ]; then
                        echo "Création de settings.local.php..."
                        cp web/sites/default/example.settings.local.php web/sites/default/settings.local.php
                    fi

                    # Installer Drupal
                    php vendor/bin/drush site:install standard -y \
                        --db-url=mysql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}/${DB_NAME} \
                        --site-name="Drupal CI/CD" \
                        --account-name=admin \
                        --account-pass=admin123 || echo "⚠️ Drupal déjà installé"

                    echo "✅ Drupal installé/configuré"
                '''
            }
        }

        stage('Build') {
            steps {
                sh '''
                    echo "========== BUILD =========="
                    bash scripts/build.sh ${ENVIRONMENT}
                    echo "✅ Build complété"
                '''
            }
        }

        stage('Tests') {
            when {
                expression { params.RUN_TESTS == true }
            }
            steps {
                sh '''
                    echo "========== TESTS =========="
                    bash scripts/test.sh
                    echo "✅ Tests réussis"
                '''
            }
        }

        stage('Deploy') {
            when {
                branch 'main'
                expression { params.ENVIRONMENT == 'production' }
            }
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'deploy-key', keyFileVariable: 'SSH_KEY_FILE', usernameVariable: 'SSH_CREDENTIAL_USER')]) {
                    sh '''
                        echo "========== DÉPLOIEMENT =========="

                        # Priorité à l'utilisateur saisi en paramètre, sinon à celui du credential.
                        DEPLOY_USER_EFFECTIVE="${DEPLOY_USER}"
                        if [ -z "$DEPLOY_USER_EFFECTIVE" ]; then
                            DEPLOY_USER_EFFECTIVE="${SSH_CREDENTIAL_USER}"
                        fi

                        bash scripts/deploy.sh "${ENVIRONMENT}" "${SERVER_IP}" "${DEPLOY_USER_EFFECTIVE}" "${DEPLOY_PATH}" "${SSH_KEY_FILE}"
                        echo "✅ Déploiement complété"
                    '''
                }
            }
        }

        stage('Post-Deploy') {
            when {
                branch 'main'
                expression { params.ENVIRONMENT == 'production' }
            }
            steps {
                sh '''
                    echo "========== POST-DÉPLOIEMENT =========="

                    # Exécuter les migrations
                    php vendor/bin/drush updatedb -y || true

                    # Exécuter les imports de config
                    php vendor/bin/drush config:import -y || true

                    # Reconstruire le cache
                    php vendor/bin/drush cache:rebuild || true

                    echo "✅ Post-déploiement complété"
                '''
            }
        }

        stage('Push GitHub') {
            when {
                expression { params.PUSH_GITHUB == true }
                branch 'develop|main'
            }
            steps {
                withCredentials([gitUsernamePassword(credentialsId: 'github-credentials', gitToolName: 'Default')]) {
                    sh '''
                        echo "========== PUSH GITHUB =========="

                        # Vérifier que le repo remote est bien configuré
                        git remote -v >/dev/null 2>&1 || {
                            echo "❌ Aucun remote Git configuré sur ce dépôt Jenkins."
                            exit 1
                        }

                        # Configurer Git
                        git config user.name "Jenkins CI"
                        git config user.email "jenkins@example.com"

                        # Stabiliser les variables utiles
                        BRANCH_NAME="${BRANCH_NAME:-$(git rev-parse --abbrev-ref HEAD)}"

                        # Ajouter seulement les fichiers du projet qui ont changé
                        # et ignorer les artefacts générés localement
                        git add -A -- . \
                            ':(exclude)vendor' \
                            ':(exclude)web/sites/default/files' \
                            ':(exclude)logs' \
                            ':(exclude)private' \
                            ':(exclude).env' \
                            ':(exclude).gitignore' || true

                        if ! git diff --cached --quiet; then
                            git commit -m "Jenkins build ${BUILD_TIMESTAMP} - ${GIT_COMMIT_SHORT}"
                            git push origin "$BRANCH_NAME" --quiet
                            echo "✅ Commit et push de la branche effectués"
                        else
                            echo "ℹ️ Aucune modification Git à pousser pour cette branche."
                        fi

                        # Créer un tag avec le timestamp
                        git tag -a "build-${BUILD_TIMESTAMP}" -m "Build ${BUILD_TIMESTAMP} - ${GIT_COMMIT_SHORT}" || true
                        git push origin --tags --quiet || true

                        echo "✅ Push GitHub complété"
                    '''
                }
            }
        }

        stage('Create Release') {
            when {
                expression { params.CREATE_RELEASE == true }
                branch 'main'
            }
            steps {
                withCredentials([string(credentialsId: 'github-token', variable: 'GITHUB_TOKEN')]) {
                    sh '''
                        echo "========== CRÉATION RELEASE =========="

                        RELEASE_TAG="release-${BUILD_TIMESTAMP}"
                        RELEASE_NOTES="Build automatique Jenkins\\n\\nVersion: ${BUILD_VERSION}\\nCommit: ${GIT_COMMIT_SHORT}\\nEnvironnement: ${ENVIRONMENT}"

                        # Créer release via GitHub API
                        curl -s -X POST \
                            -H "Authorization: token ${GITHUB_TOKEN}" \
                            -H "Accept: application/vnd.github.v3+json" \
                            "https://api.github.com/repos/${GIT_USERNAME}/${GITHUB_REPO}/releases" \
                            -d "{\"tag_name\":\"${RELEASE_TAG}\",\"target_commitish\":\"main\",\"name\":\"Release ${BUILD_TIMESTAMP}\",\"body\":\"${RELEASE_NOTES}\",\"draft\":false,\"prerelease\":false}" || echo "⚠️ Release creation échouée"

                        echo "✅ Release créée: ${RELEASE_TAG}"
                    '''
                }
            }
        }
    }

    post {
        always {
            script {
                echo "========== RAPPORT FINAL =========="
                sh '''
                    echo "Build: ${BUILD_VERSION}"
                    echo "Status: ${BUILD_STATUS}"
                    echo "Environnement: ${ENVIRONMENT}"
                    echo "Date: $(date)"
                    echo "Durée: $((${SECONDS} / 60)) minutes"
                '''
            }
            cleanWs()
        }

        success {
            echo "✅ BUILD ET DÉPLOIEMENT RÉUSSI"
        }

        failure {
            echo "❌ BUILD OU DÉPLOIEMENT ÉCHOUÉ"
        }
    }
}
