<?php
require_once __DIR__ . '/../core/Response.php';
require_once __DIR__ . '/../core/Database.php';

class RoleMiddleware {
    
    public static function hasRole($allowedRoles) {
        $user = JWT::getCurrentUser();
        
        if (!$user) {
            Response::unauthorized();
        }
        
        $allowedRoles = is_array($allowedRoles) ? $allowedRoles : [$allowedRoles];
        
        if (!in_array($user['id_role'], $allowedRoles)) {
            Response::forbidden('Vous n\'avez pas les permissions nécessaires pour cette action');
        }
        
        return true;
    }
    
    public static function hasPermission($permissionCode) {
        $user = JWT::getCurrentUser();
        
        if (!$user) {
            Response::unauthorized();
        }
        
        // L'admin a toutes les permissions
        if ($user['id_role'] == ROLE_ADMIN) {
            return true;
        }
        
        $db = new Database();
        $hasPermission = $db->fetchColumn(
            "SELECT COUNT(*) FROM role_permissions rp
             JOIN permissions p ON rp.id_permission = p.id_permission
             WHERE rp.id_role = ? AND p.code_permission = ?",
            [$user['id_role'], $permissionCode]
        );
        
        if (!$hasPermission) {
            Response::forbidden("Permission requise: $permissionCode");
        }
        
        return true;
    }
    
    public static function canAccess($resource, $action) {
        $permissionCode = strtolower($resource) . '.' . strtolower($action);
        return self::hasPermission($permissionCode);
    }
}