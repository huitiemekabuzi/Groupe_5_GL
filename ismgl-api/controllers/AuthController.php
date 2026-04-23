<?php
require_once __DIR__ . '/../core/Controller.php';
require_once __DIR__ . '/../core/Response.php';
require_once __DIR__ . '/../core/Validator.php';
require_once __DIR__ . '/../core/JWT.php';
require_once __DIR__ . '/../models/UserModel.php';

class AuthController extends Controller {
    private $userModel;
    
    public function __construct() {
        parent::__construct();
        $this->userModel = new UserModel();
    }
    
    public function login() {
        $data = $this->getRequestData();
        
        // Validation
        $validator = Validator::validate($data, [
            'email' => 'required|email',
            'mot_de_passe' => 'required'
        ]);
        
        if ($validator->fails()) {
            Response::validationError($validator->errors());
        }
        
        try {
            // Récupérer l'utilisateur
            $user = $this->userModel->findByEmail($data['email']);
            
            if (!$user) {
                Response::error('Email ou mot de passe incorrect', 401);
            }
            
            // Vérifier si le compte est bloqué
            if ($user['compte_bloque']) {
                $lockTime = strtotime($user['date_blocage']);
                $unlockTime = $lockTime + ACCOUNT_LOCKOUT_TIME;
                
                if (time() < $unlockTime) {
                    $minutes = ceil(($unlockTime - time()) / 60);
                    Response::error("Compte bloqué. Réessayez dans $minutes minutes.", 423);
                } else {
                    // Débloquer automatiquement après le délai
                    $this->userModel->unlockAccount($user['id_user']);
                }
            }
            
            // Vérifier le mot de passe
            if (!password_verify($data['mot_de_passe'], $user['mot_de_passe'])) {
                $this->userModel->incrementLoginAttempts($data['email']);
                Response::error('Email ou mot de passe incorrect', 401);
            }
            
            // Vérifier si l'utilisateur est actif
            if (!$user['est_actif']) {
                Response::error('Compte inactif. Contactez l\'administrateur.', 403);
            }
            
            // Générer le token JWT
            $payload = [
                'id_user' => $user['id_user'],
                'matricule' => $user['matricule'],
                'email' => $user['email'],
                'nom' => $user['nom'],
                'prenom' => $user['prenom'],
                'id_role' => $user['id_role'],
                'nom_role' => $user['nom_role']
            ];
            
            $token = JWT::encode($payload);
            $refreshToken = JWT::generateRefreshToken();
            
            // Créer une session
            $sessionId = $this->db->insert(
                "INSERT INTO sessions (id_user, token, refresh_token, ip_address, user_agent, date_expiration) 
                 VALUES (?, ?, ?, ?, ?, DATE_ADD(NOW(), INTERVAL ? SECOND))",
                [
                    $user['id_user'],
                    $token,
                    $refreshToken,
                    $_SERVER['REMOTE_ADDR'] ?? null,
                    $_SERVER['HTTP_USER_AGENT'] ?? null,
                    JWT_EXPIRATION
                ]
            );
            
            // Mettre à jour la dernière connexion
            $this->userModel->updateLastLogin($user['id_user']);
            
            // Logger l'activité
            $this->logActivity('LOGIN', 'Authentification', 'Connexion réussie');
            
            // Réponse
            Response::success([
                'token' => $token,
                'refresh_token' => $refreshToken,
                'expires_in' => JWT_EXPIRATION,
                'user' => [
                    'id' => $user['id_user'],
                    'matricule' => $user['matricule'],
                    'nom' => $user['nom'],
                    'prenom' => $user['prenom'],
                    'email' => $user['email'],
                    'telephone' => $user['telephone'],
                    'photo_profil' => $user['photo_profil'],
                    'role' => [
                        'id' => $user['id_role'],
                        'nom' => $user['nom_role']
                    ]
                ]
            ], 'Connexion réussie');
            
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }
    
    public function logout() {
        try {
            $token = JWT::getAuthorizationToken();
            
            if ($token) {
                // Désactiver la session
                $this->db->update(
                    "UPDATE sessions SET est_actif = FALSE WHERE token = ?",
                    [$token]
                );
                
                $this->logActivity('LOGOUT', 'Authentification', 'Déconnexion');
            }
            
            Response::success(null, 'Déconnexion réussie');
            
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }
    
    public function refresh() {
        $data = $this->getRequestData();
        
        if (empty($data['refresh_token'])) {
            Response::error('Refresh token requis', 400);
        }
        
        try {
            // Vérifier le refresh token
            $session = $this->db->fetchOne(
                "SELECT s.*, u.* FROM sessions s
                 JOIN users u ON s.id_user = u.id_user
                 WHERE s.refresh_token = ? AND s.est_actif = TRUE",
                [$data['refresh_token']]
            );
            
            if (!$session) {
                Response::unauthorized('Refresh token invalide');
            }
            
            // Générer un nouveau token
            $payload = [
                'id_user' => $session['id_user'],
                'matricule' => $session['matricule'],
                'email' => $session['email'],
                'nom' => $session['nom'],
                'prenom' => $session['prenom'],
                'id_role' => $session['id_role']
            ];
            
            $newToken = JWT::encode($payload);
            $newRefreshToken = JWT::generateRefreshToken();
            
            // Mettre à jour la session
            $this->db->update(
                "UPDATE sessions SET token = ?, refresh_token = ?, date_expiration = DATE_ADD(NOW(), INTERVAL ? SECOND) WHERE id_session = ?",
                [$newToken, $newRefreshToken, JWT_EXPIRATION, $session['id_session']]
            );
            
            Response::success([
                'token' => $newToken,
                'refresh_token' => $newRefreshToken,
                'expires_in' => JWT_EXPIRATION
            ], 'Token rafraîchi avec succès');
            
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }
    
    public function me() {
        try {
            AuthMiddleware::handle();
            $userId = $this->getUserId();
            
            $user = $this->userModel->getUserWithRole($userId);
            $permissions = $this->userModel->getUserPermissions($userId);
            
            if (!$user) {
                Response::notFound('Utilisateur non trouvé');
            }
            
            // Retirer le mot de passe
            unset($user['mot_de_passe']);
            
            $user['permissions'] = $permissions;
            
            Response::success($user);
            
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }
    
    public function changePassword() {
        AuthMiddleware::handle();
        $data = $this->getRequestData();
        $userId = $this->getUserId();
        
        // Validation
        $validator = new Validator($data);
        $validator->required(['ancien_mot_de_passe', 'nouveau_mot_de_passe', 'confirmation_mot_de_passe'])
                  ->password('nouveau_mot_de_passe');
        
        if ($validator->fails()) {
            Response::validationError($validator->errors());
        }
        
        if ($data['nouveau_mot_de_passe'] !== $data['confirmation_mot_de_passe']) {
            Response::error('Les mots de passe ne correspondent pas', 400);
        }
        
        try {
            $user = $this->userModel->find($userId);
            
            // Vérifier l'ancien mot de passe
            if (!password_verify($data['ancien_mot_de_passe'], $user['mot_de_passe'])) {
                Response::error('Ancien mot de passe incorrect', 400);
            }
            
            // Mettre à jour le mot de passe
            $this->userModel->updatePassword($userId, $data['nouveau_mot_de_passe']);
            
            $this->logActivity('CHANGE_PASSWORD', 'Authentification', 'Changement de mot de passe');
            
            Response::success(null, 'Mot de passe modifié avec succès');
            
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }
    
    public function forgotPassword() {
        $data = $this->getRequestData();
        
        $validator = new Validator($data);
        $validator->required('email')->email('email');
        
        if ($validator->fails()) {
            Response::validationError($validator->errors());
        }
        
        try {
            $user = $this->userModel->findByEmail($data['email']);
            
            if ($user) {
                $token = bin2hex(random_bytes(32));
                $this->userModel->saveResetToken($data['email'], $token);
                
                // TODO: Envoyer l'email avec le lien de réinitialisation
                // EmailSender::sendPasswordReset($user['email'], $token);
                
                $this->logActivity('FORGOT_PASSWORD', 'Authentification', 'Demande de réinitialisation de mot de passe');
            }
            
            // Réponse générique pour la sécurité
            Response::success(null, 'Si l\'email existe, un lien de réinitialisation a été envoyé');
            
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }
    
    public function resetPassword() {
        $data = $this->getRequestData();
        
        $validator = new Validator($data);
        $validator->required(['token', 'nouveau_mot_de_passe', 'confirmation_mot_de_passe'])
                  ->password('nouveau_mot_de_passe');
        
        if ($validator->fails()) {
            Response::validationError($validator->errors());
        }
        
        if ($data['nouveau_mot_de_passe'] !== $data['confirmation_mot_de_passe']) {
            Response::error('Les mots de passe ne correspondent pas', 400);
        }
        
        try {
            $user = $this->userModel->verifyResetToken($data['token']);
            
            if (!$user) {
                Response::error('Token invalide ou expiré', 400);
            }
            
            $this->userModel->updatePassword($user['id_user'], $data['nouveau_mot_de_passe']);
            $this->userModel->clearResetToken($user['id_user']);
            
            Response::success(null, 'Mot de passe réinitialisé avec succès');
            
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }
}