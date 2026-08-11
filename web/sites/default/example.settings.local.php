<?php

/**
 * @file
 * Configuration locale pour le développement et tests Drupal.
 *
 * À copier en settings.local.php pour une configuration personnalisée.
 */

// ===== CONFIGURATION DE LA BASE DE DONNÉES =====
// Configurée via les variables d'environnement Docker
if (getenv('DB_HOST')) {
    $databases['default']['default'] = [
        'driver' => 'mysql',
        'database' => getenv('DB_NAME') ?: 'drupal',
        'username' => getenv('DB_USER') ?: 'drupal',
        'password' => getenv('DB_PASSWORD') ?: 'drupal',
        'host' => getenv('DB_HOST') ?: 'localhost',
        'port' => getenv('DB_PORT') ?: 3306,
        'namespace' => 'Drupal\\Core\\Database\\Driver\\mysql',
        'prefix' => '',
    ];
}

// ===== CONFIGURATION DE SÉCURITÉ =====
$settings['hash_salt'] = getenv('DRUPAL_HASH_SALT') ?: 'change-me-to-a-random-string';

// ===== MODE DEBUG =====
$config['system.logging']['error_level'] = 'all';
$settings['file_private_path'] = '../private';
$settings['file_public_path'] = 'sites/default/files';

// ===== REDIS CACHE (optionnel) =====
if (getenv('REDIS_HOST')) {
    $settings['redis.connection']['interface'] = 'PhpRedis';
    $settings['redis.connection']['host'] = getenv('REDIS_HOST') ?: 'redis';
    $settings['redis.connection']['port'] = getenv('REDIS_PORT') ?: 6379;

    $settings['cache']['default'] = 'cache.backend.redis';
    $settings['cache_bins']['default'] = 'cache.backend.redis';

    // Utiliser Redis pour les sessions
    $settings['session.storage'] = 'Drupal\Core\Session\SessionManager';
}

// ===== TRUSTED HOSTS =====
$settings['trusted_host_patterns'] = [
    '^localhost$',
    '^127\.0\.0\.1$',
    '^drupal$',
    getenv('DRUPAL_HOST') ?: 'localhost:8080',
];

// ===== CONFIGURATION D'EMAIL =====
$config['system.mail']['interface']['default'] = 'swiftmailer';
$config['swiftmailer.transport']['transport'] = 'smtp';
$config['swiftmailer.transport']['smtp_host'] = getenv('MAIL_HOST') ?: 'localhost';
$config['swiftmailer.transport']['smtp_port'] = getenv('MAIL_PORT') ?: 1025;

// ===== DÉVELOPPEMENT =====
if (getenv('DRUPAL_ENV') === 'develop') {
    // Désactiver la mise en cache
    $settings['cache']['bins']['dynamic_page_cache'] = 'cache.backend.null';
    $settings['cache']['bins']['page'] = 'cache.backend.null';
    $settings['cache']['bins']['render'] = 'cache.backend.null';

    // Activer l'affichage détaillé des erreurs
    $config['system.logging']['error_level'] = 'verbose';

    // Désactiver les images lazyload pour le développement
    $settings['image_loading_attribute'] = 'lazy';
}

// ===== PRODUCTION =====
if (getenv('DRUPAL_ENV') === 'production') {
    // Modes de cache en production
    $settings['cache']['bins']['dynamic_page_cache'] = 'cache.backend.redis';
    $settings['cache']['bins']['page'] = 'cache.backend.redis';

    // Désactiver le mode debug
    $config['system.logging']['error_level'] = 'some';

    // Forcer le SSL/HTTPS
    $settings['mixed_mode_whitelist'] = [];
}

// ===== CONFIGURATION DRUSH =====
$settings['drush.settings'] = [
    'uri' => getenv('DRUSH_OPTIONS_URI') ?: 'http://localhost:8080',
];
