import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ismgl/app/app_messenger.dart';
import 'package:ismgl/app/themes/app_theme.dart';

class AppHelpers {
  static void _showSnackbar({
    required String title,
    required String message,
    required Color backgroundColor,
    Icon? icon,
    int seconds = 3,
  }) {
    void deliver() {
      final rootMessenger = rootScaffoldMessengerKey.currentState;
      final rootCtx = rootScaffoldMessengerKey.currentContext;
      if (rootMessenger != null && rootCtx != null) {
        // MaterialBanner = top of scaffold, never off-screen.
        rootMessenger.clearMaterialBanners();
        rootMessenger.showMaterialBanner(
          MaterialBanner(
            backgroundColor: backgroundColor,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            leading: icon,
            content: Text(
              '$title\n$message',
              style: const TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: rootMessenger.hideCurrentMaterialBanner,
                child: const Text(
                  'OK',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
        Future<void>.delayed(Duration(seconds: seconds)).then((_) {
          try {
            rootMessenger.hideCurrentMaterialBanner();
          } catch (_) {}
        });
        return;
      }

      try {
        final overlayCtx = Get.overlayContext ?? Get.context;
        if (overlayCtx != null) {
          final mq = MediaQuery.of(overlayCtx);
          Get.snackbar(
            title,
            message,
            snackPosition: SnackPosition.TOP,
            backgroundColor: backgroundColor,
            colorText: Colors.white,
            icon: icon,
            shouldIconPulse: false,
            margin: EdgeInsets.only(
              top: mq.padding.top + 8,
              left: 12,
              right: 12,
            ),
            borderRadius: 10,
            duration: Duration(seconds: seconds),
            snackStyle: SnackStyle.FLOATING,
            maxWidth: mq.size.width - 24,
          );
          return;
        }
      } catch (e) {
        debugPrint('⚠️ Get.snackbar: $e');
      }

      final ctx = Get.context;
      if (ctx == null) {
        debugPrint('⚠️ Snackbar ignorée: $title — $message');
        return;
      }
      final messenger = ScaffoldMessenger.maybeOf(ctx);
      if (messenger == null) return;
      final mq = MediaQuery.of(ctx);
      const barHeight = 88.0;
      final top = mq.padding.top + 8;
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              if (icon != null) ...[icon, const SizedBox(width: 8)],
              Expanded(
                child: Text(
                  '$title\n$message',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: backgroundColor,
          duration: Duration(seconds: seconds),
          margin: EdgeInsets.only(
            left: 12,
            right: 12,
            bottom: mq.size.height - top - barHeight,
          ),
        ),
      );
    }

    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) => deliver());
    } else {
      deliver();
    }
  }

  // Formater montant
  static String formatMontant(double montant, {String devise = 'FC'}) {
    final formatter = NumberFormat('#,##0.00', 'fr_FR');
    return '${formatter.format(montant)} $devise';
  }

  /// Alias de [formatMontant] pour compatibilité avec les nouvelles vues.
  static String formatCurrency(double montant, {String devise = 'FC'}) =>
      formatMontant(montant, devise: devise);

  // Formater date
  static String formatDate(String? date, {String format = 'dd/MM/yyyy'}) {
    if (date == null || date.isEmpty) return 'N/A';
    try {
      final d = DateTime.parse(date);
      return DateFormat(format, 'fr_FR').format(d);
    } catch (_) {
      return date;
    }
  }

  static String formatDateTime(String? date) =>
      formatDate(date, format: 'dd/MM/yyyy HH:mm');

  // Notifications Snackbar
  static void showSuccess(String message) {
    _showSnackbar(
      title: '✅ Succès',
      message: message,
      backgroundColor: AppTheme.success,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  static void showError(String message) {
    _showSnackbar(
      title: '❌ Erreur',
      message: message,
      backgroundColor: AppTheme.error,
      icon: const Icon(Icons.error_outline, color: Colors.white),
      seconds: 4,
    );
  }

  static void showWarning(String message) {
    _showSnackbar(
      title: '⚠️ Attention',
      message: message,
      backgroundColor: AppTheme.warning,
      icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
    );
  }

  static void showInfo(String message) {
    _showSnackbar(
      title: 'ℹ️ Information',
      message: message,
      backgroundColor: AppTheme.info,
      icon: const Icon(Icons.info_outline_rounded, color: Colors.white),
    );
  }

  // Dialog confirmation
  static Future<bool> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = 'Confirmer',
    String cancelText  = 'Annuler',
    Color? confirmColor,
  }) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor ?? AppTheme.primary,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Couleur statut inscription
  static Color getStatutInscriptionColor(String statut) {
    switch (statut) {
      case 'Validée':    return AppTheme.success;
      case 'En attente': return AppTheme.warning;
      case 'Rejetée':    return AppTheme.error;
      case 'Annulée':    return Colors.grey;
      default:           return AppTheme.info;
    }
  }

  // Couleur statut paiement
  static Color getStatutPaiementColor(String statut) {
    switch (statut) {
      case 'Validé':    return AppTheme.success;
      case 'En attente': return AppTheme.warning;
      case 'Annulé':    return AppTheme.error;
      case 'Remboursé': return AppTheme.info;
      default:          return Colors.grey;
    }
  }

  // Initiales
  static String getInitials(String fullName) {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }
}