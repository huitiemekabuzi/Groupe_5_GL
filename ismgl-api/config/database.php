<?php
class DatabaseConfig {
    private static $instance = null;
    
    private $host = 'localhost';
    private $database = 'ismgl_db';
    private $username = 'root';
    private $password = '';
    private $charset = 'utf8mb4';
    
    private $connection = null;
    
    private function __construct() {
        $this->connection = @new mysqli(
            $this->host,
            $this->username,
            $this->password,
            $this->database
        );

        if ($this->connection->connect_error) {
            throw new Exception('Database connection failed: ' . $this->connection->connect_error);
        }

        if (!$this->connection->set_charset($this->charset)) {
            throw new Exception('Failed to set charset: ' . $this->connection->error);
        }
    }
    
    public static function getInstance() {
        if (self::$instance === null) {
            self::$instance = new self();
        }
        return self::$instance;
    }
    
    public function getConnection() {
        return $this->connection;
    }
    
    // Empêcher le clonage
    private function __clone() {}
    
    // Empêcher la désérialisation
    public function __wakeup() {
        throw new Exception("Cannot unserialize singleton");
    }
}