<?php
require_once __DIR__ . '/../config/database.php';

class DatabaseStatement {
    private $rows;
    private $cursor = 0;
    private $affectedRows;
    
    public function __construct($rows = [], $affectedRows = 0) {
        $this->rows = $rows;
        $this->affectedRows = $affectedRows;
    }
    
    public function fetch() {
        if (!isset($this->rows[$this->cursor])) {
            return null;
        }
        
        return $this->rows[$this->cursor++];
    }
    
    public function fetchAll() {
        return $this->rows;
    }
    
    public function fetchColumn($index = 0) {
        if (empty($this->rows)) {
            return null;
        }
        
        $values = array_values($this->rows[0]);
        return $values[$index] ?? null;
    }
    
    public function rowCount() {
        return $this->affectedRows;
    }
}

class Database {
    private $conn;
    
    public function __construct() {
        $this->conn = DatabaseConfig::getInstance()->getConnection();
    }
    
    public function query($sql, $params = []) {
        try {
            $stmt = $this->conn->prepare($sql);
            if (!$stmt) {
                throw new Exception($this->conn->error);
            }
            
            $this->bindStatementParams($stmt, $params);
            
            if (!$stmt->execute()) {
                throw new Exception($stmt->error);
            }
            
            $affectedRows = $stmt->affected_rows;
            $rows = [];
            $result = $stmt->get_result();
            
            if ($result instanceof mysqli_result) {
                $rows = $result->fetch_all(MYSQLI_ASSOC);
                $result->free();
            }
            
            $stmt->close();
            $this->clearPendingResults();
            
            return new DatabaseStatement($rows, $affectedRows);
        } catch (Exception $e) {
            error_log('Database Error: ' . $e->getMessage());
            throw new Exception('Erreur de base de donnees: ' . $e->getMessage());
        }
    }
    
    public function fetchAll($sql, $params = []) {
        $stmt = $this->query($sql, $params);
        return $stmt->fetchAll();
    }
    
    public function fetchOne($sql, $params = []) {
        $stmt = $this->query($sql, $params);
        return $stmt->fetch();
    }
    
    public function fetchColumn($sql, $params = []) {
        $stmt = $this->query($sql, $params);
        return $stmt->fetchColumn();
    }
    
    public function insert($sql, $params = []) {
        $this->query($sql, $params);
        return $this->conn->insert_id;
    }
    
    public function update($sql, $params = []) {
        $stmt = $this->query($sql, $params);
        return $stmt->rowCount();
    }
    
    public function delete($sql, $params = []) {
        $stmt = $this->query($sql, $params);
        return $stmt->rowCount();
    }
    
    public function beginTransaction() {
        return $this->conn->begin_transaction();
    }
    
    public function commit() {
        return $this->conn->commit();
    }
    
    public function rollback() {
        return $this->conn->rollback();
    }
    
    public function queryResultSets($sql, $params = []) {
        try {
            $stmt = $this->conn->prepare($sql);
            if (!$stmt) {
                throw new Exception($this->conn->error);
            }
            
            $this->bindStatementParams($stmt, $params);
            
            if (!$stmt->execute()) {
                throw new Exception($stmt->error);
            }
            
            $resultSets = [];
            $result = $stmt->get_result();
            if ($result instanceof mysqli_result) {
                $resultSets[] = $result->fetch_all(MYSQLI_ASSOC);
                $result->free();
            } else {
                $resultSets[] = [];
            }
            
            $stmt->close();
            
            while ($this->conn->more_results()) {
                $this->conn->next_result();
                $nextResult = $this->conn->store_result();
                if ($nextResult instanceof mysqli_result) {
                    $resultSets[] = $nextResult->fetch_all(MYSQLI_ASSOC);
                    $nextResult->free();
                } else {
                    $resultSets[] = [];
                }
            }
            
            return $resultSets;
        } catch (Exception $e) {
            error_log('Database Error: ' . $e->getMessage());
            throw new Exception('Erreur de base de donnees: ' . $e->getMessage());
        }
    }
    
    public function callProcedure($procedureName, $params = []) {
        $placeholders = rtrim(str_repeat('?, ', count($params)), ', ');
        $sql = "CALL $procedureName($placeholders)";
        return $this->queryResultSets($sql, $params);
    }
    
    private function bindStatementParams($stmt, $params) {
        if (empty($params)) {
            return;
        }
        
        $types = '';
        foreach ($params as $param) {
            $types .= $this->resolveParamType($param);
        }
        
        $bindValues = [$types];
        foreach ($params as $key => $value) {
            $bindValues[] = &$params[$key];
        }
        
        call_user_func_array([$stmt, 'bind_param'], $bindValues);
    }
    
    private function resolveParamType($value) {
        if (is_int($value) || is_bool($value)) {
            return 'i';
        }
        
        if (is_float($value)) {
            return 'd';
        }
        
        if (is_null($value)) {
            return 's';
        }
        
        return 's';
    }
    
    private function clearPendingResults() {
        while ($this->conn->more_results()) {
            $this->conn->next_result();
            $result = $this->conn->store_result();
            if ($result instanceof mysqli_result) {
                $result->free();
            }
        }
    }
}