<?php
require_once __DIR__ . '/../core/Model.php';

class AnneeAcademiqueModel extends Model {
    protected $table = 'annees_academiques';
    protected $primaryKey = 'id_annee_academique';
    
    public function getAllAnneesAcademiques() {
        return $this->db->fetchAll(
            "SELECT * FROM annees_academiques ORDER BY annee_debut DESC"
        );
    }
    
    public function getAnneeCourante() {
        return $this->db->fetchOne(
            "SELECT * FROM annees_academiques WHERE est_courante = TRUE"
        );
    }
    
    public function setAnneeCourante($id) {
        $this->db->beginTransaction();
        
        try {
            // Désactiver toutes les années courantes
            $this->db->update("UPDATE annees_academiques SET est_courante = FALSE");
            
            // Activer l'année sélectionnée
            $this->db->update("UPDATE annees_academiques SET est_courante = TRUE WHERE id_annee_academique = ?", [$id]);
            
            $this->db->commit();
            return true;
        } catch (Exception $e) {
            $this->db->rollback();
            throw $e;
        }
    }
    
    public function cloturerAnnee($id) {
        return $this->db->update(
            "UPDATE annees_academiques SET est_cloturee = TRUE, date_cloture = NOW() WHERE id_annee_academique = ?",
            [$id]
        );
    }
}