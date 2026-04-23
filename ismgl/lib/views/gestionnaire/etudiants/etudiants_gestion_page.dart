import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ismgl/app/routes/app_routes.dart';
import 'package:ismgl/app/themes/app_theme.dart';
import 'package:ismgl/core/services/api_service.dart';
import 'package:ismgl/core/utils/helpers.dart';
import 'package:ismgl/data/models/etudiant_model.dart';
import 'package:ismgl/views/shared/widgets/custom_app_bar.dart';
import 'package:ismgl/views/shared/widgets/empty_state.dart';
import 'package:ismgl/views/shared/widgets/loading_widget.dart';
import 'package:ismgl/views/shared/widgets/status_chip.dart';

class EtudiantsGestionPage extends StatefulWidget {
  const EtudiantsGestionPage({super.key});

  @override
  State<EtudiantsGestionPage> createState() => _EtudiantsGestionPageState();
}

class _EtudiantsGestionPageState extends State<EtudiantsGestionPage> {
  final ApiService _api = Get.find<ApiService>();

  List<EtudiantModel> _etudiants = [];
  bool   _isLoading   = true;
  int    _currentPage = 1;
  int    _totalPages  = 1;
  int    _total       = 0;
  String _search      = '';

  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _load();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
        if (_currentPage < _totalPages && !_isLoading) {
          _currentPage++;
          _load(append: true);
        }
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _load({bool append = false, bool reset = false}) async {
    if (reset) { _currentPage = 1; _etudiants = []; }
    setState(() => _isLoading = true);

    final result = await _api.get('/etudiants', params: {
      'page': _currentPage, 'page_size': 20,
      if (_search.isNotEmpty) 'search': _search,
    });

    if (result['success'] == true) {
      final data = result['data'];
      final items = (data['items'] as List).map((e) => EtudiantModel.fromJson(e)).toList();
      setState(() {
        if (append) { _etudiants.addAll(items); } else { _etudiants = items; }
        _totalPages = data['pagination']['total_pages'];
        _total      = data['pagination']['total_items'];
      });
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Étudiants ($_total)',
        showBack: true,
        showNotification: false,
        showProfile: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.gestionEtudiantForm)?.then((_) => _load(reset: true)),
        label: const Text('Nouvel Étudiant'),
        icon: const Icon(Icons.person_add_rounded),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Nom, prénom, N° étudiant...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _search = '');
                        _load(reset: true);
                      })
                    : null,
              ),
              onChanged: (v) {
                setState(() => _search = v);
                if (v.length >= 3 || v.isEmpty) _load(reset: true);
              },
            ),
          ),
          Expanded(
            child: _isLoading && _etudiants.isEmpty
                ? const ShimmerList()
                : _etudiants.isEmpty
                    ? EmptyState(
                        message: 'Aucun étudiant trouvé',
                        icon: Icons.school_outlined,
                        actionLabel: 'Ajouter un étudiant',
                        onAction: () => Get.toNamed(AppRoutes.gestionEtudiantForm),
                      )
                    : RefreshIndicator(
                        onRefresh: () => _load(reset: true),
                        child: ListView.separated(
                          controller: _scrollCtrl,
                          padding: const EdgeInsets.all(16),
                          itemCount: _etudiants.length + (_isLoading ? 1 : 0),
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, i) {
                            if (i >= _etudiants.length) return const Center(child: CircularProgressIndicator());
                            return _buildCard(_etudiants[i]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(EtudiantModel e) {
    return GestureDetector(
      onTap: () => _showEtudiantDetail(e),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(14),
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
            child: Text(AppHelpers.getInitials(e.fullName),
                style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
          ),
          title: Row(
            children: [
              Expanded(child: Text(e.fullName, style: const TextStyle(fontWeight: FontWeight.w600))),
              StatusChip(status: e.statut, type: 'etudiant'),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text(e.numeroEtudiant, style: const TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w500)),
              Text(e.email, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            ],
          ),
          isThreeLine: true,
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textSecondary),
        ),
      ),
    );
  }

  void _showEtudiantDetail(EtudiantModel e) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        maxChildSize: 0.85,
        initialChildSize: 0.6,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    CircleAvatar(radius: 36, backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                        child: Text(AppHelpers.getInitials(e.fullName), style: const TextStyle(color: AppTheme.primary, fontSize: 24, fontWeight: FontWeight.bold))),
                    const SizedBox(height: 8),
                    Text(e.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text(e.numeroEtudiant, style: const TextStyle(color: AppTheme.primary)),
                    const SizedBox(height: 4),
                    StatusChip(status: e.statut, type: 'etudiant'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _InfoRow('Email', e.email),
              _InfoRow('Téléphone', e.telephone ?? 'N/A'),
              _InfoRow('Date de naissance', AppHelpers.formatDate(e.dateNaissance)),
              _InfoRow('Lieu de naissance', e.lieuNaissance ?? 'N/A'),
              _InfoRow('Sexe', e.sexe == 'M' ? 'Masculin' : 'Féminin'),
              _InfoRow('Nationalité', e.nationalite ?? 'N/A'),
              _InfoRow('Adresse', e.adresse ?? 'N/A'),
              _InfoRow('Ville', e.ville ?? 'N/A'),
              _InfoRow('Province', e.province ?? 'N/A'),
              _InfoRow('Groupe sanguin', e.groupeSanguin ?? 'N/A'),
              _InfoRow('Père', e.nomPere ?? 'N/A'),
              _InfoRow('Mère', e.nomMere ?? 'N/A'),
              _InfoRow('Tél. urgence', e.telephoneUrgence ?? 'N/A'),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () { Get.back(); Get.toNamed(AppRoutes.gestionInscriptionForm, arguments: e); },
                      icon: const Icon(Icons.how_to_reg_rounded, size: 18),
                      label: const Text('Inscrire'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _InfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
        ],
      ),
    );
  }
}