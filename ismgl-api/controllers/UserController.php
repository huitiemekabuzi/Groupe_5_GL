<?php
require_once __DIR__ . '/../core/Controller.php';
require_once __DIR__ . '/../core/Response.php';
require_once __DIR__ . '/../middleware/AuthMiddleware.php';
require_once __DIR__ . '/../middleware/RoleMiddleware.php';
require_once __DIR__ . '/../models/UserModel.php';

class UserController extends Controller {
    private $userModel;
    
    public function __construct() {
        parent::__construct();
        $this->userModel = new UserModel();
    }
    
    public function index() {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('user.read');
        
        try {
            $pagination = $this->getPagination();
            $filters = [
                'role' => $_GET['role'] ?? null,
                'actif' => $_GET['actif'] ?? null,
                'search' => $_GET['search'] ?? null
            ];
            
            $users = $this->userModel->getAllUsers(
                $pagination['page'],
                $pagination['page_size'],
                $filters
            );
            
            $total = $this->userModel->getTotalUsers($filters);
            
            Response::paginated($users, $pagination['page'], $pagination['page_size'], $total);
            
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }
    
    public function show($id) {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('user.read');
        
        try {
            $user = $this->userModel->getUserWithRole($id);
            
            if (!$user) {
                Response::notFound('Utilisateur non trouvé');
            }
            
            unset($user['mot_de_passe']);
            
            Response::success($user);
            
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }
    
    public function store() {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('user.create');
        
        $data = $this->getRequestData();
        
        // Validation
        $validator = new Validator($data);
        $validator->required(['matricule', 'nom', 'prenom', 'email', 'mot_de_passe', 'id_role'])
                  ->email('email')
                  ->password('mot_de_passe')
                  ->unique('email', 'users', 'email')
                  ->unique('matricule', 'users', 'matricule');
        
        if ($validator->fails()) {
            Response::validationError($validator->errors());
        }
        
        try {
            $userId = $this->userModel->createUser($data);
            
            $this->logActivity(
                'CREATE_USER',
                'Utilisateurs',
                "Création de l'utilisateur {$data['email']}",
                null,
                $data
            );
            
            $user = $this->userModel->getUserWithRole($userId);
            unset($user['mot_de_passe']);
            
            Response::created($user, 'Utilisateur créé avec succès');
            
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }
    
    public function update($id) {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('user.update');
        
        $data = $this->getRequestData();
        
        try {
            $user = $this->userModel->find($id);
            if (!$user) {
                Response::notFound('Utilisateur non trouvé');
            }
            
            // Validation
            $validator = new Validator($data);
            if (isset($data['email'])) {
                $validator->email('email')->unique('email', 'users', 'email', $id);
            }
            
            if ($validator->fails()) {
                Response::validationError($validator->errors());
            }
            
            $updateData = [];
            $allowedFields = ['nom', 'prenom', 'email', 'telephone', 'id_role', 'photo_profil', 'est_actif'];
            
            foreach ($allowedFields as $field) {
                if (isset($data[$field])) {
                    $updateData[$field] = $data[$field];
                }
            }
            
            $this->userModel->update($id, $updateData);
            
            $this->logActivity(
                'UPDATE_USER',
                'Utilisateurs',
                "Modification de l'utilisateur ID: $id",
                $user,
                $updateData
            );
            
            $updatedUser = $this->userModel->getUserWithRole($id);
            unset($updatedUser['mot_de_passe']);
            
            Response::updated($updatedUser);
            
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }
    
    public function delete($id) {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('user.delete');
        
        try {
            $user = $this->userModel->find($id);
            if (!$user) {
                Response::notFound('Utilisateur non trouvé');
            }
            
            // Empêcher la suppression de son propre compte
            if ($id == $this->getUserId()) {
                Response::error('Vous ne pouvez pas supprimer votre propre compte', 400);
            }
            
            $this->userModel->delete($id);
            
            $this->logActivity(
                'DELETE_USER',
                'Utilisateurs',
                "Suppression de l'utilisateur ID: $id",
                $user,
                null
            );
            
            Response::deleted();
            
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }
    
    public function toggleActive($id) {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('user.update');
        
        try {
            $user = $this->userModel->find($id);
            if (!$user) {
                Response::notFound('Utilisateur non trouvé');
            }
            
            $newStatus = !$user['est_actif'];
            $this->userModel->update($id, ['est_actif' => $newStatus]);
            
            $this->logActivity(
                'TOGGLE_USER_STATUS',
                'Utilisateurs',
                "Changement de statut utilisateur ID: $id",
                ['est_actif' => $user['est_actif']],
                ['est_actif' => $newStatus]
            );
            
            Response::success(['est_actif' => $newStatus], 'Statut modifié avec succès');
            
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }
    
    public function unlockAccount($id) {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('user.update');
        
        try {
            $this->userModel->unlockAccount($id);
            
            $this->logActivity(
                'UNLOCK_ACCOUNT',
                'Utilisateurs',
                "Déverrouillage du compte utilisateur ID: $id"
            );
            
            Response::success(null, 'Compte déverrouillé avec succès');
            
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }
}