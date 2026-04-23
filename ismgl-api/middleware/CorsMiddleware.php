<?php
class CorsMiddleware {
    
    public static function handle() {
        // Autoriser toutes les origines (à personnaliser en production)
        $allowedOrigins = ['*'];
        
        $origin = $_SERVER['HTTP_ORIGIN'] ?? '*';
        
        if (in_array('*', $allowedOrigins) || in_array($origin, $allowedOrigins)) {
            header("Access-Control-Allow-Origin: $origin");
        }
        
        header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, PATCH, OPTIONS');
        header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
        header('Access-Control-Max-Age: 86400');
        header('Access-Control-Allow-Credentials: true');
        
        // Gérer les requêtes preflight
        if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
            http_response_code(200);
            exit();
        }
    }
}