import 'package:get/get.dart';
import 'package:ismgl/core/services/notification_service.dart';
import 'package:ismgl/core/utils/helpers.dart';
import 'package:ismgl/data/models/notification_model.dart';

class NotificationController extends GetxController {
  final NotificationService _service = Get.find<NotificationService>();

  final notifications  = <NotificationModel>[].obs;
  final unreadCount    = 0.obs;
  final isLoading      = false.obs;
  final isMarkingAllRead = false.obs;
  DateTime? _lastMarkAllReadAt;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
    loadUnreadCount();
  }

  static int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  List<dynamic> _extractNotifications(dynamic resultData, Map<String, dynamic> fullResult) {
    List<dynamic> scan(dynamic node) {
      if (node is List) return node;
      if (node is! Map) return <dynamic>[];

      final current = Map<String, dynamic>.from(node);
      final direct = <dynamic>[
        current['notifications'],
        current['items'],
        current['results'],
        current['rows'],
        current['data'],
      ];

      for (final candidate in direct) {
        if (candidate is List) return candidate;
      }
      for (final candidate in direct) {
        if (candidate is Map) {
          final nested = scan(candidate);
          if (nested.isNotEmpty) return nested;
        }
      }
      return <dynamic>[];
    }

    final fromData = scan(resultData);
    if (fromData.isNotEmpty) return fromData;
    return scan(fullResult);
  }

  int _extractUnreadCount(Map<String, dynamic> source) {
    return _asInt(
      source['total_non_lues'] ??
          source['non_lues'] ??
          source['count_non_lues'] ??
          source['count'] ??
          source['unread_count'],
    );
  }

  Future<void> loadNotifications() async {
    isLoading.value = true;
    try {
      final result = await _service.getNotifications();
      if (result['success'] == true) {
        final raw = result['data'];
        final list = _extractNotifications(raw, result);
        var unread = 0;
        if (raw is Map<String, dynamic>) {
          unread = _extractUnreadCount(raw);
        }
        if (unread == 0) {
          unread = _extractUnreadCount(result);
        }

        notifications.value = list
            .whereType<Map>()
            .map((n) => NotificationModel.fromJson(
                  Map<String, dynamic>.from(n),
                ))
            .toList();

        if (unread == 0 && notifications.isNotEmpty) {
          unread = notifications
              .where((n) => !n.estLu)
              .length;
        }
        unreadCount.value = unread;
      }
    } catch (e) {
      AppHelpers.showError('Erreur chargement notifications');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUnreadCount() async {
    try {
      final result = await _service.getCount();
      if (result['success'] == true) {
        final d = result['data'];
        if (d is Map<String, dynamic>) {
          unreadCount.value = _extractUnreadCount(d);
        } else if (d is int) {
          unreadCount.value = d;
        } else {
          unreadCount.value = _extractUnreadCount(result);
        }
      }
    } catch (_) {}
  }

  Future<void> marquerLu(int id) async {
    await _service.markAsRead(id);
    await loadNotifications();
  }

  Future<void> marquerToutLu() async {
    if (isMarkingAllRead.value) return;
    if (unreadCount.value <= 0) return;

    final now = DateTime.now();
    if (_lastMarkAllReadAt != null &&
        now.difference(_lastMarkAllReadAt!).inMilliseconds < 1200) {
      return;
    }

    isMarkingAllRead.value = true;
    _lastMarkAllReadAt = now;
    try {
      await _service.markAllAsRead();
      unreadCount.value = 0;
      await loadNotifications();
    } catch (_) {
      AppHelpers.showError('Impossible de marquer toutes les notifications');
    } finally {
      isMarkingAllRead.value = false;
    }
  }

  Future<void> supprimer(int id) async {
    await _service.deleteNotification(id);
    notifications.removeWhere((n) => n.idNotification == id);
  }

  /// Envoyer une notification à tous les utilisateurs (admin).
  Future<bool> broadcast({
    required String titre,
    required String message,
    String type = 'Info',
    String? lien,
  }) async {
    isLoading.value = true;
    try {
      final result = await _service.broadcast(
        titre:   titre,
        message: message,
        type:    type,
        lien:    lien,
      );
      if (result['success'] == true) {
        final count = result['data']?['destinataires'] as int? ?? 0;
        AppHelpers.showSuccess('Notification envoyée à $count destinataires');
        return true;
      } else {
        AppHelpers.showError(result['message'] ?? 'Erreur envoi');
        return false;
      }
    } finally {
      isLoading.value = false;
    }
  }
}