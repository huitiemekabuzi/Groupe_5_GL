<?php
require_once __DIR__ . '/../core/Model.php';

class TypeFraisModel extends Model {
    protected $table = 'types_frais';
    protected $primaryKey = 'id_type_frais';
    
    public function getAllTypesFrais() {
        return $this->db->fetchAll(
            "SELECT * FROM types_frais WHERE est_actif = TRUE ORDER BY nom_frais"
        );
    }
    
    public function getTypesFraisObligatoires() {
        return $this->db->fetchAll(
            "SELECT * FROM types_frais WHERE est_actif = TRUE AND est_obligatoire = TRUE ORDER BY nom_frais"
        );
    }
}