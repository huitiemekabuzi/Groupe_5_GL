<?php
require_once __DIR__ . '/../core/Controller.php';
require_once __DIR__ . '/../middleware/AuthMiddleware.php';
require_once __DIR__ . '/../middleware/RoleMiddleware.php';
require_once __DIR__ . '/../models/PaiementModel.php';
require_once __DIR__ . '/../models/NotificationModel.php';

class PaiementController extends Controller {
    private $paiementModel;
    private $notificationModel;
    
    public function __construct() {
        parent::__construct();
        $this->paiementModel = new PaiementModel();
        $this->notificationModel = new NotificationModel();
    }
    
    public function index() {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('paiement.read');
        
        try {
            $pagination = $this->getPagination();
            $filters = [
                'date_debut' => $_GET['date_debut'] ?? null,
                'date_fin' => $_GET['date_fin'] ?? null,
                'caissier' => $_GET['caissier'] ?? null,
                'mode_paiement' => $_GET['mode_paiement'] ?? null,
                'statut' => $_GET['statut'] ?? null,
                'search' => $_GET['search'] ?? null
            ];
            
            $paiements = $this->paiementModel->getAllPaiements(
                $pagination['page'],
                $pagination['page_size'],
                $filters
            );
            
            $total = $this->paiementModel->getTotalPaiements($filters);
            
            Response::paginated($paiements, $pagination['page'], $pagination['page_size'], $total);
            
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }
    
    public function show($id) {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('paiement.read');
        
        try {
            $paiement = $this->paiementModel->getPaiementComplet($id);
            
            if (!$paiement) {
                Response::notFound('Paiement non trouvé');
            }
            
            Response::success($paiement);
            
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }
    
    public function store() {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('paiement.create');
        
        $data = $this->getRequestData();
        
        // Validation
        $validator = new Validator($data);
        $validator->required(['id_inscription', 'id_etudiant', 'id_type_frais', 'id_mode_paiement', 'montant'])
                  ->numeric('montant')
                  ->min('montant', 0);
        
        if ($validator->fails()) {
            Response::validationError($validator->errors());
        }
        
        try {
            $data['recu_par'] = $this->getUserId();
            
            $result = $this->paiementModel->createPaiement($data);
            
            // Notification à l'étudiant
            $etudiantModel = new EtudiantModel();
            $etudiant = $etudiantModel->find($data['id_etudiant']);
            
            $this->notificationModel->createNotification(
                $etudiant['id_user'],
                'Nouveau paiement',
                "Votre paiement de {$data['montant']} FC a été enregistré. N° {$result['numero']}",
                'Succès',
                "/paiements/{$result['id']}"
            );
            
            $this->logActivity(
                'CREATE_PAIEMENT',
                'Paiements',
                "Enregistrement du paiement {$result['numero']}",
                null,
                $result
            );
            
            $paiement = $this->paiementModel->getPaiementComplet($result['id']);
            
            Response::created($paiement, 'Paiement enregistré avec succès');
            
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }
    
    public function annuler($id) {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('paiement.cancel');
        
        $data = $this->getRequestData();
        
        $validator = new Validator($data);
        $validator->required('motif');
        
        if ($validator->fails()) {
            Response::validationError($validator->errors());
        }
        
        try {
            $paiement = $this->paiementModel->find($id);
            if (!$paiement) {
                Response::notFound('Paiement non trouvé');
            }
            
            if ($paiement['statut_paiement'] === 'Annulé') {
                Response::error('Ce paiement est déjà annulé', 400);
            }
            
            $userId = $this->getUserId();
            $this->paiementModel->annulerPaiement($id, $data['motif'], $userId);
            
            $this->logActivity(
                'CANCEL_PAIEMENT',
                'Paiements',
                "Annulation du paiement ID: $id",
                $paiement,
                ['motif' => $data['motif']]
            );
            
            Response::success(null, 'Paiement annulé avec succès');
            
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }
    
    public function myPaiements() {
        AuthMiddleware::handle();
        
        try {
            $userId = $this->getUserId();
            $etudiantModel = new EtudiantModel();
            $etudiant = $etudiantModel->getEtudiantByUser($userId);
            
            if (!$etudiant) {
                Response::error('Profil étudiant non trouvé', 404);
            }
            
            $paiements = $this->paiementModel->getPaiementsByEtudiant($etudiant['id_etudiant']);
            
            Response::success($paiements);
            
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }
    
    public function rapportJournalier() {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('rapport.caisse');
        
        try {
            $date = $_GET['date'] ?? date('Y-m-d');
            $caissier = $_GET['caissier'] ?? null;
            
            $montant = $this->paiementModel->getMontantJournalier($date, $caissier);
            
            Response::success([
                'date' => $date,
                'montant_total' => $montant,
                'caissier' => $caissier
            ]);
            
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }
}