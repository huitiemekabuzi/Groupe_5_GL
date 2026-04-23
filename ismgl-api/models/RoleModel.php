<?php
require_once __DIR__ . '/../core/Model.php';

class RoleModel extends Model {
    protected $table = 'roles';
    protected $primaryKey = 'id_role';
    
    public function getAllRoles() {
        return $this->db->fetchAll(
            "SELECT * FROM roles WHERE est_actif = TRUE ORDER BY nom_role"
        );
    }
    
    public function getRoleWithPermissions($roleId) {
        $role = $this->find($roleId);
        
        if ($role) {
            $permissions = $this->db->fetchAll(
                "SELECT p.* FROM permissions p
                 JOIN role_permissions rp ON p.id_permission = rp.id_permission
                 WHERE rp.id_role = ?",
                [$roleId]
            );
            
            $role['permissions'] = $permissions;
        }
        
        return $role;
    }
    
    public function assignPermissions($roleId, $permissionIds) {
        $this->db->beginTransaction();
        
        try {
            // Supprimer les anciennes permissions
            $this->db->delete("DELETE FROM role_permissions WHERE id_role = ?", [$roleId]);
            
            // Ajouter les nouvelles permissions
            foreach ($permissionIds as $permissionId) {
                $this->db->insert(
                    "INSERT INTO role_permissions (id_role, id_permission) VALUES (?, ?)",
                    [$roleId, $permissionId]
                );
            }
            
            $this->db->commit();
            return true;
        } catch (Exception $e) {
            $this->db->rollback();
            throw $e;
        }
    }
}