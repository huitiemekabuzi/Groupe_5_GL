<?php
require_once __DIR__ . '/../core/JWT.php';
require_once __DIR__ . '/../core/Response.php';

class AuthMiddleware {
    
    public static function handle() {
        try {
            $token = JWT::getAuthorizationToken();
            
            if (!$token) {
                Response::unauthorized('Token manquant');
            }
            
            // Décoder et valider le JWT (signature + expiration)
            $payload = JWT::decode($token);
            
            // Vérifier uniquement que l'utilisateur existe et est actif
            $db = new Database();
            $user = $db->fetchOne(
                "SELECT id_user, est_actif, compte_bloque FROM users WHERE id_user = ?",
                [$payload['id_user']]
            );
            
            if (!$user) {
                Response::unauthorized('Utilisateur introuvable');
            }
            
            if (!$user['est_actif']) {
                Response::unauthorized('Compte utilisateur inactif');
            }
            
            if ($user['compte_bloque']) {
                Response::unauthorized('Compte utilisateur bloqué');
            }
            
            return $payload;
            
        } catch (Exception $e) {
            Response::unauthorized($e->getMessage());
        }
    }
    
    public static function optional() {
        try {
            $token = JWT::getAuthorizationToken();
            if ($token) {
                return JWT::decode($token);
            }
            return null;
        } catch (Exception $e) {
            return null;
        }
    }
}