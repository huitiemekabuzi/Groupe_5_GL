<?php
require_once __DIR__ . '/../core/Controller.php';
require_once __DIR__ . '/../middleware/AuthMiddleware.php';
require_once __DIR__ . '/../models/AnneeAcademiqueModel.php';
require_once __DIR__ . '/../models/RapportModel.php';

class DashboardController extends Controller {
    private $anneeModel;
    private $rapportModel;

    public function __construct() {
        parent::__construct();
        $this->anneeModel   = new AnneeAcademiqueModel();
        $this->rapportModel = new RapportModel();
    }

    public function index() {
        AuthMiddleware::handle();

        try {
            $user    = $this->getCurrentUser();
            $idRole  = $user['id_role'];

            switch ($idRole) {
                case ROLE_ADMIN:
                    $data = $this->dashboardAdmin();
                    break;
                case ROLE_CAISSIER:
                    $data = $this->dashboardCaissier();
                    break;
                case ROLE_GESTIONNAIRE:
                    $data = $this->dashboardGestionnaire();
                    break;
                case ROLE_ETUDIANT:
                    $data = $this->dashboardEtudiant();
                    break;
                case ROLE_COMPTABLE:
                    $data = $this->dashboardComptable();
                    break;
                default:
                    $data = [];
            }

            Response::success($data);
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }

    private function dashboardAdmin() {
        $annee   = $this->anneeModel->getAnneeCourante();
        $idAnnee = $annee['id_annee_academique'] ?? null;

        $stats   = $idAnnee ? $this->rapportModel->getStatistiquesGlobales($idAnnee) : [];
        $recap   = $idAnnee ? $this->rapportModel->getRecapitulatifFinancier($idAnnee) : [];

        return [
            'role'                => 'Administrateur',
            'annee_courante'      => $annee,
            'statistiques'        => $stats,
            'financier'           => $recap,
            'paiements_recents'   => $this->db->fetchAll(
                "SELECT * FROM v_paiements_detailles WHERE statut_paiement = 'Validé' ORDER BY date_paiement DESC LIMIT 10"
            ),
            'inscriptions_recentes' => $this->db->fetchAll(
                "SELECT * FROM v_inscriptions_detaillees ORDER BY date_inscription DESC LIMIT 10"
            ),
            'etudiants_impayes_count' => $this->db->fetchColumn(
                "SELECT COUNT(*) FROM inscriptions WHERE montant_restant > 0 AND statut_inscription = 'Validée'"
            ),
            'utilisateurs_actifs' => $this->db->fetchColumn(
                "SELECT COUNT(*) FROM users WHERE est_actif = TRUE"
            )
        ];
    }

    private function dashboardCaissier() {
        $userId     = $this->getUserId();
        $today      = date('Y-m-d');

        return [
            'role'                     => 'Caissier',
            'paiements_aujourd_hui'    => $this->db->fetchAll(
                "SELECT * FROM v_paiements_detailles WHERE DATE(date_paiement) = ? AND recu_par = ? ORDER BY date_paiement DESC",
                [$today, $userId]
            ),
            'montant_aujourd_hui'      => $this->db->fetchColumn(
                "SELECT IFNULL(SUM(montant), 0) FROM paiements WHERE DATE(date_paiement) = ? AND recu_par = ? AND statut_paiement = 'Validé'",
                [$today, $userId]
            ),
            'nombre_paiements_jour'    => $this->db->fetchColumn(
                "SELECT COUNT(*) FROM paiements WHERE DATE(date_paiement) = ? AND recu_par = ? AND statut_paiement = 'Validé'",
                [$today, $userId]
            ),
            'rapport_modes_paiement'   => $this->db->fetchAll(
                "SELECT mp.nom_mode, COUNT(p.id_paiement) as nombre, SUM(p.montant) as total
                 FROM paiements p JOIN modes_paiement mp ON p.id_mode_paiement = mp.id_mode_paiement
                 WHERE DATE(p.date_paiement) = ? AND p.recu_par = ? AND p.statut_paiement = 'Validé'
                 GROUP BY mp.id_mode_paiement, mp.nom_mode",
                [$today, $userId]
            )
        ];
    }

    private function dashboardGestionnaire() {
        $annee      = $this->anneeModel->getAnneeCourante();
        $idAnnee    = $annee['id_annee_academique'] ?? null;

        return [
            'role'                          => 'Gestionnaire',
            'annee_courante'                => $annee,
            'total_etudiants'               => $this->db->fetchColumn(
                "SELECT COUNT(*) FROM etudiants WHERE statut = 'Actif'"
            ),
            'inscriptions_en_attente'       => $this->db->fetchColumn(
                "SELECT COUNT(*) FROM inscriptions WHERE statut_inscription = 'En attente'"
            ),
            'inscriptions_recentes'         => $this->db->fetchAll(
                "SELECT * FROM v_inscriptions_detaillees ORDER BY date_inscription DESC LIMIT 15"
            ),
            'repartition_par_filiere'       => $this->db->fetchAll(
                "SELECT f.nom_filiere, COUNT(i.id_inscription) as nombre_inscriptions
                 FROM filieres f LEFT JOIN inscriptions i ON f.id_filiere = i.id_filiere
                 AND i.id_annee_academique = ?
                 GROUP BY f.id_filiere, f.nom_filiere ORDER BY nombre_inscriptions DESC",
                [$idAnnee]
            ),
            'repartition_par_sexe'          => $this->db->fetchAll(
                "SELECT e.sexe, COUNT(*) as nombre FROM etudiants e WHERE e.statut = 'Actif' GROUP BY e.sexe"
            )
        ];
    }

    private function dashboardEtudiant() {
        $userId     = $this->getUserId();
        $etudiant   = $this->db->fetchOne(
            "SELECT e.*, u.nom, u.prenom, u.email FROM etudiants e JOIN users u ON e.id_user = u.id_user WHERE e.id_user = ?",
            [$userId]
        );

        if (!$etudiant) {
            return ['role' => 'Etudiant', 'message' => 'Profil incomplet'];
        }

        $annee   = $this->anneeModel->getAnneeCourante();
        $idAnnee = $annee['id_annee_academique'] ?? null;

        $inscription = $idAnnee ? $this->db->fetchOne(
            "SELECT * FROM v_inscriptions_detaillees WHERE id_etudiant = ? AND id_annee_academique = ?",
            [$etudiant['id_etudiant'], $idAnnee]
        ) : null;

        return [
            'role'                  => 'Etudiant',
            'etudiant'              => $etudiant,
            'annee_courante'        => $annee,
            'inscription_courante'  => $inscription,
            'paiements_recents'     => $this->db->fetchAll(
                "SELECT * FROM v_paiements_detailles WHERE id_etudiant = ? ORDER BY date_paiement DESC LIMIT 5",
                [$etudiant['id_etudiant']]
            ),
            'notifications_recentes' => $this->db->fetchAll(
                "SELECT * FROM notifications WHERE id_user = ? AND est_lu = FALSE ORDER BY date_creation DESC LIMIT 5",
                [$userId]
            )
        ];
    }

    private function dashboardComptable() {
        $annee   = $this->anneeModel->getAnneeCourante();
        $idAnnee = $annee['id_annee_academique'] ?? null;

        return [
            'role'              => 'Comptable',
            'annee_courante'    => $annee,
            'recap_financier'   => $idAnnee ? $this->rapportModel->getRecapitulatifFinancier($idAnnee) : [],
            'stats_filieres'    => $idAnnee ? $this->rapportModel->getStatistiquesFilieres($idAnnee) : [],
            'rapport_journalier' => $this->rapportModel->getRapportJournalierCaisse(date('Y-m-d')),
            'evolution_mensuelle' => $this->db->fetchAll(
                "SELECT MONTH(date_paiement) as mois, YEAR(date_paiement) as annee,
                        SUM(montant) as total, COUNT(*) as nombre
                 FROM paiements WHERE statut_paiement = 'Validé' AND YEAR(date_paiement) = YEAR(CURDATE())
                 GROUP BY YEAR(date_paiement), MONTH(date_paiement)
                 ORDER BY annee, mois"
            )
        ];
    }
}