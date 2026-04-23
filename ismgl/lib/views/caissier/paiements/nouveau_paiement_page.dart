import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ismgl/app/themes/app_theme.dart';
import 'package:ismgl/core/services/api_service.dart';
import 'package:ismgl/core/utils/helpers.dart';
import 'package:ismgl/core/utils/validators.dart';
import 'package:ismgl/views/shared/widgets/button.dart';
import 'package:ismgl/views/shared/widgets/form_field.dart';

class NouveauPaiementPage extends StatefulWidget {
  const NouveauPaiementPage({super.key});

  @override
  State<NouveauPaiementPage> createState() => _NouveauPaiementPageState();
}

class _NouveauPaiementPageState extends State<NouveauPaiementPage> {
  final ApiService _api = Get.find<ApiService>();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading        = false;
  bool _isSearching      = false;
  bool _isLoadingFrais   = false;

  final _searchCtrl    = TextEditingController();
  final _montantCtrl   = TextEditingController();
  final _referenceCtrl = TextEditingController();

  Map<String, dynamic>? _etudiant;
  Map<String, dynamic>? _inscription;
  List<dynamic> _typesFrais    = [];
  List<dynamic> _modesPaiement = [];
  List<dynamic> _fraisDisponibles = [];

  int? _selectedTypeFrais;
  int? _selectedMode;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _montantCtrl.dispose();
    _referenceCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadConfig() async {
    final results = await Future.wait([
      _api.get('/config/types-frais'),
      _api.get('/config/modes-paiement'),
    ]);
    setState(() {
      _typesFrais    = (results[0]['data'] as List?) ?? [];
      _modesPaiement = (results[1]['data'] as List?) ?? [];
    });
  }

  Future<void> _searchEtudiant() async {
    final query = _searchCtrl.text.trim();
    if (query.isEmpty) return;

    setState(() => _isSearching = true);

    final result = await _api.get('/etudiants', params: {'search': query, 'page_size': 5});
    setState(() => _isSearching = false);

    if (result['success'] == true) {
      final items = (result['data']['items'] as List?) ?? [];
      if (items.isEmpty) {
        AppHelpers.showWarning('Aucun étudiant trouvé');
      } else if (items.length == 1) {
        await _selectEtudiant(items[0]);
      } else {
        _showEtudiantSelection(items);
      }
    }
  }

