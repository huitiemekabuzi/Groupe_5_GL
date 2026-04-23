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

class InscriptionsPage extends StatefulWidget {
  const InscriptionsPage({super.key});

  @override
  State<InscriptionsPage> createState() => _InscriptionsPageState();
}

class _InscriptionsPageState extends State<InscriptionsPage> with SingleTickerProviderStateMixin {
  final ApiService _api = Get.find<ApiService>();
  late TabController _tabController;

  List<InscriptionModel> _inscriptions = [];
  bool   _isLoading   = true;
  int    _currentPage = 1;
  int    _totalPages  = 1;
  int    _total       = 0;
  String _search      = '';
  String? _filterStatut;
  int? _busyInscriptionId;
  String? _busyAction;

  final _searchCtrl = TextEditingController();

  final _tabs = ['Toutes', 'En attente', 'Validées', 'Rejetées'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _filterStatut = _tabController.index == 0 ? null : _tabs[_tabController.index];
        });
        _load(reset: true);
      }
    });
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load({bool reset = false}) async {
    if (reset) { _currentPage = 1; _inscriptions = []; }
    setState(() => _isLoading = true);

    final result = await _api.get('/inscriptions', params: {
      'page': _currentPage,
      'page_size': 20,
      if (_search.isNotEmpty)    'search': _search,
      if (_filterStatut != null) 'statut': _filterStatut,
    });

    if (result['success'] == true) {
      final data = result['data'];
      final items = (data['items'] as List).map((i) => InscriptionModel.fromJson(i)).toList();
      setState(() {
        _inscriptions = items;
        _totalPages   = data['pagination']['total_pages'];
        _total        = data['pagination']['total_items'];
      });
    }

    setState(() => _isLoading = false);
  }

  Future<void> _valider(InscriptionModel ins) async {
    if (_busyInscriptionId == ins.idInscription) return;
    final confirm = await AppHelpers.showConfirmDialog(
      title: 'Valider inscription', message: 'Valider l\'inscription de ${ins.nomComplet} ?',
      confirmText: 'Valider', confirmColor: AppTheme.success,
    );
    if (!confirm) return;

    setState(() {
      _busyInscriptionId = ins.idInscription;
      _busyAction = 'valider';
    });
    final result = await _api.patch('/inscriptions/${ins.idInscription}/valider');
    if (result['success'] == true) {
      AppHelpers.showSuccess('Inscription validée');
      await _load(reset: true);
    }
    if (mounted) {
      setState(() {
        _busyInscriptionId = null;
        _busyAction = null;
      });
    }
  }

  Future<void> _rejeter(InscriptionModel ins) async {
    if (_busyInscriptionId == ins.idInscription) return;
    final motifCtrl = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rejeter inscription'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Motif du rejet pour ${ins.nomComplet}'),
            const SizedBox(height: 12),
            TextField(
              controller: motifCtrl,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Entrez le motif...'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Rejeter'),
          ),
        ],
      ),
    );

    if (confirm == true && motifCtrl.text.isNotEmpty) {
      setState(() {
        _busyInscriptionId = ins.idInscription;
        _busyAction = 'rejeter';
      });
      final result = await _api.patch(
        '/inscriptions/${ins.idInscription}/rejeter',
        data: {'motif': motifCtrl.text},
      );
      if (result['success'] == true) {
        AppHelpers.showSuccess('Inscription rejetée');
        await _load(reset: true);
      }
      if (mounted) {
        setState(() {
          _busyInscriptionId = null;
          _busyAction = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Inscriptions ($_total)',
        showBack: true,
        showNotification: false,
        showProfile: false,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => _load(reset: true)),
        ],
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                hintText: 'Rechercher...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) {
                setState(() => _search = v);
                if (v.length >= 3 || v.isEmpty) _load(reset: true);
              },
            ),
          ),
          // Tabs
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.primary,
            tabs: _tabs.map((t) => Tab(text: t)).toList(),
          ),
          Expanded(
            child: _isLoading
                ? const ShimmerList()
                : _inscriptions.isEmpty
                    ? const EmptyState(message: 'Aucune inscription trouvée', icon: Icons.how_to_reg_outlined)
                    : RefreshIndicator(
                        onRefresh: () => _load(reset: true),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _inscriptions.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, i) => _buildCard(_inscriptions[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(InscriptionModel ins) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(ins.nomComplet ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                const SizedBox(width: 8),
                StatusChip(status: ins.statutInscription),
              ],
            ),
            const SizedBox(height: 6),
            Text(ins.numeroInscription ?? '', style: const TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                const Icon(Icons.school_outlined, size: 14, color: AppTheme.textSecondary),
                Text(
                  '${ins.nomFiliere ?? ''} - ${ins.nomNiveau ?? ''}',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 14, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text(AppHelpers.formatDate(ins.dateInscription),
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            // Progression financière
            Wrap(
              spacing: 8,
              runSpacing: 4,
              alignment: WrapAlignment.spaceBetween,
              children: [
                Text(AppHelpers.formatMontant(ins.montantPaye), style: const TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold)),
                Text('/ ${AppHelpers.formatMontant(ins.montantTotal)}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                Text(ins.pourcentagePaye ?? '0%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: ins.montantTotal > 0 ? (ins.montantPaye / ins.montantTotal).clamp(0.0, 1.0) : 0,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(ins.estComplete ? AppTheme.success : AppTheme.primary),
              borderRadius: BorderRadius.circular(4),
            ),
            // Actions si En attente
            if (ins.estEnAttente) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _busyInscriptionId == ins.idInscription ? null : () => _rejeter(ins),
                      icon: _busyInscriptionId == ins.idInscription && _busyAction == 'rejeter'
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.close, size: 16),
                      label: Text(_busyInscriptionId == ins.idInscription && _busyAction == 'rejeter' ? '...' : 'Rejeter'),
                      style: OutlinedButton.styleFrom(foregroundColor: AppTheme.error, side: const BorderSide(color: AppTheme.error)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _busyInscriptionId == ins.idInscription ? null : () => _valider(ins),
                      icon: _busyInscriptionId == ins.idInscription && _busyAction == 'valider'
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.check, size: 16),
                      label: Text(_busyInscriptionId == ins.idInscription && _busyAction == 'valider' ? '...' : 'Valider'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}