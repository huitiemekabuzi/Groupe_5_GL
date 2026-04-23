import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ismgl/app/routes/app_routes.dart';
import 'package:ismgl/core/services/auth_service.dart';
import 'package:ismgl/core/services/storage_service.dart';
import 'package:ismgl/core/utils/helpers.dart';

class AuthController extends GetxController {
  final AuthService    _authService = Get.find<AuthService>();
  final StorageService _storage     = Get.find<StorageService>();

  // ── État de connexion ──────────────────────────────────────────────────────
  final isLoading        = false.obs;
  final obscurePassword  = true.obs;
  final obscureNew       = true.obs;
  final obscureConfirm   = true.obs;
  final errorMessage     = ''.obs;
  final emailError       = ''.obs;
  final passwordError    = ''.obs;
  final successMessage   = ''.obs;

  // Valeurs
  final emailValue    = ''.obs;
  final passwordValue = ''.obs;

  void togglePasswordVisibility()  => obscurePassword.toggle();
  void toggleNewVisibility()        => obscureNew.toggle();
  void toggleConfirmVisibility()    => obscureConfirm.toggle();

  void clearErrors() {
    errorMessage.value  = '';
    emailError.value    = '';
    passwordError.value = '';
    successMessage.value = '';
  }

  // ── Connexion ──────────────────────────────────────────────────────────────
  Future<void> login() async {
    if (isLoading.value) return;
    clearErrors();

    final email    = emailValue.value.trim();
    final password = passwordValue.value;

    if (email.isEmpty) {
      emailError.value = 'L\'email est requis';
      return;
    }
    if (!GetUtils.isEmail(email)) {
      emailError.value = 'Email invalide';
      return;
    }
    if (password.isEmpty) {
      passwordError.value = 'Le mot de passe est requis';
      return;
    }

    isLoading.value = true;
    try {
      final result = await _authService.login(email, password);

      if (result['success'] == true) {
        AppHelpers.showSuccess('Bienvenue ! Connexion réussie.');
        _authService.redirectToDashboard();
      } else {
        errorMessage.value = result['message'] ?? 'Erreur de connexion';
        AppHelpers.showError(errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'Erreur réseau. Vérifiez votre connexion.';
      AppHelpers.showError(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Déconnexion ────────────────────────────────────────────────────────────
  Future<void> logout() async {
    if (isLoading.value) return;
    isLoading.value = true;
    Get.dialog(
      PopScope(
        canPop: false,
        child: Center(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Déconnexion…',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
    try {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      await _authService.logout();
    } finally {
      try {
        if (Get.isDialogOpen == true) Get.back<void>();
      } catch (_) {}
      isLoading.value = false;
      Get.offAllNamed(AppRoutes.login);
    }
  }

  // ── Changer mot de passe ───────────────────────────────────────────────────
  Future<bool> changePassword({
    required String ancienMotDePasse,
    required String nouveauMotDePasse,
    required String confirmationMotDePasse,
  }) async {
    clearErrors();
    if (nouveauMotDePasse != confirmationMotDePasse) {
      errorMessage.value = 'Les mots de passe ne correspondent pas';
      return false;
    }
    isLoading.value = true;
    try {
      final result = await _authService.changePassword(
        ancienMotDePasse:      ancienMotDePasse,
        nouveauMotDePasse:     nouveauMotDePasse,
        confirmationMotDePasse: confirmationMotDePasse,
      );
      if (result['success'] == true) {
        AppHelpers.showSuccess('Mot de passe modifié avec succès');
        return true;
      } else {
        errorMessage.value = result['message'] ?? 'Erreur modification';
        AppHelpers.showError(errorMessage.value);
        return false;
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ── Mot de passe oublié ────────────────────────────────────────────────────
  Future<bool> forgotPassword(String email) async {
    clearErrors();
    if (!GetUtils.isEmail(email.trim())) {
      emailError.value = 'Email invalide';
      return false;
    }
    isLoading.value = true;
    try {
      final result = await _authService.forgotPassword(email.trim());
      if (result['success'] == true) {
        successMessage.value =
            'Si l\'email existe, un lien de réinitialisation a été envoyé';
        return true;
      } else {
        errorMessage.value = result['message'] ?? 'Erreur';
        return false;
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ── Réinitialiser mot de passe ─────────────────────────────────────────────
  Future<bool> resetPassword({
    required String token,
    required String nouveauMotDePasse,
    required String confirmationMotDePasse,
  }) async {
    clearErrors();
    if (nouveauMotDePasse != confirmationMotDePasse) {
      errorMessage.value = 'Les mots de passe ne correspondent pas';
      return false;
    }
    isLoading.value = true;
    try {
      final result = await _authService.resetPassword(
        token:                   token,
        nouveauMotDePasse:       nouveauMotDePasse,
        confirmationMotDePasse:  confirmationMotDePasse,
      );
      if (result['success'] == true) {
        AppHelpers.showSuccess('Mot de passe réinitialisé');
        Get.offAllNamed(AppRoutes.login);
        return true;
      } else {
        errorMessage.value = result['message'] ?? 'Token invalide ou expiré';
        return false;
      }
    } finally {
      isLoading.value = false;
    }
  }
}