<?php
require_once __DIR__ . '/../core/Model.php';

class InscriptionModel extends Model {
    protected $table = 'inscriptions';
    protected $primaryKey = 'id_inscription';
    
    public function createInscription($data) {
        $this->db->beginTransaction();
        
        try {
            // Appeler la procédure stockée
            $stmt = $this->db->query(
                "CALL sp_enregistrer_inscription(?, ?, ?, ?, ?, @id_inscription, @numero_inscription, @montant_total)",
                [
                    $data['id_etudiant'],
                    $data['id_filiere'],
                    $data['id_niveau'],
                    $data['id_annee_academique'],
                    $data['type_inscription']
                ]
            );
            
            // Récupérer les valeurs de sortie
            $result = $this->db->fetchOne("SELECT @id_inscription as id, @numero_inscription as numero, @montant_total as montant");
            
            $this->db->commit();
            return $result;
            
        } catch (Exception $e) {
            $this->db->rollback();
            throw $e;
        }
    }
    
    public function getInscriptionComplete($id) {
        return $this->db->fetchOne(
            "SELECT i.*, 
                    e.numero_etudiant,
                    u.nom, u.prenom, u.email, u.telephone,
                    f.nom_filiere, f.code_filiere,
                    n.nom_niveau, n.code_niveau,
                    aa.code_annee,
                    d.nom_departement,
                    fac.nom_faculte
             FROM inscriptions i
             JOIN etudiants e ON i.id_etudiant = e.id_etudiant
             JOIN users u ON e.id_user = u.id_user
             JOIN filieres f ON i.id_filiere = f.id_filiere
             JOIN niveaux n ON i.id_niveau = n.id_niveau
             JOIN annees_academiques aa ON i.id_annee_academique = aa.id_annee_academique
             JOIN departements d ON f.id_departement = d.id_departement
             JOIN facultes fac ON d.id_faculte = fac.id_faculte
             WHERE i.id_inscription = ?",
            [$id]
        );
    }
    
    public function getInscriptionByNumero($numero) {
        return $this->db->fetchOne(
            "SELECT * FROM v_inscriptions_detaillees WHERE numero_inscription = ?",
            [$numero]
        );
    }
    
    public function getInscriptionsByEtudiant($idEtudiant, $idAnneeAcademique = null) {
        $sql = "SELECT i.*, f.nom_filiere, n.nom_niveau, aa.code_annee
                FROM inscriptions i
                JOIN filieres f ON i.id_filiere = f.id_filiere
                JOIN niveaux n ON i.id_niveau = n.id_niveau
                JOIN annees_academiques aa ON i.id_annee_academique = aa.id_annee_academique
                WHERE i.id_etudiant = ?";
        
        $params = [$idEtudiant];
        
        if ($idAnneeAcademique) {
            $sql .= " AND i.id_annee_academique = ?";
            $params[] = $idAnneeAcademique;
        }
        
        $sql .= " ORDER BY i.date_inscription DESC";
        
        return $this->db->fetchAll($sql, $params);
    }
    
    public function getAllInscriptions($page, $pageSize, $filters = []) {
        $offset = ($page - 1) * $pageSize;
        $params = [];
        
        $sql = "SELECT * FROM v_inscriptions_detaillees WHERE 1=1";
        
        if (!empty($filters['annee_academique'])) {
            $sql .= " AND id_annee_academique = ?";
            $params[] = $filters['annee_academique'];
        }
        
        if (!empty($filters['filiere'])) {
            $sql .= " AND id_filiere = ?";
            $params[] = $filters['filiere'];
        }
        
        if (!empty($filters['niveau'])) {
            $sql .= " AND id_niveau = ?";
            $params[] = $filters['niveau'];
        }
        
        if (!empty($filters['statut'])) {
            $sql .= " AND statut_inscription = ?";
            $params[] = $filters['statut'];
        }
        
        if (!empty($filters['type'])) {
            $sql .= " AND type_inscription = ?";
            $params[] = $filters['type'];
        }
        
        if (!empty($filters['id_etudiant'])) {
            $sql .= " AND id_etudiant = ?";
            $params[] = $filters['id_etudiant'];
        }
        
        if (!empty($filters['search'])) {
            $sql .= " AND (nom LIKE ? OR prenom LIKE ? OR numero_inscription LIKE ? OR numero_etudiant LIKE ?)";
            $search = "%{$filters['search']}%";
            $params = array_merge($params, [$search, $search, $search, $search]);
        }
        
        $sql .= " ORDER BY date_inscription DESC LIMIT ? OFFSET ?";
        $params[] = $pageSize;
        $params[] = $offset;
        
        return $this->db->fetchAll($sql, $params);
    }
    
    public function getTotalInscriptions($filters = []) {
        $params = [];
        $sql = "SELECT COUNT(*) FROM v_inscriptions_detaillees WHERE 1=1";
        
        if (!empty($filters['annee_academique'])) {
            $sql .= " AND id_annee_academique = ?";
            $params[] = $filters['annee_academique'];
        }
        
        if (!empty($filters['filiere'])) {
            $sql .= " AND id_filiere = ?";
            $params[] = $filters['filiere'];
        }
        
        if (!empty($filters['niveau'])) {
            $sql .= " AND id_niveau = ?";
            $params[] = $filters['niveau'];
        }
        
        if (!empty($filters['statut'])) {
            $sql .= " AND statut_inscription = ?";
            $params[] = $filters['statut'];
        }
        
        if (!empty($filters['type'])) {
            $sql .= " AND type_inscription = ?";
            $params[] = $filters['type'];
        }
        
        if (!empty($filters['id_etudiant'])) {
            $sql .= " AND id_etudiant = ?";
            $params[] = $filters['id_etudiant'];
        }
        
        if (!empty($filters['search'])) {
            $sql .= " AND (nom LIKE ? OR prenom LIKE ? OR numero_inscription LIKE ? OR numero_etudiant LIKE ?)";
            $search = "%{$filters['search']}%";
            $params = array_merge($params, [$search, $search, $search, $search]);
        }
        
        return $this->db->fetchColumn($sql, $params);
    }
    
    public function validerInscription($id, $userId) {
        return $this->db->update(
            "UPDATE inscriptions SET statut_inscription = 'Validée', date_validation = NOW(), validee_par = ? WHERE id_inscription = ?",
            [$userId, $id]
        );
    }
    
    public function rejeterInscription($id, $motif, $userId) {
        return $this->db->update(
            "UPDATE inscriptions SET statut_inscription = 'Rejetée', motif_rejet = ?, validee_par = ?, date_validation = NOW() WHERE id_inscription = ?",
            [$motif, $userId, $id]
        );
    }
    
    public function annulerInscription($id) {
        return $this->update($id, ['statut_inscription' => 'Annulée']);
    }
    
    public function verifierInscriptionExistante($idEtudiant, $idAnneeAcademique) {
        return $this->db->fetchOne(
            "SELECT * FROM inscriptions WHERE id_etudiant = ? AND id_annee_academique = ?",
            [$idEtudiant, $idAnneeAcademique]
        );
    }
}