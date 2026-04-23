<?php
require_once __DIR__ . '/../core/Model.php';

class RecuModel extends Model {
    protected $table = 'recus';
    protected $primaryKey = 'id_recu';
    
    public function getRecuComplet($id) {
        return $this->db->fetchOne(
            "SELECT r.*, p.numero_paiement, p.date_paiement, p.montant, p.reference_transaction,
                    e.numero_etudiant,
                    CONCAT(u.nom, ' ', u.prenom) as nom_complet_etudiant,
                    u.email, u.telephone,
                    tf.nom_frais,
                    mp.nom_mode as mode_paiement,
                    i.numero_inscription,
                    f.nom_filiere,
                    n.nom_niveau,
                    aa.code_annee,
                    CONCAT(ue.nom, ' ', ue.prenom) as emis_par_nom
             FROM recus r
             JOIN paiements p ON r.id_paiement = p.id_paiement
             JOIN etudiants e ON r.id_etudiant = e.id_etudiant
             JOIN users u ON e.id_user = u.id_user
             JOIN types_frais tf ON p.id_type_frais = tf.id_type_frais
             JOIN modes_paiement mp ON p.id_mode_paiement = mp.id_mode_paiement
             JOIN inscriptions i ON p.id_inscription = i.id_inscription
             JOIN filieres f ON i.id_filiere = f.id_filiere
             JOIN niveaux n ON i.id_niveau = n.id_niveau
             JOIN annees_academiques aa ON i.id_annee_academique = aa.id_annee_academique
             JOIN users ue ON r.emis_par = ue.id_user
             WHERE r.id_recu = ?",
            [$id]
        );
    }
    
    public function getRecuByNumero($numero) {
        return $this->getRecuComplet(
            $this->db->fetchColumn("SELECT id_recu FROM recus WHERE numero_recu = ?", [$numero])
        );
    }
    
    public function getRecuByPaiement($idPaiement) {
        return $this->db->fetchOne(
            "SELECT * FROM recus WHERE id_paiement = ?",
            [$idPaiement]
        );
    }
    
    public function marquerImprime($id) {
        return $this->db->update(
            "UPDATE recus SET est_imprime = TRUE, date_impression = NOW(), nombre_impressions = nombre_impressions + 1 WHERE id_recu = ?",
            [$id]
        );
    }
    
    public function getRecusByEtudiant($idEtudiant) {
        return $this->db->fetchAll(
            "SELECT r.*, p.montant, p.date_paiement, tf.nom_frais
             FROM recus r
             JOIN paiements p ON r.id_paiement = p.id_paiement
             JOIN types_frais tf ON p.id_type_frais = tf.id_type_frais
             WHERE r.id_etudiant = ?
             ORDER BY r.date_emission DESC",
            [$idEtudiant]
        );
    }
}