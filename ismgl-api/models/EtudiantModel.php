<?php
require_once __DIR__ . '/../core/Model.php';

class EtudiantModel extends Model {
    protected $table = 'etudiants';
    protected $primaryKey = 'id_etudiant';
    
    public function createEtudiant($userData, $etudiantData) {
        $this->db->beginTransaction();
        
        try {
            // Créer l'utilisateur
            $userModel = new UserModel();
            $userId = $userModel->createUser($userData);
            
            // Créer l'étudiant
            $etudiantId = $this->create([
                'id_user' => $userId,
                'numero_etudiant' => $etudiantData['numero_etudiant'],
                'date_naissance' => $etudiantData['date_naissance'],
                'lieu_naissance' => $etudiantData['lieu_naissance'] ?? null,
                'sexe' => $etudiantData['sexe'],
                'nationalite' => $etudiantData['nationalite'] ?? 'Congolaise',
                'adresse' => $etudiantData['adresse'] ?? null,
                'ville' => $etudiantData['ville'] ?? null,
                'province' => $etudiantData['province'] ?? null,
                'nom_pere' => $etudiantData['nom_pere'] ?? null,
                'nom_mere' => $etudiantData['nom_mere'] ?? null,
                'telephone_urgence' => $etudiantData['telephone_urgence'] ?? null,
                'groupe_sanguin' => $etudiantData['groupe_sanguin'] ?? null,
                'photo_identite' => $etudiantData['photo_identite'] ?? null,
                'date_premiere_inscription' => date('Y-m-d')
            ]);
            
            $this->db->commit();
            return $etudiantId;
            
        } catch (Exception $e) {
            $this->db->rollback();
            throw $e;
        }
    }
    
    public function getEtudiantComplet($id) {
        return $this->db->fetchOne(
            "SELECT e.*, u.matricule, u.nom, u.prenom, u.email, u.telephone, 
                    u.photo_profil, u.est_actif
             FROM etudiants e
             JOIN users u ON e.id_user = u.id_user
             WHERE e.id_etudiant = ?",
            [$id]
        );
    }
    
    public function getEtudiantByUser($userId) {
        return $this->db->fetchOne(
            "SELECT e.*, u.matricule, u.nom, u.prenom, u.email, u.telephone
             FROM etudiants e
             JOIN users u ON e.id_user = u.id_user
             WHERE e.id_user = ?",
            [$userId]
        );
    }
    
    public function getEtudiantByNumero($numero) {
        return $this->db->fetchOne(
            "SELECT e.*, u.nom, u.prenom, u.email
             FROM etudiants e
             JOIN users u ON e.id_user = u.id_user
             WHERE e.numero_etudiant = ?",
            [$numero]
        );
    }
    
    public function getAllEtudiants($page, $pageSize, $filters = []) {
        $offset = ($page - 1) * $pageSize;
        $params = [];
        
        $sql = "SELECT e.id_etudiant, e.numero_etudiant, e.date_naissance, e.sexe, 
                       e.statut, e.date_premiere_inscription,
                       u.matricule, u.nom, u.prenom, u.email, u.telephone, u.est_actif
                FROM etudiants e
                JOIN users u ON e.id_user = u.id_user
                WHERE 1=1";
        
        if (!empty($filters['statut'])) {
            $sql .= " AND e.statut = ?";
            $params[] = $filters['statut'];
        }
        
        if (!empty($filters['sexe'])) {
            $sql .= " AND e.sexe = ?";
            $params[] = $filters['sexe'];
        }
        
        if (!empty($filters['search'])) {
            $sql .= " AND (u.nom LIKE ? OR u.prenom LIKE ? OR e.numero_etudiant LIKE ? OR u.email LIKE ?)";
            $search = "%{$filters['search']}%";
            $params = array_merge($params, [$search, $search, $search, $search]);
        }
        
        $sql .= " ORDER BY e.date_creation DESC LIMIT ? OFFSET ?";
        $params[] = $pageSize;
        $params[] = $offset;
        
        return $this->db->fetchAll($sql, $params);
    }
    
    public function getTotalEtudiants($filters = []) {
        $params = [];
        $sql = "SELECT COUNT(*) FROM etudiants e JOIN users u ON e.id_user = u.id_user WHERE 1=1";
        
        if (!empty($filters['statut'])) {
            $sql .= " AND e.statut = ?";
            $params[] = $filters['statut'];
        }
        
        if (!empty($filters['sexe'])) {
            $sql .= " AND e.sexe = ?";
            $params[] = $filters['sexe'];
        }
        
        if (!empty($filters['search'])) {
            $sql .= " AND (u.nom LIKE ? OR u.prenom LIKE ? OR e.numero_etudiant LIKE ?)";
            $search = "%{$filters['search']}%";
            $params = array_merge($params, [$search, $search, $search]);
        }
        
        return $this->db->fetchColumn($sql, $params);
    }
    
    public function updateStatut($id, $statut) {
        return $this->update($id, ['statut' => $statut]);
    }
    
    public function generateNumeroEtudiant() {
        $annee = date('Y');
        $count = $this->db->fetchColumn(
            "SELECT COUNT(*) + 1 FROM etudiants WHERE YEAR(date_creation) = ?",
            [$annee]
        );
        
        return sprintf("ETU%s%05d", $annee, $count);
    }
}