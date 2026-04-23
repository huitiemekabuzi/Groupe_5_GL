<?php
require_once __DIR__ . '/../core/Controller.php';
require_once __DIR__ . '/../middleware/AuthMiddleware.php';
require_once __DIR__ . '/../middleware/RoleMiddleware.php';
require_once __DIR__ . '/../models/EtudiantModel.php';
require_once __DIR__ . '/../utils/FileUpload.php';

class EtudiantController extends Controller {
    private $etudiantModel;
    
    public function __construct() {
        parent::__construct();
        $this->etudiantModel = new EtudiantModel();
    }
    
    public function index() {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('etudiant.read');
        
        try {
            $pagination = $this->getPagination();
            $filters = [
                'statut' => $_GET['statut'] ?? null,
                'sexe' => $_GET['sexe'] ?? null,
                'search' => $_GET['search'] ?? null
            ];
            
            $etudiants = $this->etudiantModel->getAllEtudiants(
                $pagination['page'],
                $pagination['page_size'],
                $filters
            );
            
            $total = $this->etudiantModel->getTotalEtudiants($filters);
            
            Response::paginated($etudiants, $pagination['page'], $pagination['page_size'], $total);
            
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }
    
    public function show($id) {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('etudiant.read');
        
        try {
            $etudiant = $this->etudiantModel->getEtudiantComplet($id);
            
            if (!$etudiant) {
                Response::notFound('Étudiant non trouvé');
            }
            
            Response::success($etudiant);
            
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }
    
    public function store() {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('etudiant.create');
        
        $data = $this->getRequestData();
        
        // Validation
        $validator = new Validator($data);
        $validator->required(['nom', 'prenom', 'email', 'mot_de_passe', 'date_naissance', 'sexe'])
                  ->email('email')
                  ->date('date_naissance')
                  ->in('sexe', ['M', 'F'])
                  ->unique('email', 'users', 'email');
        
        if ($validator->fails()) {
            Response::validationError($validator->errors());
        }
        
        try {
            // Générer le numéro étudiant
            $numeroEtudiant = $this->etudiantModel->generateNumeroEtudiant();
            
            // Données utilisateur
            $userData = [
                'matricule' => $numeroEtudiant,
                'nom' => $data['nom'],
                'prenom' => $data['prenom'],
                'email' => $data['email'],
                'telephone' => $data['telephone'] ?? null,
                'mot_de_passe' => $data['mot_de_passe'],
                'id_role' => ROLE_ETUDIANT,
                'photo_profil' => null
            ];
            
            // Upload photo si présente
            if (isset($_FILES['photo_profil']) && $_FILES['photo_profil']['error'] === UPLOAD_ERR_OK) {
                $upload = new FileUpload();
                $photoPath = $upload->uploadImage($_FILES['photo_profil'], 'photos');
                $userData['photo_profil'] = $photoPath;
            }
            
            // Données étudiant
            $etudiantData = [
                'numero_etudiant' => $numeroEtudiant,
                'date_naissance' => $data['date_naissance'],
                'lieu_naissance' => $data['lieu_naissance'] ?? null,
                'sexe' => $data['sexe'],
                'nationalite' => $data['nationalite'] ?? 'Congolaise',
                'adresse' => $data['adresse'] ?? null,
                'ville' => $data['ville'] ?? null,
                'province' => $data['province'] ?? null,
                'nom_pere' => $data['nom_pere'] ?? null,
                'nom_mere' => $data['nom_mere'] ?? null,
                'telephone_urgence' => $data['telephone_urgence'] ?? null,
                'groupe_sanguin' => $data['groupe_sanguin'] ?? null,
                'photo_identite' => null
            ];
            
            // Upload photo d'identité si présente
            if (isset($_FILES['photo_identite']) && $_FILES['photo_identite']['error'] === UPLOAD_ERR_OK) {
                $upload = new FileUpload();
                $photoIdentitePath = $upload->uploadImage($_FILES['photo_identite'], 'photos');
                $etudiantData['photo_identite'] = $photoIdentitePath;
            }
            
            $etudiantId = $this->etudiantModel->createEtudiant($userData, $etudiantData);
            
            $this->logActivity(
                'CREATE_ETUDIANT',
                'Etudiants',
                "Création de l'étudiant {$numeroEtudiant}",
                null,
                $etudiantData
            );
            
            $etudiant = $this->etudiantModel->getEtudiantComplet($etudiantId);
            
            Response::created($etudiant, 'Étudiant créé avec succès');
            
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }
    
    public function update($id) {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('etudiant.update');
        
        $data = $this->getRequestData();
        
        try {
            $etudiant = $this->etudiantModel->find($id);
            if (!$etudiant) {
                Response::notFound('Étudiant non trouvé');
            }
            
            $updateData = [];
            $allowedFields = [
                'date_naissance', 'lieu_naissance', 'sexe', 'nationalite',
                'adresse', 'ville', 'province', 'nom_pere', 'nom_mere',
                'telephone_urgence', 'groupe_sanguin', 'statut'
            ];
            
            foreach ($allowedFields as $field) {
                if (isset($data[$field])) {
                    $updateData[$field] = $data[$field];
                }
            }
            
            if (!empty($updateData)) {
                $this->etudiantModel->update($id, $updateData);
            }
            
            // Mettre à jour les infos utilisateur si présentes
            if (isset($data['nom']) || isset($data['prenom']) || isset($data['email']) || isset($data['telephone'])) {
                $userModel = new UserModel();
                $userUpdateData = [];
                
                if (isset($data['nom'])) $userUpdateData['nom'] = $data['nom'];
                if (isset($data['prenom'])) $userUpdateData['prenom'] = $data['prenom'];
                if (isset($data['email'])) $userUpdateData['email'] = $data['email'];
                if (isset($data['telephone'])) $userUpdateData['telephone'] = $data['telephone'];
                
                if (!empty($userUpdateData)) {
                    $userModel->update($etudiant['id_user'], $userUpdateData);
                }
            }
            
            $this->logActivity(
                'UPDATE_ETUDIANT',
                'Etudiants',
                "Modification de l'étudiant ID: $id",
                $etudiant,
                $updateData
            );
            
            $updatedEtudiant = $this->etudiantModel->getEtudiantComplet($id);
            
            Response::updated($updatedEtudiant);
            
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }
    
    public function delete($id) {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('etudiant.delete');
        
        try {
            $etudiant = $this->etudiantModel->find($id);
            if (!$etudiant) {
                Response::notFound('Étudiant non trouvé');
            }
            
            $this->etudiantModel->delete($id);
            
            $this->logActivity(
                'DELETE_ETUDIANT',
                'Etudiants',
                "Suppression de l'étudiant ID: $id",
                $etudiant,
                null
            );
            
            Response::deleted();
            
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }
    
    public function myProfile() {
        AuthMiddleware::handle();
        
        try {
            $userId = $this->getUserId();
            $etudiant = $this->etudiantModel->getEtudiantByUser($userId);
            
            if (!$etudiant) {
                Response::notFound('Profil étudiant non trouvé');
            }
            
            Response::success($etudiant);
            
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }
    
    public function updateStatut($id) {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('etudiant.update');
        
        $data = $this->getRequestData();
        
        $validator = new Validator($data);
        $validator->required('statut')->in('statut', ['Actif', 'Suspendu', 'Diplômé', 'Abandonné']);
        
        if ($validator->fails()) {
            Response::validationError($validator->errors());
        }
        
        try {
            $this->etudiantModel->updateStatut($id, $data['statut']);
            
            $this->logActivity(
                'UPDATE_STATUT_ETUDIANT',
                'Etudiants',
                "Changement de statut étudiant ID: $id vers {$data['statut']}"
            );
            
            Response::success(['statut' => $data['statut']], 'Statut mis à jour avec succès');
            
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }
}