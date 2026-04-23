<?php
require_once __DIR__ . '/../core/Model.php';

class FiliereModel extends Model {
    protected $table = 'filieres';
    protected $primaryKey = 'id_filiere';
    
    public function getAllFilieres() {
        return $this->db->fetchAll(
            "SELECT f.*, d.nom_departement, fac.nom_faculte
             FROM filieres f
             JOIN departements d ON f.id_departement = d.id_departement
             JOIN facultes fac ON d.id_faculte = fac.id_faculte
             WHERE f.est_actif = TRUE
             ORDER BY f.nom_filiere"
        );
    }
    
    public function getFiliereComplete($id) {
        return $this->db->fetchOne(
            "SELECT f.*, d.nom_departement, d.code_departement, 
                    fac.nom_faculte, fac.code_faculte
             FROM filieres f
             JOIN departements d ON f.id_departement = d.id_departement
             JOIN facultes fac ON d.id_faculte = fac.id_faculte
             WHERE f.id_filiere = ?",
            [$id]
        );
    }
    
    public function getFilieresByDepartement($idDepartement) {
        return $this->db->fetchAll(
            "SELECT * FROM filieres WHERE id_departement = ? AND est_actif = TRUE ORDER BY nom_filiere",
            [$idDepartement]
        );
    }
    
    public function getFilieresByFaculte($idFaculte) {
        return $this->db->fetchAll(
            "SELECT f.* FROM filieres f
             JOIN departements d ON f.id_departement = d.id_departement
             WHERE d.id_faculte = ? AND f.est_actif = TRUE
             ORDER BY f.nom_filiere",
            [$idFaculte]
        );
    }
}