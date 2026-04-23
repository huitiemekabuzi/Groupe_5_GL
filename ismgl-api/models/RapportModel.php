<?php
require_once __DIR__ . '/../core/Model.php';

class RapportModel extends Model {
    
    public function getStatistiquesGlobales($idAnneeAcademique) {
        $resultSets = $this->db->queryResultSets("CALL sp_rapport_statistiques_globales(?)", [$idAnneeAcademique]);
        return $resultSets[0][0] ?? null;
    }
    
    public function getRapportPaiementsPeriode($dateDebut, $dateFin, $idCaissier = null) {
        $resultSets = $this->db->queryResultSets(
            "CALL sp_rapport_paiements_periode(?, ?, ?)",
            [$dateDebut, $dateFin, $idCaissier]
        );
        return $resultSets[0] ?? [];
    }
    
    public function getSituationEtudiant($idEtudiant, $idAnneeAcademique) {
        $resultSets = $this->db->queryResultSets(
            "CALL sp_rapport_situation_etudiant(?, ?)",
            [$idEtudiant, $idAnneeAcademique]
        );
        
        return [
            'inscription' => $resultSets[0][0] ?? null,
            'paiements' => $resultSets[1] ?? []
        ];
    }
    
    public function getRapportJournalierCaisse($date = null) {
        $date = $date ?? date('Y-m-d');
        return $this->db->fetchAll(
            "SELECT * FROM v_rapport_journalier_caisse WHERE date_operation = ? ORDER BY caissier, nom_mode",
            [$date]
        );
    }
    
    public function getEtudiantsImpayes($idAnneeAcademique = null) {
        $sql = "SELECT * FROM v_etudiants_impayes WHERE 1=1";
        $params = [];
        
        if ($idAnneeAcademique) {
            $sql .= " AND id_annee_academique = ?";
            $params[] = $idAnneeAcademique;
        }
        
        $sql .= " ORDER BY montant_restant DESC";
        
        return $this->db->fetchAll($sql, $params);
    }
    
    public function getStatistiquesFilieres($idAnneeAcademique) {
        return $this->db->fetchAll(
            "SELECT * FROM v_statistiques_filieres WHERE code_annee = (SELECT code_annee FROM annees_academiques WHERE id_annee_academique = ?)",
            [$idAnneeAcademique]
        );
    }
    
    public function getRecapitulatifFinancier($idAnneeAcademique) {
        return $this->db->fetchOne(
            "SELECT 
                SUM(montant_total) as montant_attendu,
                SUM(montant_paye) as montant_percu,
                SUM(montant_restant) as montant_impaye,
                COUNT(*) as nombre_inscriptions,
                COUNT(CASE WHEN est_complete THEN 1 END) as inscriptions_completes,
                ROUND((SUM(montant_paye) / SUM(montant_total)) * 100, 2) as taux_recouvrement
             FROM inscriptions
             WHERE id_annee_academique = ? AND statut_inscription = 'Validée'",
            [$idAnneeAcademique]
        );
    }
}