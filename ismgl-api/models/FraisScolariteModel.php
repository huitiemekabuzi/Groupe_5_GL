<?php
require_once __DIR__ . '/../core/Model.php';

class FraisScolariteModel extends Model {
    protected $table = 'frais_scolarite';
    protected $primaryKey = 'id_frais';
    
    public function getFraisByFiliereNiveau($idFiliere, $idNiveau, $idAnneeAcademique) {
        return $this->db->fetchAll(
            "SELECT fs.*, tf.nom_frais, tf.code_frais, tf.est_obligatoire
             FROM frais_scolarite fs
             JOIN types_frais tf ON fs.id_type_frais = tf.id_type_frais
             WHERE fs.id_filiere = ? AND fs.id_niveau = ? 
             AND fs.id_annee_academique = ? AND fs.est_actif = TRUE",
            [$idFiliere, $idNiveau, $idAnneeAcademique]
        );
    }
    
    public function getMontantTotal($idFiliere, $idNiveau, $idAnneeAcademique) {
        return $this->db->fetchColumn(
            "SELECT SUM(fs.montant) FROM frais_scolarite fs
             JOIN types_frais tf ON fs.id_type_frais = tf.id_type_frais
             WHERE fs.id_filiere = ? AND fs.id_niveau = ? 
             AND fs.id_annee_academique = ? AND fs.est_actif = TRUE
             AND tf.est_obligatoire = TRUE",
            [$idFiliere, $idNiveau, $idAnneeAcademique]
        ) ?? 0;
    }
}