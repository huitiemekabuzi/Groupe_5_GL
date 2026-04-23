import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ismgl/app/themes/app_theme.dart';
import 'package:ismgl/controllers/etudiant_controller.dart';

class EtudiantFormPage extends StatefulWidget {
  const EtudiantFormPage({super.key});

  @override
  State<EtudiantFormPage> createState() => _EtudiantFormPageState();
}

class _EtudiantFormPageState extends State<EtudiantFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _ctrl = Get.isRegistered<EtudiantController>()
      ? Get.find<EtudiantController>()
      : Get.put(EtudiantController(), permanent: true);

  final _nom       = TextEditingController();
  final _prenom    = TextEditingController();
  final _email     = TextEditingController();
  final _tel       = TextEditingController();
  final _mdp       = TextEditingController();
  final _naissance = TextEditingController();
  final _lieu      = TextEditingController();
  final _adresse   = TextEditingController();
  final _ville     = TextEditingController();
  final _province  = TextEditingController();
  final _pere      = TextEditingController();
  final _mere      = TextEditingController();
  final _telUrg    = TextEditingController();
  final _sang      = TextEditingController();

  String _sexe  = 'M';
  final String _nat   = 'Congolaise';

  @override
  void dispose() {
    for (final c in [_nom, _prenom, _email, _tel, _mdp, _naissance, _lieu,
        _adresse, _ville, _province, _pere, _mere, _telUrg, _sang]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Nouveau Étudiant'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Section('Informations personnelles', children: [
              _field(_nom,       'Nom *',           validator: _required),
              _field(_prenom,    'Prénom *',         validator: _required),
              _field(_email,     'Email *',          keyboardType: TextInputType.emailAddress, validator: _email_val),
              _field(_tel,       'Téléphone',        keyboardType: TextInputType.phone),
              _field(_mdp,       'Mot de passe *',   obscure: true, validator: _required),
              _dateField(),
              _field(_lieu,      'Lieu de naissance'),
              _sexeField(),
              _field(_sang,      'Groupe sanguin',   hint: 'ex: O+'),
            ]),
            const SizedBox(height: 12),
            _Section('Adresse', children: [
              _field(_adresse,  'Adresse'),
              _field(_ville,    'Ville'),
              _field(_province, 'Province'),
            ]),
            const SizedBox(height: 12),
            _Section('Famille & Urgence', children: [
              _field(_pere,     'Nom du père'),
              _field(_mere,     'Nom de la mère'),
              _field(_telUrg,   'Téléphone d\'urgence', keyboardType: TextInputType.phone),
            ]),
            const SizedBox(height: 24),
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _ctrl.isSubmitting.value ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _ctrl.isSubmitting.value
                        ? const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2)
                        : const Text('Enregistrer l\'étudiant',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                )),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _Section(String title, {required List<Widget> children}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: AppTheme.primary)),
            const Divider(height: 16),
            ...children.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: c,
                )),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label,
      {bool obscure = false,
      TextInputType? keyboardType,
      String? Function(String?)? validator,
      String? hint}) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _dateField() {
    return TextFormField(
      controller: _naissance,
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Date de naissance *',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      validator: _required,
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime(2000),
          firstDate: DateTime(1950),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          _naissance.text = date.toIso8601String().split('T')[0];
        }
      },
    );
  }

  Widget _sexeField() {
    return DropdownButtonFormField<String>(
      initialValue: _sexe,
      decoration: InputDecoration(
        labelText: 'Sexe *',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: const [
        DropdownMenuItem(value: 'M', child: Text('Masculin')),
        DropdownMenuItem(value: 'F', child: Text('Féminin')),
      ],
      onChanged: (v) => setState(() => _sexe = v ?? 'M'),
    );
  }

  String? _required(String? v) =>
      (v == null || v.isEmpty) ? 'Ce champ est requis' : null;

  String? _email_val(String? v) {
    if (v == null || v.isEmpty) return 'Email requis';
    if (!GetUtils.isEmail(v)) return 'Email invalide';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final data = {
      'nom':               _nom.text.trim(),
      'prenom':            _prenom.text.trim(),
      'email':             _email.text.trim(),
      'telephone':         _tel.text.trim(),
      'mot_de_passe':      _mdp.text,
      'date_naissance':    _naissance.text,
      'lieu_naissance':    _lieu.text,
      'sexe':              _sexe,
      'nationalite':       _nat,
      'adresse':           _adresse.text,
      'ville':             _ville.text,
      'province':          _province.text,
      'nom_pere':          _pere.text,
      'nom_mere':          _mere.text,
      'telephone_urgence': _telUrg.text,
      'groupe_sanguin':    _sang.text,
    };
    final ok = await _ctrl.createEtudiant(data);
    if (ok) Get.back();
  }
}
