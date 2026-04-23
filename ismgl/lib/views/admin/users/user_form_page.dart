import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ismgl/app/themes/app_theme.dart';
import 'package:ismgl/core/services/api_service.dart';
import 'package:ismgl/core/utils/helpers.dart';
import 'package:ismgl/core/utils/validators.dart';
import 'package:ismgl/data/models/user_model.dart';
import 'package:ismgl/views/shared/widgets/button.dart';
import 'package:ismgl/views/shared/widgets/form_field.dart';

class UserFormPage extends StatefulWidget {
  const UserFormPage({super.key});

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final ApiService _api = Get.find<ApiService>();
  final _formKey = GlobalKey<FormState>();

  UserModel? _editUser;
  bool _isLoading = false;
  bool _obscurePass = true;

  final _nomCtrl      = TextEditingController();
  final _prenomCtrl   = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _telCtrl      = TextEditingController();
  final _matriculeCtrl = TextEditingController();
  final _passCtrl     = TextEditingController();

  int? _selectedRole;
  bool _estActif = true;

  final _roles = [
    {'id': 1, 'nom': 'Administrateur'},
    {'id': 2, 'nom': 'Caissier'},
    {'id': 3, 'nom': 'Gestionnaire'},
    {'id': 4, 'nom': 'Etudiant'},
    {'id': 5, 'nom': 'Comptable'},
  ];

  @override
  void initState() {
    super.initState();
    _editUser = Get.arguments as UserModel?;
    if (_editUser != null) _fillForm();
  }

  void _fillForm() {
    _nomCtrl.text       = _editUser!.nom;
    _prenomCtrl.text    = _editUser!.prenom;
    _emailCtrl.text     = _editUser!.email;
    _telCtrl.text       = _editUser!.telephone ?? '';
    _matriculeCtrl.text = _editUser!.matricule;
    final roleId = _editUser!.idRole;
    final exists = _roles.any((r) => (r['id'] as int) == roleId);
    _selectedRole       = exists ? roleId : null;
    _estActif           = _editUser!.estActif;
  }

  @override
  void dispose() {
    _nomCtrl.dispose(); _prenomCtrl.dispose(); _emailCtrl.dispose();
    _telCtrl.dispose(); _passCtrl.dispose(); _matriculeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRole == null) {
      AppHelpers.showError('Veuillez sélectionner un rôle');
      return;
    }

    setState(() => _isLoading = true);

    final data = {
      'nom':        _nomCtrl.text.trim(),
      'prenom':     _prenomCtrl.text.trim(),
      'email':      _emailCtrl.text.trim(),
      'telephone':  _telCtrl.text.trim(),
      'id_role':    _selectedRole,
      'est_actif':  _estActif,
    };

    Map<String, dynamic> result;

    if (_editUser == null) {
      data['matricule']    = _matriculeCtrl.text.trim();
      data['mot_de_passe'] = _passCtrl.text;
      result = await _api.post('/users', data: data);
    } else {
      result = await _api.put('/users/${_editUser!.id}', data: data);
    }

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      AppHelpers.showSuccess(_editUser == null ? 'Utilisateur créé' : 'Utilisateur modifié');
      Get.back(result: true);
    } else {
      AppHelpers.showError(result['message'] ?? 'Erreur');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = _editUser != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Modifier utilisateur' : 'Nouvel utilisateur'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: Get.back),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              if (!isEdit) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: AppTheme.primary, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Le mot de passe doit contenir au moins 8 caractères, une majuscule, un chiffre et un caractère spécial.',
                          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              AppFormField(label: 'Prénom', hint: 'Prénom', prefixIcon: Icons.person_outline,
                  controller: _prenomCtrl, validator: (v) => AppValidators.required(v, 'Le prénom')),
              const SizedBox(height: 16),
              AppFormField(label: 'Nom', hint: 'Nom de famille', prefixIcon: Icons.person_outline,
                  controller: _nomCtrl, validator: (v) => AppValidators.required(v, 'Le nom')),
              const SizedBox(height: 16),
              AppFormField(label: 'Email', hint: 'email@ismgl.cd', prefixIcon: Icons.email_outlined,
                  controller: _emailCtrl, keyboardType: TextInputType.emailAddress,
                  validator: AppValidators.email),
              const SizedBox(height: 16),
              AppFormField(label: 'Téléphone', hint: '+243XXXXXXXXX', prefixIcon: Icons.phone_outlined,
                  controller: _telCtrl, keyboardType: TextInputType.phone,
                  validator: AppValidators.phone),
              const SizedBox(height: 16),

              if (!isEdit) ...[
                AppFormField(label: 'Matricule', hint: 'CAI001', prefixIcon: Icons.badge_outlined,
                    controller: _matriculeCtrl,
                    validator: (v) => AppValidators.required(v, 'Le matricule')),
                const SizedBox(height: 16),
                AppFormField(
                  label: 'Mot de passe',
                  hint: '••••••••',
                  prefixIcon: Icons.lock_outline,
                  controller: _passCtrl,
                  obscureText: _obscurePass,
                  validator: AppValidators.password,
                  suffixWidget: IconButton(
                    icon: Icon(_obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _obscurePass = !_obscurePass),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Rôle
              AppDropdown<int>(
                label: 'Rôle',
                value: _selectedRole,
                items: _roles.map((r) => DropdownMenuItem<int>(
                  value: r['id'] as int,
                  child: Text(r['nom'] as String),
                )).toList(),
                onChanged: (v) => setState(() => _selectedRole = v),
              ),
              const SizedBox(height: 16),

              // Actif
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SwitchListTile(
                  title: const Text('Compte actif'),
                  subtitle: Text(_estActif ? 'L\'utilisateur peut se connecter' : 'Connexion désactivée'),
                  value: _estActif,
                  onChanged: (v) => setState(() => _estActif = v),
                  activeThumbColor: AppTheme.success,
                ),
              ),
              const SizedBox(height: 28),

              AppButton(
                label:     isEdit ? 'Enregistrer les modifications' : 'Créer l\'utilisateur',
                onPressed: _submit,
                isLoading: _isLoading,
                icon:      isEdit ? Icons.save_rounded : Icons.person_add_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}