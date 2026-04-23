<?php
require_once __DIR__ . '/../core/Model.php';

class NotificationModel extends Model {
    protected $table = 'notifications';
    protected $primaryKey = 'id_notification';
    
    public function createNotification($idUser, $titre, $message, $type = 'Info', $lien = null) {
        return $this->create([
            'id_user' => $idUser,
            'titre' => $titre,
            'message' => $message,
            'type_notification' => $type,
            'lien' => $lien,
            'est_lu' => false
        ]);
    }
    
    public function getNotificationsByUser($userId, $limit = 50) {
        return $this->db->fetchAll(
            "SELECT * FROM notifications 
             WHERE id_user = ? 
             ORDER BY date_creation DESC 
             LIMIT ?",
            [$userId, $limit]
        );
    }
    
    public function getNotificationsWithUser($userId, $limit = 50) {
        return $this->db->fetchAll(
            "SELECT n.*, u.nom, u.prenom, u.email 
             FROM notifications n
             LEFT JOIN users u ON n.id_user = u.id_user
             WHERE n.id_user = ? 
             ORDER BY n.date_creation DESC 
             LIMIT ?",
            [$userId, $limit]
        );
    }
    
    public function getUnreadCount($userId) {
        $result = $this->db->fetchColumn(
            "SELECT COUNT(*) as count FROM notifications WHERE id_user = ? AND est_lu = FALSE",
            [$userId]
        );
        return $result ? (int)$result : 0;
    }
    
    public function getTotalCount($userId) {
        $result = $this->db->fetchColumn(
            "SELECT COUNT(*) as count FROM notifications WHERE id_user = ?",
            [$userId]
        );
        return $result ? (int)$result : 0;
    }
    
    public function getCountAll() {
        $result = $this->db->fetchColumn(
            "SELECT COUNT(*) as count FROM notifications"
        );
        return $result ? (int)$result : 0;
    }
    
    public function getUnreadCountAll() {
        $result = $this->db->fetchColumn(
            "SELECT COUNT(*) as count FROM notifications WHERE est_lu = FALSE"
        );
        return $result ? (int)$result : 0;
    }
    
    public function marquerLu($id, $userId) {
        return $this->db->update(
            "UPDATE notifications SET est_lu = TRUE, date_lecture = NOW() 
             WHERE id_notification = ? AND id_user = ?",
            [$id, $userId]
        );
    }
    
    public function marquerToutLu($userId) {
        return $this->db->update(
            "UPDATE notifications SET est_lu = TRUE, date_lecture = NOW() WHERE id_user = ? AND est_lu = FALSE",
            [$userId]
        );
    }
    
    public function supprimerNotification($id, $userId) {
        return $this->db->delete(
            "DELETE FROM notifications WHERE id_notification = ? AND id_user = ?",
            [$id, $userId]
        );
    }
    
    public function supprimerTout($userId) {
        return $this->db->delete(
            "DELETE FROM notifications WHERE id_user = ?",
            [$userId]
        );
    }
    
    public function obtenirNotification($id) {
        return $this->db->fetchOne(
            "SELECT * FROM notifications WHERE id_notification = ?",
            [$id]
        );
    }
}