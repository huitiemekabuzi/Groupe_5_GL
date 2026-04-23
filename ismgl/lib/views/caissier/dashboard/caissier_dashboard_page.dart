import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ismgl/app/routes/app_routes.dart';
import 'package:ismgl/app/themes/app_theme.dart';
import 'package:ismgl/core/services/api_service.dart';
import 'package:ismgl/core/services/storage_service.dart';
import 'package:ismgl/core/utils/helpers.dart';
import 'package:ismgl/views/shared/widgets/custom_app_bar.dart';
import 'package:ismgl/views/shared/widgets/loading_widget.dart';

class CaissierDashboardPage extends StatefulWidget {
  const CaissierDashboardPage({super.key});

  @override
  State<CaissierDashboardPage> createState() => _CaissierDashboardPageState();
}

class _CaissierDashboardPageState extends State<CaissierDashboardPage> {
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
      appBar: const CustomAppBar(title: 'Caisse - ISMGL', showBack: false),
      body: _isLoading
          ? const LoadingWidget()
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildSummaryCard(),
                    const SizedBox(height: 16),
                    _buildActionButtons(),
                    const SizedBox(height: 16),
                    _buildModesPaiement(),
                    const SizedBox(height: 16),
                    _buildRecentTransactions(),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isCreating
            ? null
            : () async {
                setState(() => _isCreating = true);
                try {
                  await Get.toNamed(AppRoutes.caissierNouveauPaiement);
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
            : const Text('Nouveau Paiement'),
        icon: _isCreating ? null : const Icon(Icons.add),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildSummaryCard() {
    final montant = _data?['montant_aujourd_hui'] ?? 0;
    final nombre  = _data?['nombre_paiements_jour'] ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Caissier - Aujourd'hui", style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            AppHelpers.formatMontant(double.tryParse(montant.toString()) ?? 0),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$nombre transactions',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        SizedBox(
          width: (MediaQuery.of(context).size.width - 44) / 2,
          child: _QuickCard(
            'Mes Paiements',
            Icons.payments_rounded,
            AppTheme.primary,
            () => Get.toNamed(AppRoutes.caissierPaiements),
          ),
        ),
        SizedBox(
          width: (MediaQuery.of(context).size.width - 44) / 2,
          child: _QuickCard(
            'Mes Reçus',
            Icons.receipt_long_rounded,
            AppTheme.success,
            () => Get.toNamed(AppRoutes.caissierRecus),
          ),
        ),
        SizedBox(
          width: (MediaQuery.of(context).size.width - 44) / 2,
          child: _QuickCard(
            'Rapport',
            Icons.summarize_outlined,
            AppTheme.info,
            () => Get.toNamed(AppRoutes.caissierRapport),
          ),
        ),
      ],
    );
  }

  Widget _QuickCard(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModesPaiement() {
    final modes = (_data?['rapport_modes_paiement'] as List?) ?? [];

    if (modes.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Répartition par Mode',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...modes.map((m) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    m['nom_mode'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    AppHelpers.formatMontant(
                      double.tryParse(m['total']?.toString() ?? '0') ?? 0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    final paiements = (_data?['paiements_aujourd_hui'] as List?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Transactions du Jour',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        paiements.isEmpty
            ? const Center(
                child: Text(
                  'Aucune transaction aujourd\'hui',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              )
            : Column(
                children: paiements.take(10).map((p) => _TransactionItem(p)).toList(),
              ),
      ],
    );
  }

  Widget _TransactionItem(Map<String, dynamic> p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outline, color: AppTheme.success, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p['nom_complet_etudiant'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                Text(
                  p['nom_frais'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          Flexible(
            child: Text(
              AppHelpers.formatMontant(double.tryParse(p['montant']?.toString() ?? '0') ?? 0),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.success, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}