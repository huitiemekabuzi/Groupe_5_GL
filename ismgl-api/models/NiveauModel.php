<?php
require_once __DIR__ . '/../core/Model.php';

class NiveauModel extends Model {
    protected $table = 'niveaux';
    protected $primaryKey = 'id_niveau';
    
    public function getAllNiveaux() {
        return $this->db->fetchAll(
            "SELECT * FROM niveaux WHERE est_actif = TRUE ORDER BY ordre"
        );
    }
}