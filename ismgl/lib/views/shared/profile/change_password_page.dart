import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ismgl/app/themes/app_theme.dart';
import 'package:ismgl/controllers/auth_controller.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey   = GlobalKey<FormState>();
  final AuthController _ctrl = Get.find<AuthController>();

  final _ancienCtrl    = TextEditingController();
  final _nouveauCtrl   = TextEditingController();
  final _confirmCtrl   = TextEditingController();

  @override
  void dispose() {
    _ancienCtrl.dispose();
    _nouveauCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Changer le mot de passe'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_reset,
                    size: 48, color: Colors.white),
              ),
              const SizedBox(height: 24),
              const Text(
                'Modifier votre mot de passe',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Votre nouveau mot de passe doit contenir au moins 8 caractères, '
                'une majuscule, un chiffre et un caractère spécial.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Obx(() => TextFormField(
                          controller: _ancienCtrl,
                          obscureText: _ctrl.obscurePassword.value,
                          decoration: InputDecoration(
                            labelText: 'Mot de passe actuel',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_ctrl.obscurePassword.value
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: _ctrl.togglePasswordVisibility,
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Requis' : null,
                        )),
                    const SizedBox(height: 16),
                    Obx(() => TextFormField(
                          controller: _nouveauCtrl,
                          obscureText: _ctrl.obscureNew.value,
                          decoration: InputDecoration(
                            labelText: 'Nouveau mot de passe',
                            prefixIcon: const Icon(Icons.lock_open_outlined),
                            suffixIcon: IconButton(
                              icon: Icon(_ctrl.obscureNew.value
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: _ctrl.toggleNewVisibility,
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Requis';
                            if (v.length < 8) return 'Minimum 8 caractères';
                            return null;
                          },
                        )),
                    const SizedBox(height: 16),
                    Obx(() => TextFormField(
                          controller: _confirmCtrl,
                          obscureText: _ctrl.obscureConfirm.value,
                          decoration: InputDecoration(
                            labelText: 'Confirmer le mot de passe',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_ctrl.obscureConfirm.value
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: _ctrl.toggleConfirmVisibility,
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Requis';
                            if (v != _nouveauCtrl.text) {
                              return 'Mot de passe differents';
                            }
                            return null;
                          },
                        )),
                    const SizedBox(height: 8),
                    Obx(() {
                      final err = _ctrl.errorMessage.value;
                      if (err.isEmpty) return const SizedBox();
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(err,
                            style: const TextStyle(color: AppTheme.error),
                            textAlign: TextAlign.center),
                      );
                    }),
                    const SizedBox(height: 24),
                    Obx(() => SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _ctrl.isLoading.value ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _ctrl.isLoading.value
                                ? const CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2)
                                : const Text('Modifier le mot de passe',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await _ctrl.changePassword(
      ancienMotDePasse:       _ancienCtrl.text,
      nouveauMotDePasse:      _nouveauCtrl.text,
      confirmationMotDePasse: _confirmCtrl.text,
    );
    if (ok) Get.back();
  }
}
