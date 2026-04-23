import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ismgl/app/themes/app_theme.dart';
import 'package:ismgl/controllers/notification_controller.dart';
import 'package:ismgl/core/utils/helpers.dart';
import 'package:ismgl/views/shared/widgets/custom_app_bar.dart';
import 'package:ismgl/views/shared/widgets/loading_widget.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<NotificationController>()
        ? Get.find<NotificationController>()
        : Get.put(NotificationController());

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Notifications',
        showNotification: false,
        actions: [
          Obx(() => TextButton(
                onPressed: (controller.isMarkingAllRead.value ||
                        controller.unreadCount.value <= 0)
                    ? null
                    : controller.marquerToutLu,
                child: controller.isMarkingAllRead.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Tout lire',
                        style: TextStyle(color: AppTheme.primary),
                      ),
              )),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingWidget();

        if (controller.notifications.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_none_rounded, size: 80, color: AppTheme.textSecondary),
                SizedBox(height: 16),
                Text('Aucune notification', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.notifications.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final n = controller.notifications[i];
            return Dismissible(
              key: Key('${n.idNotification}'),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: AppTheme.error,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.delete_outline, color: Colors.white),
              ),
              onDismissed: (_) => controller.supprimer(n.idNotification),
              child: GestureDetector(
                onTap: () => controller.marquerLu(n.idNotification),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: n.estLu
                        ? Theme.of(context).cardColor
                        : AppTheme.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: n.estLu
                        ? null
                        : Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _getNotifColor(n.typeNotification).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getNotifIcon(n.typeNotification),
                          color: _getNotifColor(n.typeNotification),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    n.titre,
                                    style: TextStyle(
                                      fontWeight: n.estLu ? FontWeight.normal : FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                if (!n.estLu)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppTheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              n.message,
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              AppHelpers.formatDateTime(n.dateCreation),
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Color _getNotifColor(String type) {
    switch (type) {
      case 'Succès':      return AppTheme.success;
      case 'Erreur':      return AppTheme.error;
      case 'Avertissement': return AppTheme.warning;
      default:            return AppTheme.info;
    }
  }

  IconData _getNotifIcon(String type) {
    switch (type) {
      case 'Succès':      return Icons.check_circle_outline;
      case 'Erreur':      return Icons.error_outline;
      case 'Avertissement': return Icons.warning_amber_outlined;
      default:            return Icons.info_outline;
    }
  }
}