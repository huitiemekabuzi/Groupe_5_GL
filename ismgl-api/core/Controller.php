<?php
class Controller {
    protected $db;
    
    public function __construct() {
        $this->db = new Database();
    }
    
    protected function getRequestData() {
        $contentType = $_SERVER['CONTENT_TYPE'] ?? '';
        
        if (strpos($contentType, 'application/json') !== false) {
            $data = json_decode(file_get_contents('php://input'), true);
            return $data ?? [];
        }
        
        return array_merge($_POST, $_GET);
    }
    
    protected function getRequestMethod() {
        return $_SERVER['REQUEST_METHOD'];
    }
    
    protected function getCurrentUser() {
        return JWT::getCurrentUser();
    }
    
    protected function getUserId() {
        $user = $this->getCurrentUser();
        return $user['id_user'] ?? null;
    }
    
    protected function getPagination() {
        $page = isset($_GET['page']) ? max(1, (int)$_GET['page']) : 1;
        $pageSize = isset($_GET['page_size']) ? min((int)$_GET['page_size'], MAX_PAGE_SIZE) : DEFAULT_PAGE_SIZE;
        $offset = ($page - 1) * $pageSize;
        
        return [
            'page' => $page,
            'page_size' => $pageSize,
            'offset' => $offset
        ];
    }
    
    protected function logActivity($action, $module, $description, $dataAvant = null, $dataApres = null) {
        $userId = $this->getUserId();
        $ipAddress = $_SERVER['REMOTE_ADDR'] ?? null;
        $userAgent = $_SERVER['HTTP_USER_AGENT'] ?? null;
        
        $sql = "INSERT INTO logs_activite (id_user, action, module, description, ip_address, user_agent, donnees_avant, donnees_apres) 
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        
        $this->db->query($sql, [
            $userId,
            $action,
            $module,
            $description,
            $ipAddress,
            $userAgent,
            $dataAvant ? json_encode($dataAvant) : null,
            $dataApres ? json_encode($dataApres) : null
        ]);
    }
}