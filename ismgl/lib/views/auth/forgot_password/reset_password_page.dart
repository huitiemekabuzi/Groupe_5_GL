import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ismgl/app/themes/app_theme.dart';
import 'package:ismgl/controllers/auth_controller.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthController _ctrl = Get.find<AuthController>();

  final _nouveauCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  // Le token est passé via les arguments GetX ou les query params
  late final String _token;

  @override
  void initState() {
    super.initState();
    _token = Get.parameters['token'] ?? Get.arguments as String? ?? '';
  }

  @override
  void dispose() {
    _nouveauCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Réinitialiser le mot de passe'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_reset, size: 48, color: Colors.white),
              ),
              const SizedBox(height: 24),
              const Text(
                'Nouveau mot de passe',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choisissez un nouveau mot de passe sécurisé.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              if (_token.isEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Token invalide ou manquant.',
                      style: TextStyle(color: AppTheme.error),
                      textAlign: TextAlign.center),
                ),
              ],
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  children: [
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
                              return 'Mots de passe différents';
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
                        margin: const EdgeInsets.only(top: 8),
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
                            onPressed: (_ctrl.isLoading.value || _token.isEmpty)
                                ? null
                                : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _ctrl.isLoading.value
                                ? const CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2)
                                : const Text('Réinitialiser',
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
    await _ctrl.resetPassword(
      token:                   _token,
      nouveauMotDePasse:       _nouveauCtrl.text,
      confirmationMotDePasse:  _confirmCtrl.text,
    );
  }
}
