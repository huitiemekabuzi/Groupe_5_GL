import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ismgl/app/routes/app_routes.dart';
import 'package:ismgl/app/themes/app_theme.dart';
import 'package:ismgl/controllers/auth_controller.dart';
import 'package:ismgl/controllers/theme_controller.dart';
import 'package:ismgl/core/services/storage_service.dart';
import 'package:ismgl/core/utils/helpers.dart';
import 'package:ismgl/views/shared/widgets/custom_app_bar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final storage       = Get.find<StorageService>();
    final themeCtrl     = Get.find<ThemeController>();
    final authCtrl      = Get.find<AuthController>();

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Mon Profil',
        showNotification: false,
        showProfile: false,
        showBack: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  AppHelpers.getInitials(storage.userFullName),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              storage.userFullName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              storage.getUserEmail() ?? '',
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                storage.getUserRole() ?? '',
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Infos
            _buildInfoCard([
              _InfoTile(Icons.badge_outlined, 'Matricule', storage.getMatricule() ?? 'N/A'),
              _InfoTile(Icons.phone_outlined, 'Téléphone', storage.getUserTelephone() ?? 'N/A'),
            ]),
            const SizedBox(height: 12),

            // Options
            _buildOptionCard([
              _OptionTile(
                Icons.lock_outline,
                'Changer le mot de passe',
                () => Get.toNamed(AppRoutes.changePassword),
              ),
              Obx(() => SwitchListTile(
                title: Row(
                  children: [
                    Icon(
                      themeCtrl.isDark ? Icons.dark_mode : Icons.light_mode,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 12),
                    const Text('Mode sombre'),
                  ],
                ),
                value: themeCtrl.isDark,
                onChanged: (_) => themeCtrl.toggleTheme(),
                activeThumbColor: AppTheme.primary,
              )),
              _OptionTile(
                Icons.logout_rounded,
                'Se déconnecter',
                () async {
                  final confirm = await AppHelpers.showConfirmDialog(
                    title:       'Déconnexion',
                    message:     'Voulez-vous vous déconnecter ?',
                    confirmText: 'Déconnecter',
                    confirmColor: AppTheme.error,
                  );
                  if (confirm) authCtrl.logout();
                },
                color: AppTheme.error,
              ),
            ]),
            const SizedBox(height: 24),
            const Text(
              'ISMGL v1.0.0\n© 2024 Tous droits réservés',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> tiles) {
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: tiles),
    );
  }

  Widget _buildOptionCard(List<Widget> tiles) {
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: tiles),
    );
  }

  Widget _InfoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primary),
      title: Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
      trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
    );
  }

  Widget _OptionTile(IconData icon, String label, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppTheme.primary),
      title: Text(label, style: TextStyle(color: color ?? AppTheme.textPrimary)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      onTap: onTap,
    );
  }
}