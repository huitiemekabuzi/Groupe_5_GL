<?php
require_once __DIR__ . '/../core/Model.php';

class PaiementModel extends Model {
    protected $table = 'paiements';
    protected $primaryKey = 'id_paiement';
    
    public function createPaiement($data) {
        $this->db->beginTransaction();
        
        try {
            // Appeler la procédure stockée
            $stmt = $this->db->query(
                "CALL sp_enregistrer_paiement(?, ?, ?, ?, ?, ?, ?, @id_paiement, @numero_paiement)",
                [
                    $data['id_inscription'],
                    $data['id_etudiant'],
                    $data['id_type_frais'],
                    $data['id_mode_paiement'],
                    $data['montant'],
                    $data['recu_par'],
                    $data['reference_transaction'] ?? null
                ]
            );
            
            // Récupérer les valeurs de sortie
            $result = $this->db->fetchOne("SELECT @id_paiement as id, @numero_paiement as numero");
            
            $this->db->commit();
            return $result;
            
        } catch (Exception $e) {
            $this->db->rollback();
            throw $e;
        }
    }
    
    public function getPaiementComplet($id) {
        return $this->db->fetchOne(
            "SELECT * FROM v_paiements_detailles WHERE id_paiement = ?",
            [$id]
        );
    }
    
    public function getPaiementByNumero($numero) {
        return $this->db->fetchOne(
            "SELECT * FROM v_paiements_detailles WHERE numero_paiement = ?",
            [$numero]
        );
    }
    
    public function getPaiementsByInscription($idInscription) {
        return $this->db->fetchAll(
            "SELECT * FROM v_paiements_detailles WHERE id_inscription = ? ORDER BY date_paiement DESC",
            [$idInscription]
        );
    }
    
    public function getPaiementsByEtudiant($idEtudiant, $idAnneeAcademique = null) {
        $sql = "SELECT p.*, i.numero_inscription, tf.nom_frais, mp.nom_mode, r.numero_recu
                FROM paiements p
                JOIN inscriptions i ON p.id_inscription = i.id_inscription
                JOIN types_frais tf ON p.id_type_frais = tf.id_type_frais
                JOIN modes_paiement mp ON p.id_mode_paiement = mp.id_mode_paiement
                LEFT JOIN recus r ON p.id_paiement = r.id_paiement
                WHERE p.id_etudiant = ? AND p.statut_paiement = 'Validé'";
        
        $params = [$idEtudiant];
        
        if ($idAnneeAcademique) {
            $sql .= " AND i.id_annee_academique = ?";
            $params[] = $idAnneeAcademique;
        }
        
        $sql .= " ORDER BY p.date_paiement DESC";
        
        return $this->db->fetchAll($sql, $params);
    }
    
    public function getAllPaiements($page, $pageSize, $filters = []) {
        $offset = ($page - 1) * $pageSize;
        $params = [];
        
        $sql = "SELECT * FROM v_paiements_detailles WHERE 1=1";
        
        if (!empty($filters['date_debut'])) {
            $sql .= " AND DATE(date_paiement) >= ?";
            $params[] = $filters['date_debut'];
        }
        
        if (!empty($filters['date_fin'])) {
            $sql .= " AND DATE(date_paiement) <= ?";
            $params[] = $filters['date_fin'];
        }
        
        if (!empty($filters['caissier'])) {
            $sql .= " AND recu_par = ?";
            $params[] = $filters['caissier'];
        }
        
        if (!empty($filters['mode_paiement'])) {
            $sql .= " AND id_mode_paiement = ?";
            $params[] = $filters['mode_paiement'];
        }
        
        if (!empty($filters['statut'])) {
            $sql .= " AND statut_paiement = ?";
            $params[] = $filters['statut'];
        }
        
        if (!empty($filters['search'])) {
            $sql .= " AND (numero_paiement LIKE ? OR numero_etudiant LIKE ? OR nom_complet_etudiant LIKE ?)";
            $search = "%{$filters['search']}%";
            $params = array_merge($params, [$search, $search, $search]);
        }
        
        $sql .= " ORDER BY date_paiement DESC LIMIT ? OFFSET ?";
        $params[] = $pageSize;
        $params[] = $offset;
        
        return $this->db->fetchAll($sql, $params);
    }
    
    public function getTotalPaiements($filters = []) {
        $params = [];
        $sql = "SELECT COUNT(*) FROM paiements p WHERE 1=1";
        
        if (!empty($filters['date_debut'])) {
            $sql .= " AND DATE(p.date_paiement) >= ?";
            $params[] = $filters['date_debut'];
        }
        
        if (!empty($filters['date_fin'])) {
            $sql .= " AND DATE(p.date_paiement) <= ?";
            $params[] = $filters['date_fin'];
        }
        
        if (!empty($filters['caissier'])) {
            $sql .= " AND p.recu_par = ?";
            $params[] = $filters['caissier'];
        }
        
        if (!empty($filters['statut'])) {
            $sql .= " AND p.statut_paiement = ?";
            $params[] = $filters['statut'];
        }
        
        return $this->db->fetchColumn($sql, $params);
    }
    
    public function annulerPaiement($id, $motif, $userId) {
        return $this->db->update(
            "UPDATE paiements SET statut_paiement = 'Annulé', motif_annulation = ?, annule_par = ?, date_annulation = NOW() WHERE id_paiement = ?",
            [$motif, $userId, $id]
        );
    }
    
    public function getMontantJournalier($date, $caissier = null) {
        $sql = "SELECT IFNULL(SUM(montant), 0) FROM paiements 
                WHERE DATE(date_paiement) = ? AND statut_paiement = 'Validé'";
        $params = [$date];
        
        if ($caissier) {
            $sql .= " AND recu_par = ?";
            $params[] = $caissier;
        }
        
        return $this->db->fetchColumn($sql, $params);
    }
    
    public function getMontantPeriode($dateDebut, $dateFin, $filters = []) {
        $sql = "SELECT IFNULL(SUM(montant), 0) FROM paiements 
                WHERE DATE(date_paiement) BETWEEN ? AND ? AND statut_paiement = 'Validé'";
        $params = [$dateDebut, $dateFin];
        
        if (!empty($filters['caissier'])) {
            $sql .= " AND recu_par = ?";
            $params[] = $filters['caissier'];
        }
        
        if (!empty($filters['mode_paiement'])) {
            $sql .= " AND id_mode_paiement = ?";
            $params[] = $filters['mode_paiement'];
        }
        
        return $this->db->fetchColumn($sql, $params);
    }
}