<?php
require_once __DIR__ . '/../core/Model.php';

class PermissionModel extends Model {
    protected $table = 'permissions';
    protected $primaryKey = 'id_permission';
    
    public function getAllPermissions() {
        return $this->db->fetchAll(
            "SELECT * FROM permissions ORDER BY module, nom_permission"
        );
    }
    
    public function getPermissionsByModule() {
        $permissions = $this->getAllPermissions();
        $grouped = [];
        
        foreach ($permissions as $permission) {
            $module = $permission['module'];
            if (!isset($grouped[$module])) {
                $grouped[$module] = [];
            }
            $grouped[$module][] = $permission;
        }
        
        return $grouped;
    }
    
    public function hasPermission($userId, $permissionCode) {
        $count = $this->db->fetchColumn(
            "SELECT COUNT(*) FROM role_permissions rp
             JOIN permissions p ON rp.id_permission = p.id_permission
             JOIN users u ON rp.id_role = u.id_role
             WHERE u.id_user = ? AND p.code_permission = ?",
            [$userId, $permissionCode]
        );
        
        return $count > 0;
    }
}