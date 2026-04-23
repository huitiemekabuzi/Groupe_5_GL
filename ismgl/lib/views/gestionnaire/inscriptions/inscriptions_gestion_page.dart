import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ismgl/app/themes/app_theme.dart';
import 'package:ismgl/core/services/api_service.dart';
import 'package:ismgl/core/utils/helpers.dart';
import 'package:ismgl/data/models/inscription_model.dart';
import 'package:ismgl/views/shared/widgets/custom_app_bar.dart';
import 'package:ismgl/views/shared/widgets/empty_state.dart';
import 'package:ismgl/views/shared/widgets/loading_widget.dart';
import 'package:ismgl/views/shared/widgets/status_chip.dart';

class InscriptionsGestionPage extends StatefulWidget {
  const InscriptionsGestionPage({super.key});

  @override
  State<InscriptionsGestionPage> createState() => _InscriptionsGestionPageState();
}

class _InscriptionsGestionPageState extends State<InscriptionsGestionPage> {
  final ApiService _api = Get.find<ApiService>();

  List<InscriptionModel> _inscriptions = [];
  bool   _isLoading   = true;
  int    _currentPage = 1;
  int    _totalPages  = 1;
  int    _total       = 0;
  String _search      = '';
  String? _filterStatut;

  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  // Pour nouvelle inscription
  List<dynamic> _filieres        = [];
  List<dynamic> _niveaux         = [];
  List<dynamic> _annees          = [];
  List<dynamic> _etudiants       = [];
  Map<String, dynamic>? _etudiantToInscribe;