  void _showEtudiantSelection(List items) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Sélectionner un étudiant', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ...items.map((e) => ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                child: Text(AppHelpers.getInitials('${e['prenom']} ${e['nom']}'),
                    style: const TextStyle(color: AppTheme.primary, fontSize: 12)),
              ),
              title: Text('${e['prenom']} ${e['nom']}'),
              subtitle: Text(e['numero_etudiant'] ?? ''),
              onTap: () { Get.back(); _selectEtudiant(e); },
            )),
          ],
        ),
      ),
    );
  }

  Future<void> _selectEtudiant(Map<String, dynamic> etudiant) async {
    setState(() { _etudiant = etudiant; _inscription = null; _fraisDisponibles = []; });

    // Charger inscription courante
    setState(() => _isLoadingFrais = true);

    try {
      final anneeResult = await _api.get('/config/annees/courante');
      if (!mounted) return;

      if (anneeResult['success'] != true) {
        AppHelpers.showError(anneeResult['message']?.toString() ?? 'Impossible de charger l\'année académique');
        setState(() => _isLoadingFrais = false);
        return;
      }

      final idAnnee = anneeResult['data']['id_annee_academique'];

      // Essai 1 : recherche par numéro étudiant
      final insResult = await _api.get('/inscriptions', params: {
        'search': etudiant['numero_etudiant'],
        'annee_academique': idAnnee,
      });
      if (!mounted) return;

      if (insResult['success'] == true) {
        final items = (insResult['data']?['items'] as List?) ?? [];
        if (items.isNotEmpty) {
          setState(() => _inscription = items.first);
          setState(() => _isLoadingFrais = false);
          return;
        }
      }

      // Essai 2 : recherche par id_etudiant
      final insResult2 = await _api.get('/inscriptions', params: {
        'id_etudiant': etudiant['id_etudiant'],
        'annee_academique': idAnnee,
      });
      if (!mounted) return;

      if (insResult2['success'] == true) {
        final items2 = (insResult2['data']?['items'] as List?) ?? [];
        if (items2.isNotEmpty) {
          setState(() => _inscription = items2.first);
          setState(() => _isLoadingFrais = false);
          return;
        }
      }

      // Aucune inscription trouvée — montrer l'erreur serveur si 500
      final serverMsg = insResult['message']?.toString() ?? '';
      if (insResult['success'] != true && serverMsg.isNotEmpty) {
        AppHelpers.showWarning('Erreur serveur inscriptions: $serverMsg');
      } else {
        AppHelpers.showWarning('Aucune inscription active pour cet étudiant dans l\'année en cours');
      }
    } catch (e) {
      if (mounted) AppHelpers.showError('Erreur: $e');
    } finally {
      if (mounted) setState(() => _isLoadingFrais = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_etudiant == null) { AppHelpers.showError('Sélectionnez un étudiant'); return; }
    if (_inscription == null) { AppHelpers.showError('Aucune inscription active trouvée'); return; }
    if (_selectedTypeFrais == null) { AppHelpers.showError('Sélectionnez le type de frais'); return; }
    if (_selectedMode == null) { AppHelpers.showError('Sélectionnez le mode de paiement'); return; }

    setState(() => _isLoading = true);

    final result = await _api.post('/paiements', data: {
      'id_inscription':     _inscription!['id_inscription'],
      'id_etudiant':        _etudiant!['id_etudiant'],
      'id_type_frais':      _selectedTypeFrais,
      'id_mode_paiement':   _selectedMode,
      'montant':            double.tryParse(_montantCtrl.text) ?? 0,
      'reference_transaction': _referenceCtrl.text.trim().isEmpty ? null : _referenceCtrl.text.trim(),
    });

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      AppHelpers.showSuccess('Paiement enregistré avec succès !');
      Get.back(result: true);
    } else {
      AppHelpers.showError(result['message'] ?? 'Erreur lors du paiement');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau Paiement'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Get.back();
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recherche étudiant
              const Text('Étudiant', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _searchCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Nom, prénom ou N° étudiant...',
                        prefixIcon: Icon(Icons.person_search_outlined),
                      ),
                      onFieldSubmitted: (_) => _searchEtudiant(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _isSearching ? null : _searchEtudiant,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(14)),
                    child: _isSearching
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.search),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Étudiant trouvé
              if (_etudiant != null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.success.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                            child: Text(AppHelpers.getInitials('${_etudiant!['prenom']} ${_etudiant!['nom']}'),
                                style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${_etudiant!['prenom']} ${_etudiant!['nom']}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                Text(_etudiant!['numero_etudiant'] ?? '',
                                    style: const TextStyle(color: AppTheme.primary, fontSize: 12)),
                              ],
                            ),
                          ),
                          const Icon(Icons.check_circle, color: AppTheme.success),
                        ],
                      ),

                      if (_isLoadingFrais)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: LinearProgressIndicator(),
                        ),

                      if (_inscription != null) ...[
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_inscription!['nom_filiere'] ?? '',
                                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                                Text(_inscription!['nom_niveau'] ?? '',
                                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Restant:', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                                Text(
                                  AppHelpers.formatMontant(double.tryParse(_inscription!['montant_restant']?.toString() ?? '0') ?? 0),
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.error, fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Type de frais
              AppDropdown<int>(
                label: 'Type de Frais',
                value: _selectedTypeFrais,
                items: _typesFrais.map((t) => DropdownMenuItem<int>(
                  value: t['id_type_frais'] as int,
                  child: Text(
                    '${t['nom_frais']} (${AppHelpers.formatMontant(double.tryParse(t['montant_base']?.toString() ?? '0') ?? 0)})',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )).toList(),
                onChanged: (v) {
                  setState(() => _selectedTypeFrais = v);
                  if (v != null) {
                    final tf = _typesFrais.firstWhere((t) => t['id_type_frais'] == v, orElse: () => {});
                    if (tf.isNotEmpty) _montantCtrl.text = tf['montant_base'].toString();
                  }
                },
              ),
              const SizedBox(height: 16),

              // Montant
              AppFormField(
                label:        'Montant (FC)',
                hint:         '0.00',
                prefixIcon:   Icons.monetization_on_outlined,
                controller:   _montantCtrl,
                keyboardType: TextInputType.number,
                validator:    (v) => AppValidators.minAmount(v, 1),
              ),
              const SizedBox(height: 16),

              // Mode de paiement
              AppDropdown<int>(
                label: 'Mode de Paiement',
                value: _selectedMode,
                items: _modesPaiement.map((m) => DropdownMenuItem<int>(
                  value: m['id_mode_paiement'] as int,
                  child: Text(
                    m['nom_mode'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )).toList(),
                onChanged: (v) => setState(() => _selectedMode = v),
              ),
              const SizedBox(height: 16),

              // Référence
              AppFormField(
                label:      'Référence Transaction',
                hint:       'Optionnel (N° reçu mobile, etc.)',
                prefixIcon: Icons.tag_outlined,
                controller: _referenceCtrl,
              ),
              const SizedBox(height: 28),

              AppButton(
                label:     'Enregistrer le Paiement',
                onPressed: _submit,
                isLoading: _isLoading,
                icon:      Icons.payments_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}