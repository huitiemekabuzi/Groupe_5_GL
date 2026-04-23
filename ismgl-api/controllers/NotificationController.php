<?php
require_once __DIR__ . '/../core/Controller.php';
require_once __DIR__ . '/../middleware/AuthMiddleware.php';
require_once __DIR__ . '/../models/NotificationModel.php';

class NotificationController extends Controller {
    private $notificationModel;

    public function __construct() {
        parent::__construct();
        $this->notificationModel = new NotificationModel();
    }

    public function index() {
        AuthMiddleware::handle();

        try {
            $userId        = $this->getUserId();
            $limit         = $_GET['limit'] ?? 50;
            $notifications = $this->notificationModel->getNotificationsByUser($userId, $limit);
            $unread        = $this->notificationModel->getUnreadCount($userId);
            $total         = $this->notificationModel->getTotalCount($userId);

            Response::success([
                'notifications'  => $notifications,
                'stats' => [
                    'total' => $total,
                    'unread' => $unread,
                    'read' => $total - $unread
                ]
            ]);
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }
    
    public function debug() {
        AuthMiddleware::handle();
        RoleMiddleware::hasRole(ROLE_ADMIN);

        try {
            // Retourner des infos de debug
            $userId = $this->getUserId();
            
            // Toutes les notifications en BD
            $allNotifications = $this->db->fetchAll("SELECT * FROM notifications LIMIT 50");
            
            // Pour l'utilisateur courant
            $userNotifications = $this->db->fetchAll(
                "SELECT * FROM notifications WHERE id_user = ? LIMIT 50",
                [$userId]
            );
            
            // Compte global
            $totalGlobal = $this->db->fetchColumn("SELECT COUNT(*) FROM notifications");
            $totalUser = $this->db->fetchColumn("SELECT COUNT(*) FROM notifications WHERE id_user = ?", [$userId]);

            Response::success([
                'debug' => [
                    'current_user_id' => $userId,
                    'total_notifications_db' => (int)$totalGlobal,
                    'user_notifications' => (int)$totalUser,
                    'all_notifications_sample' => $allNotifications,
                    'user_notifications_data' => $userNotifications
                ]
            ]);
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }

    public function unreadCount() {
        AuthMiddleware::handle();

        try {
            $userId = $this->getUserId();
            $count  = $this->notificationModel->getUnreadCount($userId);

            Response::success(['count' => (int)$count]);
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }
    
    public function count() {
        AuthMiddleware::handle();

        try {
            // Retourner le nombre total de notifications de l'utilisateur
            $userId = $this->getUserId();
            $total = $this->db->fetchColumn(
                "SELECT COUNT(*) FROM notifications WHERE id_user = ?",
                [$userId]
            );
            
            $unread = $this->db->fetchColumn(
                "SELECT COUNT(*) FROM notifications WHERE id_user = ? AND est_lu = FALSE",
                [$userId]
            );

            Response::success([
                'total' => (int)$total,
                'unread' => (int)$unread
            ]);
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }
    
    public function countAll() {
        AuthMiddleware::handle();

        try {
            // Compte TOUTES les notifications en base (pour debug)
            $total = $this->db->fetchColumn("SELECT COUNT(*) FROM notifications");
            
            $unread = $this->db->fetchColumn(
                "SELECT COUNT(*) FROM notifications WHERE est_lu = FALSE"
            );

            Response::success([
                'total_global' => (int)$total,
                'unread_global' => (int)$unread,
                'message' => 'Compteur global de toutes les notifications'
            ]);
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }

    public function marquerLu($id) {
        AuthMiddleware::handle();

        try {
            $userId = $this->getUserId();
            $this->notificationModel->marquerLu($id, $userId);

            Response::success(null, 'Notification marquée comme lue');
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }

    public function marquerToutLu() {
        AuthMiddleware::handle();

        try {
            $userId = $this->getUserId();
            $updatedRows = $this->notificationModel->marquerToutLu($userId);
            $unreadAfter = $this->notificationModel->getUnreadCount($userId);

            Response::success([
                'updated_rows' => (int)$updatedRows,
                'unread_remaining' => (int)$unreadAfter
            ], 'Toutes les notifications marquées comme lues');
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }

    public function supprimer($id) {
        AuthMiddleware::handle();

        try {
            $userId = $this->getUserId();
            $this->notificationModel->supprimerNotification($id, $userId);

            Response::deleted('Notification supprimée');
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }

    public function envoyerBroadcast() {
        AuthMiddleware::handle();
        RoleMiddleware::hasRole(ROLE_ADMIN);

        $data = $this->getRequestData();

        $validator = new Validator($data);
        $validator->required(['titre', 'message']);

        if ($validator->fails()) {
            Response::validationError($validator->errors());
        }

        try {
            // Récupérer tous les utilisateurs actifs
            $users = $this->db->fetchAll(
                "SELECT id_user FROM users WHERE est_actif = TRUE"
            );

            foreach ($users as $user) {
                $this->notificationModel->createNotification(
                    $user['id_user'],
                    $data['titre'],
                    $data['message'],
                    $data['type'] ?? 'Info',
                    $data['lien'] ?? null
                );
            }

            $this->logActivity('BROADCAST_NOTIFICATION', 'Notifications', "Envoi notification globale: {$data['titre']}");

            Response::success(
                ['destinataires' => count($users)],
                'Notification envoyée à tous les utilisateurs'
            );
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }
}