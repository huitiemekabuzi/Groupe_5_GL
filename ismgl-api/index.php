<?php
// Point d'entrée principal de l'API ISMGL
declare(strict_types=1);

// Chargement de la configuration
require_once __DIR__ . '/config/config.php';
require_once __DIR__ . '/config/constants.php';

// Chargement des classes core
require_once __DIR__ . '/core/Database.php';
require_once __DIR__ . '/core/Model.php';
require_once __DIR__ . '/core/Controller.php';
require_once __DIR__ . '/core/Response.php';
require_once __DIR__ . '/core/Validator.php';
require_once __DIR__ . '/core/JWT.php';
require_once __DIR__ . '/core/Router.php';

// Chargement des middlewares
require_once __DIR__ . '/middleware/CorsMiddleware.php';
require_once __DIR__ . '/middleware/AuthMiddleware.php';
require_once __DIR__ . '/middleware/RoleMiddleware.php';

// Chargement des utils
require_once __DIR__ . '/utils/Helper.php';
require_once __DIR__ . '/utils/FileUpload.php';
require_once __DIR__ . '/utils/PDFGenerator.php';
require_once __DIR__ . '/utils/EmailSender.php';

// Appliquer CORS
CorsMiddleware::handle();

// Gestion globale des erreurs
set_exception_handler(function (Throwable $e) {
    error_log("[ISMGL ERROR] " . $e->getMessage() . " in " . $e->getFile() . " line " . $e->getLine());
    Response::serverError(APP_ENV === 'development' ? $e->getMessage() : MSG_SERVER_ERROR);
});

set_error_handler(function ($severity, $message, $file, $line) {
    throw new ErrorException($message, 0, $severity, $file, $line);
});

// Chargement et dispatch des routes
try {
    $router = require_once __DIR__ . '/routes.php';
    $router->dispatch();
} catch (Exception $e) {
    error_log("[ISMGL FATAL] " . $e->getMessage());
    Response::serverError(APP_ENV === 'development' ? $e->getMessage() : MSG_SERVER_ERROR);
}