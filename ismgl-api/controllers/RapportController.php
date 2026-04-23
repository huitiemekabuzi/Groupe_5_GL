<?php
require_once __DIR__ . '/../core/Controller.php';
require_once __DIR__ . '/../middleware/AuthMiddleware.php';
require_once __DIR__ . '/../middleware/RoleMiddleware.php';
require_once __DIR__ . '/../models/RapportModel.php';
require_once __DIR__ . '/../models/AnneeAcademiqueModel.php';
require_once __DIR__ . '/../utils/PDFGenerator.php';

class RapportController extends Controller {
    private $rapportModel;
    private $anneeModel;

    public function __construct() {
        parent::__construct();
        $this->rapportModel = new RapportModel();
        $this->anneeModel   = new AnneeAcademiqueModel();
    }

    public function statistiquesGlobales() {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('rapport.general');

        try {
            $idAnnee = $_GET['annee'] ?? null;

            if (!$idAnnee) {
                $annee = $this->anneeModel->getAnneeCourante();
                $idAnnee = $annee['id_annee_academique'] ?? null;
            }

            if (!$idAnnee) {
                Response::error('Aucune année académique spécifiée', 400);
            }

            $stats = $this->rapportModel->getStatistiquesGlobales($idAnnee);
            Response::success($stats);
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }

    public function rapportPaiements() {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('rapport.caisse');

        try {
            $dateDebut  = $_GET['date_debut'] ?? date('Y-m-01');
            $dateFin    = $_GET['date_fin'] ?? date('Y-m-d');
            $idCaissier = $_GET['caissier'] ?? null;

            $paiements = $this->rapportModel->getRapportPaiementsPeriode($dateDebut, $dateFin, $idCaissier);

            $total = array_sum(array_column($paiements, 'montant'));

            Response::success([
                'periode'       => ['date_debut' => $dateDebut, 'date_fin' => $dateFin],
                'total_montant' => $total,
                'nombre'        => count($paiements),
                'paiements'     => $paiements
            ]);
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }

    public function situationEtudiant($idEtudiant) {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('rapport.etudiant');

        try {
            $idAnnee = $_GET['annee'] ?? null;

            if (!$idAnnee) {
                $annee = $this->anneeModel->getAnneeCourante();
                $idAnnee = $annee['id_annee_academique'] ?? null;
            }

            $situation = $this->rapportModel->getSituationEtudiant($idEtudiant, $idAnnee);
            Response::success($situation);
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }

    public function rapportJournalier() {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('rapport.caisse');

        try {
            $date = $_GET['date'] ?? date('Y-m-d');
            $rapport = $this->rapportModel->getRapportJournalierCaisse($date);

            $total = array_sum(array_column($rapport, 'montant_total'));

            Response::success([
                'date'          => $date,
                'montant_total' => $total,
                'details'       => $rapport
            ]);
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }

    public function etudiantsImpayes() {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('rapport.general');

        try {
            $idAnnee = $_GET['annee'] ?? null;

            if (!$idAnnee) {
                $annee   = $this->anneeModel->getAnneeCourante();
                $idAnnee = $annee['id_annee_academique'] ?? null;
            }

            $impayes         = $this->rapportModel->getEtudiantsImpayes($idAnnee);
            $montantTotal    = array_sum(array_column($impayes, 'montant_restant'));

            Response::success([
                'nombre_etudiants'  => count($impayes),
                'montant_total'     => $montantTotal,
                'etudiants'         => $impayes
            ]);
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }

    public function statistiquesFilieres() {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('rapport.general');

        try {
            $idAnnee = $_GET['annee'] ?? null;

            if (!$idAnnee) {
                $annee   = $this->anneeModel->getAnneeCourante();
                $idAnnee = $annee['id_annee_academique'] ?? null;
            }

            $stats = $this->rapportModel->getStatistiquesFilieres($idAnnee);
            Response::success($stats);
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }

    public function recapitulatifFinancier() {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('rapport.general');

        try {
            $idAnnee = $_GET['annee'] ?? null;

            if (!$idAnnee) {
                $annee   = $this->anneeModel->getAnneeCourante();
                $idAnnee = $annee['id_annee_academique'] ?? null;
            }

            $recap = $this->rapportModel->getRecapitulatifFinancier($idAnnee);
            Response::success($recap);
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }

    public function exportPDF() {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('rapport.general');

        try {
            $type    = $_GET['type'] ?? 'general';
            $idAnnee = $_GET['annee'] ?? null;

            if (!$idAnnee) {
                $annee   = $this->anneeModel->getAnneeCourante();
                $idAnnee = $annee['id_annee_academique'] ?? null;
            }

            $pdfGenerator = new PDFGenerator();
            $data         = [];

            switch ($type) {
                case 'paiements':
                    $dateDebut = $_GET['date_debut'] ?? date('Y-m-01');
                    $dateFin   = $_GET['date_fin'] ?? date('Y-m-d');
                    $data      = $this->rapportModel->getRapportPaiementsPeriode($dateDebut, $dateFin);
                    $pdfPath   = $pdfGenerator->generateRapportPaiements($data, $dateDebut, $dateFin);
                    break;

                case 'impayes':
                    $data    = $this->rapportModel->getEtudiantsImpayes($idAnnee);
                    $pdfPath = $pdfGenerator->generateRapportImpayes($data);
                    break;

                case 'filieres':
                    $data    = $this->rapportModel->getStatistiquesFilieres($idAnnee);
                    $pdfPath = $pdfGenerator->generateRapportFilieres($data);
                    break;

                default:
                    $data    = $this->rapportModel->getStatistiquesGlobales($idAnnee);
                    $pdfPath = $pdfGenerator->generateRapportGeneral($data);
            }

            $this->logActivity('EXPORT_PDF', 'Rapports', "Export PDF rapport type: $type");

            Response::success([
                'pdf_url' => BASE_URL . '/' . $pdfPath,
                'type'    => $type
            ], 'Rapport généré avec succès');
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }

    public function exportCSV() {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('rapport.general');

        try {
            $type      = $_GET['type'] ?? 'paiements';
            $dateDebut = $_GET['date_debut'] ?? date('Y-m-01');
            $dateFin   = $_GET['date_fin'] ?? date('Y-m-d');

            $data = $this->rapportModel->getRapportPaiementsPeriode($dateDebut, $dateFin);

            header('Content-Type: text/csv; charset=utf-8');
            header('Content-Disposition: attachment; filename="rapport_' . $type . '_' . date('Y-m-d') . '.csv"');

            $output = fopen('php://output', 'w');
            fprintf($output, chr(0xEF) . chr(0xBB) . chr(0xBF));

            // En-têtes CSV
            fputcsv($output, ['N° Paiement', 'Date', 'Étudiant', 'Type Frais', 'Montant', 'Mode', 'Référence', 'Statut']);

            foreach ($data as $row) {
                fputcsv($output, [
                    $row['numero_paiement'],
                    $row['date_paiement'],
                    $row['etudiant'],
                    $row['nom_frais'],
                    $row['montant'],
                    $row['mode_paiement'],
                    $row['reference_transaction'],
                    $row['statut_paiement']
                ]);
            }

            fclose($output);
            exit;
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }

    public function logsActivite() {
        AuthMiddleware::handle();
        RoleMiddleware::hasRole(ROLE_ADMIN);

        try {
            $logModel   = new LogModel();
            $pagination = $this->getPagination();
            $filters    = [
                'user'        => $_GET['user'] ?? null,
                'module'      => $_GET['module'] ?? null,
                'action'      => $_GET['action'] ?? null,
                'date_debut'  => $_GET['date_debut'] ?? null,
                'date_fin'    => $_GET['date_fin'] ?? null
            ];

            $logs  = $logModel->getLogs($pagination['page'], $pagination['page_size'], $filters);
            $total = $logModel->getTotalLogs($filters);

            Response::paginated($logs, $pagination['page'], $pagination['page_size'], $total);
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }
}