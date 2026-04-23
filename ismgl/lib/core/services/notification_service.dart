import 'package:get/get.dart';
import 'package:ismgl/core/services/api_service.dart';

class NotificationService extends GetxService {
  final ApiService _api = Get.find<ApiService>();

  /// Liste des notifications de l'utilisateur connecté.
  Future<Map<String, dynamic>> getNotifications({int limit = 20}) =>
      _api.get('/notifications', params: {'limit': limit});

  /// Nombre de notifications non lues.
  Future<Map<String, dynamic>> getCount() => _api.get('/notifications/count');

  /// Marquer une notification comme lue.
  Future<Map<String, dynamic>> markAsRead(int id) =>
      _api.patch('/notifications/$id/lire');

  /// Marquer toutes les notifications comme lues.
  Future<Map<String, dynamic>> markAllAsRead() =>
      _api.patch('/notifications/lire-tout');

  /// Supprimer une notification.
  Future<Map<String, dynamic>> deleteNotification(int id) =>
      _api.delete('/notifications/$id');

  /// Envoyer une notification globale (admin seulement).
  Future<Map<String, dynamic>> broadcast({
    required String titre,
    required String message,
    String type = 'Info',
    String? lien,
  }) =>
      _api.post('/notifications/broadcast', data: {
        'titre':   titre,
        'message': message,
        'type':    type,
        if (lien != null) 'lien': lien,
      });
}
