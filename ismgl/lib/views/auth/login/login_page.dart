import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ismgl/app/routes/app_routes.dart';
import 'package:ismgl/app/themes/app_theme.dart';
import 'package:ismgl/controllers/auth_controller.dart';
import 'package:ismgl/core/utils/validators.dart';
import 'package:ismgl/views/shared/widgets/form_field.dart';
import 'package:ismgl/views/shared/widgets/button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthController());
    final formKey    = GlobalKey<FormState>();
    final emailCtrl  = TextEditingController();
    final passCtrl   = TextEditingController();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Logo & Titre
              _buildHeader(),
              const SizedBox(height: 40),
              // Formulaire
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(28),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          const Text(
                            'Connexion',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Connectez-vous à votre compte ISMGL',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Email
                          Obx(() => AppFormField(
                            label:       'Email',
                            hint:        'votre@email.cd',
                            prefixIcon:  Icons.email_outlined,
                            controller:  emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            errorText:   controller.emailError.value.isEmpty
                                ? null
                                : controller.emailError.value,
                            onChanged:   (v) {
                              controller.emailValue.value = v;
                              controller.emailError.value = '';
                            },
                            validator:   AppValidators.email,
                          )),
                          const SizedBox(height: 20),

                          // Mot de passe
                          Obx(() => AppFormField(
                            label:       'Mot de passe',
                            hint:        '••••••••',
                            prefixIcon:  Icons.lock_outline,
                            controller:  passCtrl,
                            obscureText: controller.obscurePassword.value,
                            errorText:   controller.passwordError.value.isEmpty
                                ? null
                                : controller.passwordError.value,
                            suffixWidget: IconButton(
                              icon: Icon(
                                controller.obscurePassword.value
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppTheme.textSecondary,
                              ),
                              onPressed: controller.togglePasswordVisibility,
                            ),
                            onChanged: (v) {
                              controller.passwordValue.value = v;
                              controller.passwordError.value = '';
                            },
                          )),
                          const SizedBox(height: 12),

                          // Mot de passe oublié
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => Get.toNamed(AppRoutes.forgotPassword),
                              child: const Text(
                                'Mot de passe oublié ?',
                                style: TextStyle(color: AppTheme.primary),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Erreur globale
                          Obx(() => controller.errorMessage.value.isNotEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: AppTheme.error.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline, color: AppTheme.error, size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          controller.errorMessage.value,
                                          style: const TextStyle(
                                            color: AppTheme.error,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink()),

                          // Bouton connexion
                          Obx(() => AppButton(
                            label:    'Se connecter',
                            onPressed: () {
                              emailCtrl.text = controller.emailValue.value;
                              passCtrl.text  = controller.passwordValue.value;
                              controller.login();
                            },
                            isLoading: controller.isLoading.value,
                            icon:      Icons.login_rounded,
                          )),

                          const SizedBox(height: 32),

                          // Version
                          Center(
                            child: Text(
                              'ISMGL v1.0.0',
                              style: TextStyle(
                                color: AppTheme.textSecondary.withValues(alpha: 0.6),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.school_rounded,
            size: 44,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'ISMGL',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const Text(
          'Gestion Universitaire',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}