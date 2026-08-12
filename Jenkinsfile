groovy
pipeline {
    agent any

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timestamps()
        timeout(time: 60, unit: 'MINUTES')
        disableConcurrentBuilds()
    }

    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['develop', 'staging', 'production'],
            description: 'Environnement de déploiement'
        )

        booleanParam(
            name: 'RUN_TESTS',
            defaultValue: true,
            description: 'Exécuter les tests'
        )

        booleanParam(
            name: 'INSTALL_DRUPAL',
            defaultValue: false,
            description: 'Installer Drupal frais'
        )

        booleanParam(
            name: 'PUSH_GITHUB',
            defaultValue: true,
            description: 'Push vers GitHub après build'
        )

        booleanParam(
            name: 'CREATE_RELEASE',
            defaultValue: false,
            description: 'Créer une release GitHub'
        )

        string(
            name: 'SERVER_IP',
            defaultValue: '',
            description: 'IP du serveur cible (ex: 203.0.113.10)'
        )

        string(
            name: 'DEPLOY_USER',
            defaultValue: 'deploy',
            description: 'Utilisateur SSH du serveur cible'
        )

        string(
            name: 'DEPLOY_PATH',
            defaultValue: '/var/www/drupal-production',
            description: 'Répertoire de déploiement sur le serveur'
        )

        string(
            name: 'DB_HOST',
            defaultValue: 'mariadb',
            description: 'Hôte base de données MySQL/MariaDB'
        )

        string(
            name: 'DB_NAME',
            defaultValue: 'drupal',
            description: 'Nom de la base Drupal'
        )

        string(
            name: 'DB_USER',
            defaultValue: 'drupal',
            description: 'Utilisateur base de données'
        )

        password(
            name: 'DB_PASSWORD',
            defaultValue: '',
            description: 'Mot de passe base de données'
        )
    }

    environment {
        DEPLOY_ALLOWED = 'false'
        DEPLOY_EXECUTED = 'false'
        DEPLOY_SKIP_REASONS = ''
        DEPLOY_ENV_EFFECTIVE = ''
        GITHUB_REPO = sh(
            script: "git config --get remote.origin.url | sed 's|.*/||' | sed 's|\\.git||'",
            returnStdout: true
        ).trim()
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm

                script {
                    def detectedBranch = (env.CHANGE_BRANCH ?: env.BRANCH_NAME ?: env.GIT_BRANCH ?: '').trim()
                    detectedBranch = detectedBranch
                        .replaceFirst(/^origin\//, '')
                        .replaceFirst(/^refs\/heads\//, '')
                        .replaceAll(/\r/, '')
                        .trim()

                    if (!detectedBranch || detectedBranch == 'HEAD' || detectedBranch == 'undefined') {
                        detectedBranch = sh(
                            script: """
                                set -e
                                git branch -a --contains HEAD 2>/dev/null \
                                    | sed 's#^..##' \
                                    | sed 's#^remotes/origin/##' \
                                    | head -n1 \
                                    || true
                            """,
                            returnStdout: true
                        ).trim()
                    }

                    if (!detectedBranch || detectedBranch == 'HEAD' || detectedBranch == 'undefined') {
                        detectedBranch = sh(
                            script: """
                                set -e
                                if git show-ref --verify --quiet refs/remotes/origin/main; then
                                    echo main
                                elif git show-ref --verify --quiet refs/remotes/origin/develop; then
                                    echo develop
                                else
                                    git rev-parse --abbrev-ref HEAD 2>/dev/null || true
                                fi
                            """,
                            returnStdout: true
                        ).trim()
                    }

                    if (!detectedBranch || detectedBranch == 'HEAD' || detectedBranch == 'undefined') {
                        detectedBranch = sh(
                            script: "git remote show origin 2>/dev/null | sed -n '/HEAD branch/s/.*: //p' || true",
                            returnStdout: true
                        ).trim()
                    }

                    if (!detectedBranch || detectedBranch == 'HEAD' || detectedBranch == 'undefined') {
                        detectedBranch = 'main'
                    }

                    env.BUILD_TIMESTAMP = sh(
                        script: 'date +%Y%m%d_%H%M%S',
                        returnStdout: true
                    ).trim()

                    env.GIT_COMMIT_SHORT = sh(
                        script: 'git rev-parse --short HEAD',
                        returnStdout: true
                    ).trim()

                    env.BUILD_VERSION = sh(
                        script: 'git describe --tags --always 2>/dev/null || echo "v1.0.0"',
                        returnStdout: true
                    ).trim()

                    env.BRANCH_NAME = detectedBranch ?: 'unknown'

                    echo "========== CHECKOUT =========="
                    echo "Branche       : ${env.BRANCH_NAME}"
                    echo "Version       : ${env.BUILD_VERSION}"
                    echo "Commit        : ${env.GIT_COMMIT_SHORT}"
                    echo "Timestamp     : ${env.BUILD_TIMESTAMP}"
                    echo "Environnement : ${params.ENVIRONMENT}"
                }
            }
        }

        stage('Prepare') {
            steps {
                script {
                    echo "========== PRÉPARATION BUILD =========="
                    echo "Version: ${env.BUILD_VERSION}"
                    echo "Environnement: ${params.ENVIRONMENT}"
                }

                sh '''
                    set -e

                    if [ ! -f "composer.json" ]; then
                        echo "❌ ERREUR: composer.json manquant !"
                        exit 1
                    fi

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
                    set -e

                    echo "========== INSTALLATION DES DÉPENDANCES =========="

                    composer install \
                        --no-interaction \
                        --prefer-dist \
                        --no-dev \
                        --optimize-autoloader

                    echo "✅ Dépendances installées"
                '''
            }
        }

        stage('Install Drupal') {
            when {
                expression {
                    return params.INSTALL_DRUPAL
                }
            }

            steps {
                sh '''
                    set -e

                    echo "========== INSTALLATION DE DRUPAL =========="

                    if [ ! -f "web/sites/default/settings.php" ]; then
                        echo "Création de settings.php..."
                        cp web/sites/default/default.settings.php \
                           web/sites/default/settings.php

                        chmod 644 web/sites/default/settings.php
                    fi

                    if [ ! -f "web/sites/default/settings.local.php" ]; then
                        echo "Création de settings.local.php..."
                        cp web/sites/default/example.settings.local.php \
                           web/sites/default/settings.local.php
                    fi

                    if [ ! -x "vendor/bin/drush" ]; then
                        echo "❌ ERREUR: drush introuvable (vendor/bin/drush)."
                        echo "Ajoutez drush au projet: composer require drush/drush"
                        exit 1
                    fi

                    if [ -z "${DB_HOST:-}" ] || [ -z "${DB_NAME:-}" ] || [ -z "${DB_USER:-}" ] || [ -z "${DB_PASSWORD:-}" ]; then
                        echo "❌ ERREUR: variables DB manquantes (DB_HOST, DB_NAME, DB_USER, DB_PASSWORD)."
                        exit 1
                    fi

                    if php vendor/bin/drush status --field=bootstrap 2>/dev/null | grep -qi successful; then
                        echo "ℹ️ Drupal déjà installé"
                    else
                        php vendor/bin/drush site:install standard -y \
                            --db-url="mysql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}/${DB_NAME}" \
                            --site-name="Drupal CI/CD" \
                            --account-name=admin \
                            --account-pass=admin123
                    fi

                    echo "✅ Drupal installé/configuré"
                '''
            }
        }

        stage('Build') {
            steps {
                sh '''
                    set -e

                    echo "========== BUILD =========="

                    bash scripts/build.sh "${ENVIRONMENT}"

                    echo "✅ Build complété"
                '''
            }
        }

        stage('Tests') {
            when {
                expression {
                    return params.RUN_TESTS
                }
            }

            steps {
                sh '''
                    set -e

                    echo "========== TESTS =========="

                    bash scripts/test.sh

                    echo "✅ Tests réussis"
                '''
            }
        }

        stage('Deploy Gate') {
            steps {
                script {
                    def blockers = []

                    env.DEPLOY_ENV_EFFECTIVE = params.ENVIRONMENT

                    if (env.BRANCH_NAME != 'main') {
                        blockers << "Branche attendue: main (actuelle: ${env.BRANCH_NAME})"
                    }

                    if (env.BRANCH_NAME == 'main' && params.ENVIRONMENT != 'production') {
                        env.DEPLOY_ENV_EFFECTIVE = 'production'
                        echo "ℹ️ Environnement de déploiement forcé à production (paramètre actuel: ${params.ENVIRONMENT})."
                    }

                    if (blockers) {
                        env.DEPLOY_ALLOWED = 'false'
                        env.DEPLOY_SKIP_REASONS = blockers.join(' | ')
                        echo 'ℹ️ Déploiement distant ignoré (conditions non remplies):'
                        blockers.each { reason -> echo " - ${reason}" }
                    } else {
                        env.DEPLOY_ALLOWED = 'true'
                        env.DEPLOY_SKIP_REASONS = ''
                        echo "✅ Conditions de déploiement validées (branche main)."
                        echo "✅ Environnement de déploiement effectif: ${env.DEPLOY_ENV_EFFECTIVE}"
                    }
                }
            }
        }

        stage('Deploy') {
            when {
                expression {
                    return env.DEPLOY_ALLOWED == 'true'
                }
            }

            steps {
                script {
                    env.DEPLOY_EXECUTED = 'true'
                }

                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'deploy-key',
                        keyFileVariable: 'SSH_KEY_FILE',
                        usernameVariable: 'SSH_CREDENTIAL_USER'
                    )
                ]) {
                    sh '''
                        set -e

                        echo "========== DÉPLOIEMENT =========="
                        echo "Branche       : ${BRANCH_NAME}"
                        echo "Environnement : ${DEPLOY_ENV_EFFECTIVE}"
                        echo "Serveur       : ${SERVER_IP}"
                        echo "Répertoire    : ${DEPLOY_PATH}"

                        DEPLOY_USER_EFFECTIVE="${DEPLOY_USER}"

                        if [ -z "$DEPLOY_USER_EFFECTIVE" ]; then
                            DEPLOY_USER_EFFECTIVE="${SSH_CREDENTIAL_USER}"
                        fi

                        if [ -z "$SERVER_IP" ]; then
                            echo "❌ SERVER_IP n'est pas renseignée."
                            exit 1
                        fi

                        bash scripts/deploy.sh \
                            "${DEPLOY_ENV_EFFECTIVE}" \
                            "${SERVER_IP}" \
                            "${DEPLOY_USER_EFFECTIVE}" \
                            "${DEPLOY_PATH}" \
                            "${SSH_KEY_FILE}"

                        echo "✅ Déploiement complété"
                    '''
                }
            }
        }

        stage('Post-Deploy') {
            when {
                expression {
                    return env.DEPLOY_ALLOWED == 'true'
                }
            }

            steps {
                script {
                    echo '========== POST-DÉPLOIEMENT =========='
                    echo 'ℹ️ Les opérations Drush sont exécutées sur le serveur distant par scripts/deploy.sh.'
                    echo '✅ Post-déploiement distant déjà effectué'
                }
            }
        }

        stage('Push GitHub') {
            when {
                expression {
                    return (
                        params.PUSH_GITHUB &&
                        (
                            env.BRANCH_NAME == 'main' ||
                            env.BRANCH_NAME == 'develop'
                        )
                    )
                }
            }

            steps {
                withCredentials([
                    gitUsernamePassword(
                        credentialsId: 'github-credentials',
                        gitToolName: 'Default'
                    )
                ]) {
                    sh '''
                        set -e

                        echo "========== PUSH GITHUB =========="
                        echo "Branche: ${BRANCH_NAME}"

                        if ! git remote -v >/dev/null 2>&1; then
                            echo "❌ Aucun remote Git configuré."
                            exit 1
                        fi

                        git config user.name "Jenkins CI"
                        git config user.email "jenkins@example.com"

                        git add -A -- . \
                            ':(exclude)vendor' \
                            ':(exclude)web/sites/default/files' \
                            ':(exclude)logs' \
                            ':(exclude)private' \
                            ':(exclude).env' \
                            ':(exclude).gitignore'

                        if ! git diff --cached --quiet; then
                            git commit \
                                -m "Jenkins build ${BUILD_TIMESTAMP} - ${GIT_COMMIT_SHORT}"

                            git push origin "${BRANCH_NAME}" --quiet

                            echo "✅ Commit et push effectués"
                        else
                            echo "ℹ️ Aucune modification Git à pousser."
                        fi

                        TAG_NAME="build-${BUILD_TIMESTAMP}"

                        if git rev-parse "${TAG_NAME}" >/dev/null 2>&1; then
                            echo "ℹ️ Le tag ${TAG_NAME} existe déjà."
                        else
                            git tag -a "${TAG_NAME}" \
                                -m "Build ${BUILD_TIMESTAMP} - ${GIT_COMMIT_SHORT}"

                            git push origin "${TAG_NAME}" --quiet

                            echo "✅ Tag ${TAG_NAME} poussé"
                        fi

                        echo "✅ Push GitHub complété"
                    '''
                }
            }
        }

        stage('Create Release') {
            when {
                expression {
                    return (
                        params.CREATE_RELEASE &&
                        env.BRANCH_NAME == 'main'
                    )
                }
            }

            steps {
                withCredentials([
                    string(
                        credentialsId: 'github-token',
                        variable: 'GITHUB_TOKEN'
                    )
                ]) {
                    sh '''
                        set -e

                        echo "========== CRÉATION RELEASE =========="

                        RELEASE_TAG="release-${BUILD_TIMESTAMP}"

                        RELEASE_NOTES="Build automatique Jenkins

Version: ${BUILD_VERSION}
Commit: ${GIT_COMMIT_SHORT}
Environnement: ${ENVIRONMENT}"

                        curl -sS -X POST \
                            -H "Authorization: token ${GITHUB_TOKEN}" \
                            -H "Accept: application/vnd.github.v3+json" \
                            "https://api.github.com/repos/${GIT_USERNAME}/${GITHUB_REPO}/releases" \
                            -d "$(python3 -c 'import json,sys; print(json.dumps({
                                "tag_name": sys.argv[1],
                                "target_commitish": "main",
                                "name": "Release " + sys.argv[1],
                                "body": sys.argv[2],
                                "draft": False,
                                "prerelease": False
                            }))' "${RELEASE_TAG}" "${RELEASE_NOTES}")"

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
                echo "Build         : ${env.BUILD_VERSION ?: 'N/A'}"
                echo "Branche       : ${env.BRANCH_NAME ?: 'N/A'}"
                echo "Status        : ${currentBuild.currentResult}"
                echo "Environnement : ${params.ENVIRONMENT ?: 'N/A'}"
                echo "Date          : ${new Date()}"
                echo "Durée         : ${currentBuild.durationString}"
            }

            deleteDir()
        }

        success {
            script {
                if (env.DEPLOY_EXECUTED == 'true') {
                    echo "✅ BUILD ET DÉPLOIEMENT RÉUSSI"
                } else if (env.DEPLOY_ALLOWED == 'true') {
                    echo "✅ BUILD RÉUSSI (déploiement non exécuté)"
                } else {
                    echo "✅ BUILD RÉUSSI (déploiement ignoré: ${env.DEPLOY_SKIP_REASONS})"
                }
            }
        }

        failure {
            echo "❌ BUILD OU DÉPLOIEMENT ÉCHOUÉ"
        }
    }
}

