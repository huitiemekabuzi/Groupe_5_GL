import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ismgl/app/themes/app_theme.dart';
import 'package:ismgl/core/services/api_service.dart';
import 'package:ismgl/core/utils/helpers.dart';
import 'package:ismgl/core/utils/validators.dart';
import 'package:ismgl/views/shared/widgets/button.dart';
import 'package:ismgl/views/shared/widgets/form_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _api    = Get.find<ApiService>();
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;
  bool _sent = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await _api.post('/auth/forgot-password', data: {
      'email': _emailCtrl.text.trim(),
    });

    setState(() {
      _isLoading = false;
      _sent = true;
    });

    AppHelpers.showInfo(result['message'] ?? 'Email envoyé si le compte existe');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mot de passe oublié')),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: _sent
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.mark_email_read_rounded, size: 80, color: AppTheme.success),
                    const SizedBox(height: 20),
                    const Text('Email envoyé !', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    const Text(
                      'Si votre email est enregistré, vous recevrez un lien de réinitialisation.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 32),
                    AppButton(label: 'Retour à la connexion', onPressed: Get.back),
                  ],
                ),
              )
            : Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Réinitialisation',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Entrez votre email pour recevoir un lien de réinitialisation.',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 32),
                    AppFormField(
                      label:        'Email',
                      hint:         'votre@email.cd',
                      prefixIcon:   Icons.email_outlined,
                      controller:   _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      validator:    AppValidators.email,
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label:     'Envoyer',
                      onPressed: _submit,
                      isLoading: _isLoading,
                      icon:      Icons.send_rounded,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}