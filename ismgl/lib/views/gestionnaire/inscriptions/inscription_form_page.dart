import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ismgl/app/themes/app_theme.dart';
import 'package:ismgl/controllers/config_controller.dart';
import 'package:ismgl/controllers/inscription_controller.dart';
import 'package:ismgl/controllers/etudiant_controller.dart';
import 'package:ismgl/core/utils/helpers.dart';

class InscriptionFormPage extends StatefulWidget {
  const InscriptionFormPage({super.key});

  @override
  State<InscriptionFormPage> createState() => _InscriptionFormPageState();
}

class _InscriptionFormPageState extends State<InscriptionFormPage> {
  final _formKey       = GlobalKey<FormState>();
  final _insCtrl = Get.isRegistered<InscriptionController>()
      ? Get.find<InscriptionController>()
      : Get.put(InscriptionController(), permanent: true);
  final _configCtrl = Get.isRegistered<ConfigController>()
      ? Get.find<ConfigController>()
      : Get.put(ConfigController(), permanent: true);
  final _etudiantCtrl = Get.isRegistered<EtudiantController>()
      ? Get.find<EtudiantController>()
      : Get.put(EtudiantController(), permanent: true);

  int? _selectedEtudiant;
  int? _selectedFiliere;
  int? _selectedNiveau;
  int? _selectedAnnee;
  String _typeInscription = 'Nouvelle';

  final _searchCtrl = TextEditingController();

  int? _defaultAnneeId(List<dynamic> annees) {
    if (annees.isEmpty) return null;
    for (final a in annees) {
      if (a.estCourante == true) return a.idAnneeAcademique as int?;
    }
    return annees.first.idAnneeAcademique as int?;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onFiliereOrNiveauChanged() {
    if (_selectedFiliere != null &&
        _selectedNiveau   != null &&
        _selectedAnnee    != null) {
      _insCtrl.loadFrais(
        idFiliere:         _selectedFiliere!,
        idNiveau:          _selectedNiveau!,
        idAnneeAcademique: _selectedAnnee!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Nouvelle Inscription'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Sélection étudiant
            _SectionCard(
              title: 'Étudiant',
              icon: Icons.person_outline,
              child: Obx(() {
                final etudiants = _etudiantCtrl.etudiants;
                return DropdownButtonFormField<int>(
                  initialValue: _selectedEtudiant,
                  isExpanded: true,
                  decoration: _inputDecoration('Sélectionner un étudiant *'),
                  items: etudiants
                      .map((e) => DropdownMenuItem(
                            value: e.idEtudiant,
                            child: Text('${e.fullName} — ${e.numeroEtudiant}',
                                overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedEtudiant = v),
                  validator: (v) => v == null ? 'Sélectionnez un étudiant' : null,
                );
              }),
            ),
            const SizedBox(height: 12),

            // Sélection filière / niveau / année
            _SectionCard(
              title: 'Cursus',
              icon: Icons.school_outlined,
              child: Column(
                children: [
                  Obx(() {
                    final annees = _configCtrl.annees;
                    final effectiveAnnee = _selectedAnnee ?? _defaultAnneeId(annees);
                    if (_selectedAnnee == null && effectiveAnnee != null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted || _selectedAnnee != null) return;
                        setState(() => _selectedAnnee = effectiveAnnee);
                      });
                    }
                    return DropdownButtonFormField<int>(
                      initialValue: effectiveAnnee,
                      isExpanded: true,
                      decoration: _inputDecoration('Année académique *'),
                      items: annees
                          .map((a) => DropdownMenuItem(
                                value: a.idAnneeAcademique,
                                child: Text(a.codeAnnee +
                                    (a.estCourante ? ' (Courante)' : '')),
                              ))
                          .toList(),
                      onChanged: (v) {
                        setState(() => _selectedAnnee = v);
                        _onFiliereOrNiveauChanged();
                      },
                      validator: (v) => v == null ? 'Requis' : null,
                    );
                  }),
                  const SizedBox(height: 12),
                  Obx(() {
                    final filieres = _configCtrl.filieres;
                    return DropdownButtonFormField<int>(
                      initialValue: _selectedFiliere,
                      isExpanded: true,
                      decoration: _inputDecoration('Filière *'),
                      items: filieres
                          .map((f) => DropdownMenuItem(
                                value: f.idFiliere,
                                child: Text(f.nomFiliere,
                                    overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                      onChanged: (v) {
                        setState(() => _selectedFiliere = v);
                        _onFiliereOrNiveauChanged();
                      },
                      validator: (v) => v == null ? 'Requis' : null,
                    );
                  }),
                  const SizedBox(height: 12),
                  Obx(() {
                    final niveaux = _configCtrl.niveaux;
                    return DropdownButtonFormField<int>(
                      initialValue: _selectedNiveau,
                      isExpanded: true,
                      decoration: _inputDecoration('Niveau *'),
                      items: niveaux
                          .map((n) => DropdownMenuItem(
                                value: n.idNiveau,
                                child: Text(n.nomNiveau),
                              ))
                          .toList(),
                      onChanged: (v) {
                        setState(() => _selectedNiveau = v);
                        _onFiliereOrNiveauChanged();
                      },
                      validator: (v) => v == null ? 'Requis' : null,
                    );
                  }),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _typeInscription,
                    decoration: _inputDecoration('Type d\'inscription *'),
                    items: ['Nouvelle', 'Réinscription', 'Transfert']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) => setState(() => _typeInscription = v ?? 'Nouvelle'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Aperçu frais
            Obx(() {
              if (_insCtrl.isLoadingFrais.value) {
                return const Center(
                    child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ));
              }
              if (_insCtrl.fraisListe.isEmpty) return const SizedBox();
              return _SectionCard(
                title: 'Frais calculés',
                icon: Icons.calculate_outlined,
                child: Column(
                  children: [
                    ..._insCtrl.fraisListe.map((f) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                  child: Text(f['nom_frais'] as String? ?? '—',
                                      style: const TextStyle(fontSize: 13))),
                              Text(
                                AppHelpers.formatCurrency(double.tryParse(
                                        f['montant']?.toString() ?? '0') ??
                                    0),
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        )),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('TOTAL',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          AppHelpers.formatCurrency(_insCtrl.montantTotal.value),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary,
                              fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),

            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _insCtrl.isSubmitting.value ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _insCtrl.isSubmitting.value
                        ? const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2)
                        : const Text('Enregistrer l\'inscription',
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

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await _insCtrl.createInscription({
      'id_etudiant':        _selectedEtudiant,
      'id_filiere':         _selectedFiliere,
      'id_niveau':          _selectedNiveau,
      'id_annee_academique': _selectedAnnee,
      'type_inscription':   _typeInscription,
    });
    if (ok) Get.back();
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: AppTheme.primary, size: 18),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ]),
            const Divider(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
