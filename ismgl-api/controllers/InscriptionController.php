<?php
require_once __DIR__ . '/../core/Controller.php';
require_once __DIR__ . '/../middleware/AuthMiddleware.php';
require_once __DIR__ . '/../middleware/RoleMiddleware.php';
require_once __DIR__ . '/../models/InscriptionModel.php';
require_once __DIR__ . '/../models/NotificationModel.php';

class InscriptionController extends Controller {
    private $inscriptionModel;
    private $notificationModel;
    
    public function __construct() {
        parent::__construct();
        $this->inscriptionModel = new InscriptionModel();
        $this->notificationModel = new NotificationModel();
    }
    
    public function index() {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('inscription.read');
        
        try {
            $pagination = $this->getPagination();
            $filters = [
                'annee_academique' => $_GET['annee_academique'] ?? null,
                'filiere' => $_GET['filiere'] ?? null,
                'niveau' => $_GET['niveau'] ?? null,
                'statut' => $_GET['statut'] ?? null,
                'type' => $_GET['type'] ?? null,
                'search' => $_GET['search'] ?? null,
                'id_etudiant' => $_GET['id_etudiant'] ?? null
            ];
            
            $inscriptions = $this->inscriptionModel->getAllInscriptions(
                $pagination['page'],
                $pagination['page_size'],
                $filters
            );
            
            $total = $this->inscriptionModel->getTotalInscriptions($filters);
            
            Response::paginated($inscriptions, $pagination['page'], $pagination['page_size'], $total);
            
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }
    
    public function show($id) {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('inscription.read');
        
        try {
            $inscription = $this->inscriptionModel->getInscriptionComplete($id);
            
            if (!$inscription) {
                Response::notFound('Inscription non trouvée');
            }
            
            Response::success($inscription);
            
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }
    
    public function store() {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('inscription.create');
        
        $data = $this->getRequestData();
        
        // Validation
        $validator = new Validator($data);
        $validator->required(['id_etudiant', 'id_filiere', 'id_niveau', 'id_annee_academique', 'type_inscription'])
                  ->in('type_inscription', ['Nouvelle', 'Réinscription', 'Transfert']);
        
        if ($validator->fails()) {
            Response::validationError($validator->errors());
        }
        
        try {
            // Vérifier si l'étudiant a déjà une inscription pour cette année
            $existing = $this->inscriptionModel->verifierInscriptionExistante(
                $data['id_etudiant'],
                $data['id_annee_academique']
            );
            
            if ($existing) {
                Response::error('L\'étudiant est déjà inscrit pour cette année académique', 400);
            }
            
            $result = $this->inscriptionModel->createInscription($data);
            
            // Créer une notification pour l'étudiant
            $etudiantModel = new EtudiantModel();
            $etudiant = $etudiantModel->find($data['id_etudiant']);
            
            $this->notificationModel->createNotification(
                $etudiant['id_user'],
                'Nouvelle inscription',
                "Votre inscription N° {$result['numero']} a été enregistrée avec succès. Montant total: {$result['montant']} FC",
                'Succès',
                "/inscriptions/{$result['id']}"
            );
            
            $this->logActivity(
                'CREATE_INSCRIPTION',
                'Inscriptions',
                "Création de l'inscription {$result['numero']}",
                null,
                $result
            );
            
            $inscription = $this->inscriptionModel->getInscriptionComplete($result['id']);
            
            Response::created($inscription, 'Inscription enregistrée avec succès');
            
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }
    
    public function valider($id) {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('inscription.validate');
        
        try {
            $inscription = $this->inscriptionModel->find($id);
            if (!$inscription) {
                Response::notFound('Inscription non trouvée');
            }
            
            $userId = $this->getUserId();
            $this->inscriptionModel->validerInscription($id, $userId);
            
            // Notification à l'étudiant
            $etudiantModel = new EtudiantModel();
            $etudiant = $etudiantModel->find($inscription['id_etudiant']);
            
            $this->notificationModel->createNotification(
                $etudiant['id_user'],
                'Inscription validée',
                "Votre inscription N° {$inscription['numero_inscription']} a été validée",
                'Succès',
                "/inscriptions/{$id}"
            );
            
            $this->logActivity(
                'VALIDATE_INSCRIPTION',
                'Inscriptions',
                "Validation de l'inscription ID: $id"
            );
            
            Response::success(null, 'Inscription validée avec succès');
            
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }
    
    public function rejeter($id) {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('inscription.validate');
        
        $data = $this->getRequestData();
        
        $validator = new Validator($data);
        $validator->required('motif');
        
        if ($validator->fails()) {
            Response::validationError($validator->errors());
        }
        
        try {
            $inscription = $this->inscriptionModel->find($id);
            if (!$inscription) {
                Response::notFound('Inscription non trouvée');
            }
            
            $userId = $this->getUserId();
            $this->inscriptionModel->rejeterInscription($id, $data['motif'], $userId);
            
            // Notification à l'étudiant
            $etudiantModel = new EtudiantModel();
            $etudiant = $etudiantModel->find($inscription['id_etudiant']);
            
            $this->notificationModel->createNotification(
                $etudiant['id_user'],
                'Inscription rejetée',
                "Votre inscription N° {$inscription['numero_inscription']} a été rejetée. Motif: {$data['motif']}",
                'Erreur',
                "/inscriptions/{$id}"
            );
            
            $this->logActivity(
                'REJECT_INSCRIPTION',
                'Inscriptions',
                "Rejet de l'inscription ID: $id"
            );
            
            Response::success(null, 'Inscription rejetée');
            
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }
    
    public function myInscriptions() {
        AuthMiddleware::handle();
        
        try {
            $userId = $this->getUserId();
            $etudiantModel = new EtudiantModel();
            $etudiant = $etudiantModel->getEtudiantByUser($userId);
            
            if (!$etudiant) {
                Response::error('Profil étudiant non trouvé', 404);
            }
            
            $inscriptions = $this->inscriptionModel->getInscriptionsByEtudiant($etudiant['id_etudiant']);
            
            Response::success($inscriptions);
            
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }
}