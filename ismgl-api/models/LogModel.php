<?php
require_once __DIR__ . '/../core/Model.php';

class LogModel extends Model {
    protected $table = 'logs_activite';
    protected $primaryKey = 'id_log';
    
    public function getLogs($page, $pageSize, $filters = []) {
        $offset = ($page - 1) * $pageSize;
        $params = [];
        
        $sql = "SELECT l.*, CONCAT(u.nom, ' ', u.prenom) as utilisateur
                FROM logs_activite l
                LEFT JOIN users u ON l.id_user = u.id_user
                WHERE 1=1";
        
        if (!empty($filters['user'])) {
            $sql .= " AND l.id_user = ?";
            $params[] = $filters['user'];
        }
        
        if (!empty($filters['module'])) {
            $sql .= " AND l.module = ?";
            $params[] = $filters['module'];
        }
        
        if (!empty($filters['action'])) {
            $sql .= " AND l.action = ?";
            $params[] = $filters['action'];
        }
        
        if (!empty($filters['date_debut'])) {
            $sql .= " AND DATE(l.date_action) >= ?";
            $params[] = $filters['date_debut'];
        }
        
        if (!empty($filters['date_fin'])) {
            $sql .= " AND DATE(l.date_action) <= ?";
            $params[] = $filters['date_fin'];
        }
        
        $sql .= " ORDER BY l.date_action DESC LIMIT ? OFFSET ?";
        $params[] = $pageSize;
        $params[] = $offset;
        
        return $this->db->fetchAll($sql, $params);
    }
    
    public function getTotalLogs($filters = []) {
        $params = [];
        $sql = "SELECT COUNT(*) FROM logs_activite l WHERE 1=1";
        
        if (!empty($filters['user'])) {
            $sql .= " AND l.id_user = ?";
            $params[] = $filters['user'];
        }
        
        if (!empty($filters['module'])) {
            $sql .= " AND l.module = ?";
            $params[] = $filters['module'];
        }
        
        return $this->db->fetchColumn($sql, $params);
    }
}