<?php
require_once __DIR__ . '/../core/Model.php';

class UserModel extends Model {
    protected $table = 'users';
    protected $primaryKey = 'id_user';
    
    public function createUser($data) {
        return $this->create([
            'matricule' => $data['matricule'],
            'nom' => $data['nom'],
            'prenom' => $data['prenom'],
            'email' => $data['email'],
            'telephone' => $data['telephone'] ?? null,
            'mot_de_passe' => password_hash($data['mot_de_passe'], PASSWORD_DEFAULT),
            'id_role' => $data['id_role'],
            'photo_profil' => $data['photo_profil'] ?? null,
            'est_actif' => $data['est_actif'] ?? true
        ]);
    }
    
    public function findByEmail($email) {
        return $this->db->fetchOne(
            "SELECT u.*, r.nom_role 
             FROM users u 
             JOIN roles r ON u.id_role = r.id_role 
             WHERE u.email = ?",
            [$email]
        );
    }
    
    public function findByMatricule($matricule) {
        return $this->db->fetchOne(
            "SELECT u.*, r.nom_role 
             FROM users u 
             JOIN roles r ON u.id_role = r.id_role 
             WHERE u.matricule = ?",
            [$matricule]
        );
    }
    
    public function getUserWithRole($id) {
        return $this->db->fetchOne(
            "SELECT u.*, r.nom_role, r.description as role_description
             FROM users u 
             JOIN roles r ON u.id_role = r.id_role 
             WHERE u.id_user = ?",
            [$id]
        );
    }
    
    public function getUserPermissions($userId) {
        return $this->db->fetchAll(
            "SELECT p.* FROM permissions p
             JOIN role_permissions rp ON p.id_permission = rp.id_permission
             JOIN users u ON rp.id_role = u.id_role
             WHERE u.id_user = ?",
            [$userId]
        );
    }
    
    public function updatePassword($userId, $newPassword) {
        return $this->update($userId, [
            'mot_de_passe' => password_hash($newPassword, PASSWORD_DEFAULT)
        ]);
    }
    
    public function updateLastLogin($userId) {
        return $this->db->update(
            "UPDATE users SET derniere_connexion = NOW(), tentatives_connexion = 0 WHERE id_user = ?",
            [$userId]
        );
    }
    
    public function incrementLoginAttempts($email) {
        $this->db->query(
            "UPDATE users SET tentatives_connexion = tentatives_connexion + 1 WHERE email = ?",
            [$email]
        );
        
        $user = $this->findByEmail($email);
        if ($user && $user['tentatives_connexion'] >= MAX_LOGIN_ATTEMPTS) {
            $this->lockAccount($user['id_user']);
        }
    }
    
    public function lockAccount($userId) {
        return $this->db->update(
            "UPDATE users SET compte_bloque = TRUE, date_blocage = NOW() WHERE id_user = ?",
            [$userId]
        );
    }
    
    public function unlockAccount($userId) {
        return $this->db->update(
            "UPDATE users SET compte_bloque = FALSE, tentatives_connexion = 0, date_blocage = NULL WHERE id_user = ?",
            [$userId]
        );
    }
    
    public function getAllUsers($page, $pageSize, $filters = []) {
        $offset = ($page - 1) * $pageSize;
        $params = [];
        
        $sql = "SELECT u.id_user, u.matricule, u.nom, u.prenom, u.email, u.telephone, 
                       u.photo_profil, u.est_actif, u.derniere_connexion, u.compte_bloque,
                       r.nom_role, u.date_creation
                FROM users u
                JOIN roles r ON u.id_role = r.id_role
                WHERE 1=1";
        
        if (!empty($filters['role'])) {
            $sql .= " AND u.id_role = ?";
            $params[] = $filters['role'];
        }
        
        if (!empty($filters['actif'])) {
            $sql .= " AND u.est_actif = ?";
            $params[] = $filters['actif'];
        }
        
        if (!empty($filters['search'])) {
            $sql .= " AND (u.nom LIKE ? OR u.prenom LIKE ? OR u.email LIKE ? OR u.matricule LIKE ?)";
            $search = "%{$filters['search']}%";
            $params = array_merge($params, [$search, $search, $search, $search]);
        }
        
        $sql .= " ORDER BY u.date_creation DESC LIMIT ? OFFSET ?";
        $params[] = $pageSize;
        $params[] = $offset;
        
        return $this->db->fetchAll($sql, $params);
    }
    
    public function getTotalUsers($filters = []) {
        $params = [];
        $sql = "SELECT COUNT(*) FROM users u WHERE 1=1";
        
        if (!empty($filters['role'])) {
            $sql .= " AND u.id_role = ?";
            $params[] = $filters['role'];
        }
        
        if (!empty($filters['actif'])) {
            $sql .= " AND u.est_actif = ?";
            $params[] = $filters['actif'];
        }
        
        if (!empty($filters['search'])) {
            $sql .= " AND (u.nom LIKE ? OR u.prenom LIKE ? OR u.email LIKE ? OR u.matricule LIKE ?)";
            $search = "%{$filters['search']}%";
            $params = array_merge($params, [$search, $search, $search, $search]);
        }
        
        return $this->db->fetchColumn($sql, $params);
    }
    
    public function saveResetToken($email, $token) {
        $expiration = date('Y-m-d H:i:s', strtotime('+1 hour'));
        return $this->db->update(
            "UPDATE users SET token_reset = ?, token_expiration = ? WHERE email = ?",
            [$token, $expiration, $email]
        );
    }
    
    public function verifyResetToken($token) {
        return $this->db->fetchOne(
            "SELECT * FROM users WHERE token_reset = ? AND token_expiration > NOW()",
            [$token]
        );
    }
    
    public function clearResetToken($userId) {
        return $this->db->update(
            "UPDATE users SET token_reset = NULL, token_expiration = NULL WHERE id_user = ?",
            [$userId]
        );
    }
}