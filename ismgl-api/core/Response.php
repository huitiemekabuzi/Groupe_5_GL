<?php
class Response {
    
    public static function json($data, $statusCode = 200, $message = null) {
        http_response_code($statusCode);
        
        $response = [
            'success' => $statusCode >= 200 && $statusCode < 300,
            'status_code' => $statusCode,
            'timestamp' => date('Y-m-d H:i:s')
        ];
        
        if ($message !== null) {
            $response['message'] = $message;
        }
        
        if ($data !== null) {
            $response['data'] = $data;
        }
        
        echo json_encode($response, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
        exit;
    }
    
    public static function success($data = null, $message = 'Opération réussie', $statusCode = 200) {
        self::json($data, $statusCode, $message);
    }
    
    public static function error($message = 'Une erreur est survenue', $statusCode = 400, $errors = null) {
        $data = null;
        if ($errors !== null) {
            $data = ['errors' => $errors];
        }
        self::json($data, $statusCode, $message);
    }
    
    public static function created($data = null, $message = 'Créé avec succès') {
        self::json($data, 201, $message);
    }
    
    public static function updated($data = null, $message = 'Mis à jour avec succès') {
        self::json($data, 200, $message);
    }
    
    public static function deleted($message = 'Supprimé avec succès') {
        self::json(null, 200, $message);
    }
    
    public static function notFound($message = 'Ressource non trouvée') {
        self::json(null, 404, $message);
    }
    
    public static function unauthorized($message = MSG_UNAUTHORIZED) {
        self::json(null, 401, $message);
    }
    
    public static function forbidden($message = MSG_FORBIDDEN) {
        self::json(null, 403, $message);
    }
    
    public static function validationError($errors, $message = MSG_VALIDATION_ERROR) {
        self::error($message, 422, $errors);
    }
    
    public static function serverError($message = MSG_SERVER_ERROR) {
        self::json(null, 500, $message);
    }
    
    public static function paginated($data, $page, $pageSize, $totalItems, $message = null) {
        $totalPages = ceil($totalItems / $pageSize);
        
        $response = [
            'items' => $data,
            'pagination' => [
                'current_page' => (int)$page,
                'page_size' => (int)$pageSize,
                'total_items' => (int)$totalItems,
                'total_pages' => (int)$totalPages,
                'has_next' => $page < $totalPages,
                'has_previous' => $page > 1
            ]
        ];
        
        self::json($response, 200, $message);
    }
}