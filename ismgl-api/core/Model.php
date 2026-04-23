<?php
class Model {
    protected $db;
    protected $table;
    protected $primaryKey = 'id';
    
    public function __construct() {
        $this->db = new Database();
    }
    
    public function all($orderBy = null) {
        $sql = "SELECT * FROM {$this->table}";
        if ($orderBy) {
            $sql .= " ORDER BY $orderBy";
        }
        return $this->db->fetchAll($sql);
    }
    
    public function find($id) {
        $sql = "SELECT * FROM {$this->table} WHERE {$this->primaryKey} = ?";
        return $this->db->fetchOne($sql, [$id]);
    }
    
    public function where($conditions, $orderBy = null, $limit = null) {
        $sql = "SELECT * FROM {$this->table} WHERE ";
        $params = [];
        $whereClauses = [];
        
        foreach ($conditions as $field => $value) {
            $whereClauses[] = "$field = ?";
            $params[] = $value;
        }
        
        $sql .= implode(' AND ', $whereClauses);
        
        if ($orderBy) {
            $sql .= " ORDER BY $orderBy";
        }
        
        if ($limit) {
            $sql .= " LIMIT $limit";
        }
        
        return $this->db->fetchAll($sql, $params);
    }
    
    public function create($data) {
        $fields = array_keys($data);
        $values = array_values($data);
        $placeholders = rtrim(str_repeat('?, ', count($fields)), ', ');
        
        $sql = "INSERT INTO {$this->table} (" . implode(', ', $fields) . ") VALUES ($placeholders)";
        return $this->db->insert($sql, $values);
    }
    
    public function update($id, $data) {
        $fields = [];
        $values = [];
        
        foreach ($data as $field => $value) {
            $fields[] = "$field = ?";
            $values[] = $value;
        }
        
        $values[] = $id;
        $sql = "UPDATE {$this->table} SET " . implode(', ', $fields) . " WHERE {$this->primaryKey} = ?";
        
        return $this->db->update($sql, $values);
    }
    
    public function delete($id) {
        $sql = "DELETE FROM {$this->table} WHERE {$this->primaryKey} = ?";
        return $this->db->delete($sql, [$id]);
    }
    
    public function count($conditions = []) {
        $sql = "SELECT COUNT(*) FROM {$this->table}";
        $params = [];
        
        if (!empty($conditions)) {
            $sql .= " WHERE ";
            $whereClauses = [];
            
            foreach ($conditions as $field => $value) {
                $whereClauses[] = "$field = ?";
                $params[] = $value;
            }
            
            $sql .= implode(' AND ', $whereClauses);
        }
        
        return $this->db->fetchColumn($sql, $params);
    }
    
    public function paginate($page, $pageSize, $conditions = [], $orderBy = null) {
        $offset = ($page - 1) * $pageSize;
        
        $sql = "SELECT * FROM {$this->table}";
        $params = [];
        
        if (!empty($conditions)) {
            $sql .= " WHERE ";
            $whereClauses = [];
            
            foreach ($conditions as $field => $value) {
                $whereClauses[] = "$field = ?";
                $params[] = $value;
            }
            
            $sql .= implode(' AND ', $whereClauses);
        }
        
        if ($orderBy) {
            $sql .= " ORDER BY $orderBy";
        }
        
        $sql .= " LIMIT $pageSize OFFSET $offset";
        
        return $this->db->fetchAll($sql, $params);
    }
}