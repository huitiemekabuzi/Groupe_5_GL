<?php
// Configuration générale de l'application
define('APP_NAME', 'ISMGL - Gestion Universitaire');
define('APP_VERSION', '1.0.0');
define('APP_ENV', 'development'); // development, production

// Chemins
define('BASE_PATH', dirname(__DIR__));
define('UPLOAD_PATH', BASE_PATH . '/uploads/');
define('DOCUMENT_PATH', UPLOAD_PATH . 'documents/');
define('PHOTO_PATH', UPLOAD_PATH . 'photos/');
define('RECU_PATH', UPLOAD_PATH . 'recus/');

// URL de base
define('BASE_URL', 'http://localhost/ismgl-api');
define('API_URL', BASE_URL . '/api');

// JWT Configuration
define('JWT_SECRET_KEY', 'ISMGL_SECRET_KEY_2024_SECURE_@#$%');
define('JWT_ALGORITHM', 'HS256');
define('JWT_EXPIRATION', 86400); // 24 heures en secondes
define('JWT_REFRESH_EXPIRATION', 604800); // 7 jours

// Sécurité
define('MAX_LOGIN_ATTEMPTS', 5);
define('ACCOUNT_LOCKOUT_TIME', 1800); // 30 minutes
define('PASSWORD_MIN_LENGTH', 8);

// Pagination
define('DEFAULT_PAGE_SIZE', 20);
define('MAX_PAGE_SIZE', 100);

// Upload
define('MAX_FILE_SIZE', 5242880); // 5MB
define('ALLOWED_IMAGE_TYPES', ['image/jpeg', 'image/png', 'image/jpg']);
define('ALLOWED_DOCUMENT_TYPES', ['application/pdf', 'image/jpeg', 'image/png']);

// Email (à configurer selon votre serveur SMTP)
define('SMTP_HOST', 'smtp.gmail.com');
define('SMTP_PORT', 587);
define('SMTP_USERNAME', 'noreply@ismgl.cd');
define('SMTP_PASSWORD', 'your_password');
define('SMTP_FROM_EMAIL', 'noreply@ismgl.cd');
define('SMTP_FROM_NAME', 'ISMGL');

// Timezone
date_default_timezone_set('Africa/Lubumbashi');

// Error Reporting
if (APP_ENV === 'development') {
    error_reporting(E_ALL);
    ini_set('display_errors', 1);
} else {
    error_reporting(0);
    ini_set('display_errors', 0);
}

// Headers CORS
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
header('Content-Type: application/json; charset=UTF-8');

// Gérer les requêtes OPTIONS (preflight)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}