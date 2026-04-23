import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ismgl/app/routes/app_routes.dart';
import 'package:ismgl/app/themes/app_theme.dart';
import 'package:ismgl/views/shared/widgets/button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                const Spacer(),
                const Icon(Icons.school_rounded, size: 100, color: Colors.white),
                const SizedBox(height: 24),
                const Text(
                  'ISMGL',
                  style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold, letterSpacing: 4),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Institut Supérieur de Management et de Gestion de Lubumbashi',
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Gestion des Inscriptions et Paiements',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                AppButton(
                  label: 'Se connecter',
                  onPressed: () => Get.toNamed(AppRoutes.login),
                  icon: Icons.login_rounded,
                  outlined: true,
                  color: Colors.white,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}