  @override
  void initState() {
    super.initState();
    _etudiantToInscribe = Get.arguments;
    _load();
    _loadConfig();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
        if (_currentPage < _totalPages && !_isLoading) {
          _currentPage++;
          _load(append: true);
        }
      }
    });

    if (_etudiantToInscribe != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showInscriptionForm());
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadConfig() async {
    final results = await Future.wait([
      _api.get('/etudiants', params: {'page': 1, 'page_size': 200}),
      _api.get('/filieres'),
      _api.get('/config/niveaux'),
      _api.get('/config/annees'),
    ]);
    setState(() {
      final etudiantsPayload = results[0]['data'];
      if (etudiantsPayload is Map<String, dynamic>) {
        _etudiants = (etudiantsPayload['items'] as List?) ?? [];
      } else {
        _etudiants = (etudiantsPayload as List?) ?? [];
      }
      _filieres = (results[1]['data'] as List?) ?? [];
      _niveaux  = (results[2]['data'] as List?) ?? [];
      _annees   = (results[3]['data'] as List?) ?? [];
    });
  }

  Future<void> _load({bool append = false, bool reset = false}) async {
    if (reset) { _currentPage = 1; _inscriptions = []; }
    setState(() => _isLoading = true);

    final result = await _api.get('/inscriptions', params: {
      'page': _currentPage, 'page_size': 20,
      if (_search.isNotEmpty)    'search': _search,
      if (_filterStatut != null) 'statut': _filterStatut,
    });

    if (result['success'] == true) {
      final data  = result['data'];
      final items = (data['items'] as List).map((i) => InscriptionModel.fromJson(i)).toList();
      setState(() {
        if (append) { _inscriptions.addAll(items); } else { _inscriptions = items; }
        _totalPages = data['pagination']['total_pages'];
        _total      = data['pagination']['total_items'];
      });
    }

    setState(() => _isLoading = false);
  }

  Future<void> _valider(InscriptionModel ins) async {
    final result = await _api.patch('/inscriptions/${ins.idInscription}/valider');
    if (result['success'] == true) {
      AppHelpers.showSuccess('Inscription validée');
      _load(reset: true);
    } else {
      AppHelpers.showError(result['message'] ?? 'Erreur');
    }
  }

  void _showInscriptionForm() {
    int? selectedEtudiant = _etudiantToInscribe?['id_etudiant'] as int?;
    int? selectedFiliere;
    int? selectedNiveau;
    int? selectedAnnee;
    String typeInscription = 'Nouvelle';

    // Trouver l'année courante
    final anneeCourante = _annees.firstWhere((a) => a['est_courante'] == true || a['est_courante'] == 1, orElse: () => _annees.isNotEmpty ? _annees.first : {});
    if (anneeCourante.isNotEmpty) selectedAnnee = anneeCourante['id_annee_academique'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (_, setStateModal) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(_).viewInsets.bottom,
            left: 20, right: 20, top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Text(
                'Nouvelle inscription${_etudiantToInscribe != null ? ' - ${_etudiantToInscribe!['prenom']} ${_etudiantToInscribe!['nom']}' : ''}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),

              if (_etudiantToInscribe == null) ...[
                DropdownButtonFormField<int>(
                  initialValue: selectedEtudiant,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Étudiant'),
                  items: _etudiants.map<DropdownMenuItem<int>>((e) => DropdownMenuItem<int>(
                    value: e['id_etudiant'] as int,
                    child: Text(
                      '${e['prenom'] ?? ''} ${e['nom'] ?? ''}'.trim(),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )).toList(),
                  onChanged: (v) => setStateModal(() => selectedEtudiant = v),
                ),
                const SizedBox(height: 12),
              ],

              // Filière
              DropdownButtonFormField<int>(
                initialValue: selectedFiliere,
                decoration: const InputDecoration(labelText: 'Filière'),
                items: _filieres.map<DropdownMenuItem<int>>((f) => DropdownMenuItem<int>(
                  value: f['id_filiere'] as int,
                  child: Text(f['nom_filiere'] ?? ''),
                )).toList(),
                onChanged: (v) => setStateModal(() => selectedFiliere = v),
              ),
              const SizedBox(height: 12),

              // Niveau
              DropdownButtonFormField<int>(
                initialValue: selectedNiveau,
                decoration: const InputDecoration(labelText: 'Niveau'),
                items: _niveaux.map<DropdownMenuItem<int>>((n) => DropdownMenuItem<int>(
                  value: n['id_niveau'] as int,
                  child: Text(n['nom_niveau'] ?? ''),
                )).toList(),
                onChanged: (v) => setStateModal(() => selectedNiveau = v),
              ),
              const SizedBox(height: 12),

              // Année
              DropdownButtonFormField<int>(
                initialValue: selectedAnnee,
                decoration: const InputDecoration(labelText: 'Année Académique'),
                items: _annees.map<DropdownMenuItem<int>>((a) => DropdownMenuItem<int>(
                  value: a['id_annee_academique'] as int,
                  child: Text(a['code_annee'] ?? ''),
                )).toList(),
                onChanged: (v) => setStateModal(() => selectedAnnee = v),
              ),
              const SizedBox(height: 12),

              // Type
              DropdownButtonFormField<String>(
                initialValue: typeInscription,
                decoration: const InputDecoration(labelText: 'Type d\'inscription'),
                items: ['Nouvelle', 'Réinscription', 'Transfert'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setStateModal(() => typeInscription = v ?? 'Nouvelle'),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final etudiantId = _etudiantToInscribe?['id_etudiant'] ?? selectedEtudiant;
                    if (selectedFiliere == null || selectedNiveau == null || selectedAnnee == null || etudiantId == null) {
                      AppHelpers.showError('Veuillez remplir tous les champs');
                      return;
                    }
                    Get.back();
                    final result = await _api.post('/inscriptions', data: {
                      'id_etudiant':        etudiantId,
                      'id_filiere':         selectedFiliere,
                      'id_niveau':          selectedNiveau,
                      'id_annee_academique': selectedAnnee,
                      'type_inscription':   typeInscription,
                    });

                    if (result['success'] == true) {
                      AppHelpers.showSuccess('Inscription enregistrée');
                      _load(reset: true);
                    } else {
                      AppHelpers.showError(result['message'] ?? 'Erreur');
                    }
                  },
                  icon: const Icon(Icons.how_to_reg_rounded),
                  label: const Text('Enregistrer l\'inscription'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Inscriptions ($_total)',
        showBack: true,
        showNotification: false,
        showProfile: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showInscriptionForm,
        label: const Text('Nouvelle inscription'),
        icon: const Icon(Icons.add),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchCtrl.clear(); setState(() => _search = ''); _load(reset: true); })
                    : null,
              ),
              onChanged: (v) { setState(() => _search = v); if (v.length >= 3 || v.isEmpty) _load(reset: true); },
            ),
          ),
          // Filtre statut
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: ['Toutes', 'En attente', 'Validée', 'Rejetée'].map((s) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(s),
                  selected: s == 'Toutes' ? _filterStatut == null : _filterStatut == s,
                  onSelected: (_) {
                    setState(() => _filterStatut = s == 'Toutes' ? null : s);
                    _load(reset: true);
                  },
                  selectedColor: AppTheme.primary.withValues(alpha: 0.2),
                ),
              )).toList(),
            ),
          ),
          Expanded(
            child: _isLoading && _inscriptions.isEmpty
                ? const ShimmerList()
                : _inscriptions.isEmpty
                    ? const EmptyState(message: 'Aucune inscription trouvée', icon: Icons.how_to_reg_outlined)
                    : RefreshIndicator(
                        onRefresh: () => _load(reset: true),
                        child: ListView.separated(
                          controller: _scrollCtrl,
                          padding: const EdgeInsets.all(16),
                          itemCount: _inscriptions.length + (_isLoading ? 1 : 0),
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, i) {
                            if (i >= _inscriptions.length) return const Center(child: CircularProgressIndicator());
                            return _buildCard(_inscriptions[i]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(InscriptionModel ins) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(ins.nomComplet ?? '', style: const TextStyle(fontWeight: FontWeight.bold))),
              StatusChip(status: ins.statutInscription),
            ],
          ),
          const SizedBox(height: 4),
          Text(ins.numeroInscription ?? '', style: const TextStyle(color: AppTheme.primary, fontSize: 12)),
          Text('${ins.nomFiliere ?? ''} - ${ins.nomNiveau ?? ''}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppHelpers.formatMontant(ins.montantPaye), style: const TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold, fontSize: 13)),
              Text('Restant: ${AppHelpers.formatMontant(ins.montantRestant)}', style: const TextStyle(color: AppTheme.error, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: ins.montantTotal > 0 ? (ins.montantPaye / ins.montantTotal).clamp(0.0, 1.0) : 0,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(ins.estComplete ? AppTheme.success : AppTheme.primary),
            borderRadius: BorderRadius.circular(4),
          ),
          if (ins.estEnAttente) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _valider(ins),
                    icon: const Icon(Icons.check, size: 14),
                    label: const Text('Valider', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(foregroundColor: AppTheme.success, side: const BorderSide(color: AppTheme.success)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}