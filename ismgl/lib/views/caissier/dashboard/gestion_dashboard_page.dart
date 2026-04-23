import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ismgl/app/routes/app_routes.dart';
import 'package:ismgl/app/themes/app_theme.dart';
import 'package:ismgl/core/services/api_service.dart';
import 'package:ismgl/core/services/storage_service.dart';
import 'package:ismgl/views/shared/widgets/custom_app_bar.dart';
import 'package:ismgl/views/shared/widgets/loading_widget.dart';

class GestionDashboardPage extends StatefulWidget {
  const GestionDashboardPage({super.key});

  @override
  State<GestionDashboardPage> createState() => _GestionDashboardPageState();
}

class _GestionDashboardPageState extends State<GestionDashboardPage> {
  final ApiService     _api     = Get.find<ApiService>();
  final StorageService _storage = Get.find<StorageService>();

  Map<String, dynamic>? _data;
  bool _isLoading = true;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final result = await _api.get('/dashboard');
    if (!mounted) return;
    if (result['success'] == true) {
      setState(() => _data = result['data']);
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Gestion - ISMGL', showBack: false),
      body: _isLoading
          ? const LoadingWidget()
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildStatsRow(),
                    const SizedBox(height: 20),
                    _buildActions(),
                    const SizedBox(height: 20),
                    _buildInscriptionsEnAttente(),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isCreating
            ? null
            : () async {
                if (!mounted) return;
                setState(() => _isCreating = true);
                try {
                  await Get.toNamed(AppRoutes.gestionEtudiantForm);
                  await _load();
                } finally {
                  if (mounted) setState(() => _isCreating = false);
                }
              },
        label: _isCreating
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Text('Nouvel Étudiant'),
        icon: _isCreating ? null : const Icon(Icons.person_add_rounded),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour, ${_storage.getUserPrenom()}!',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const Text(
                  'Gestionnaire',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              Text('${_data?['inscriptions_en_attente'] ?? 0}',
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              const Text('En attente', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final total = _data?['total_etudiants'] ?? 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        return Row(
          children: [
            _StatCard('Étudiants', '$total', Icons.people_alt_rounded, AppTheme.primary, compact: compact),
            const SizedBox(width: 12),
            _StatCard(
              'Filières',
              '${(_data?['repartition_par_filiere'] as List?)?.length ?? 0}',
              Icons.school_rounded,
              AppTheme.success,
              compact: compact,
            ),
          ],
        );
      },
    );
  }

  Widget _StatCard(String label, String value, IconData icon, Color color, {bool compact = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: TextStyle(fontSize: compact ? 20 : 24, fontWeight: FontWeight.bold, color: color)),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        SizedBox(
          width: (MediaQuery.of(context).size.width - 44) / 2,
          child: _ActionBtn('Étudiants', Icons.people_rounded, AppTheme.primary,
              () => Get.toNamed(AppRoutes.gestionEtudiants)),
        ),
        SizedBox(
          width: (MediaQuery.of(context).size.width - 44) / 2,
          child: _ActionBtn('Inscriptions', Icons.how_to_reg_rounded, AppTheme.success,
              () => Get.toNamed(AppRoutes.gestionInscriptions)),
        ),
      ],
    );
  }

  Widget _ActionBtn(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInscriptionsEnAttente() {
    final inscriptions = (_data?['inscriptions_recentes'] as List?) ?? [];
    final enAttente = inscriptions.where((i) => i['statut_inscription'] == 'En attente').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Inscriptions en Attente', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        if (enAttente.isEmpty)
          const Center(child: Text('Aucune inscription en attente', style: TextStyle(color: AppTheme.textSecondary)))
        else
          ...enAttente.take(5).map((i) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.warning.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.pending_outlined, color: AppTheme.warning, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${i['prenom']} ${i['nom']}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        i['nom_filiere'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('En attente', style: TextStyle(color: AppTheme.warning, fontSize: 11)),
                ),
              ],
            ),
          )),
      ],
    );
  }
}