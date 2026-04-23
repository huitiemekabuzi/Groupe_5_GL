import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ismgl/app/routes/app_routes.dart';
import 'package:ismgl/app/themes/app_theme.dart';
import 'package:ismgl/core/services/api_service.dart';
import 'package:ismgl/core/services/storage_service.dart';
import 'package:ismgl/core/utils/helpers.dart';
import 'package:ismgl/views/shared/widgets/custom_app_bar.dart';
import 'package:ismgl/views/shared/widgets/loading_widget.dart';

class EtudiantDashboardPage extends StatefulWidget {
  const EtudiantDashboardPage({super.key});

  @override
  State<EtudiantDashboardPage> createState() => _EtudiantDashboardPageState();
}

class _EtudiantDashboardPageState extends State<EtudiantDashboardPage> {
  final ApiService     _api     = Get.find<ApiService>();
  final StorageService _storage = Get.find<StorageService>();

  Map<String, dynamic>? _data;
  bool _isLoading = true;

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
      appBar: const CustomAppBar(title: 'Mon Espace', showBack: false),
      body: _isLoading
          ? const LoadingWidget()
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildStudentCard(),
                    const SizedBox(height: 20),
                    _buildInscriptionCard(),
                    const SizedBox(height: 20),
                    _buildProgressCard(),
                    const SizedBox(height: 20),
                    _buildQuickActions(),
                    const SizedBox(height: 20),
                    _buildRecentPaiements(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStudentCard() {
    final etudiant = _data?['etudiant'] ?? {};
    final nom = '${etudiant['prenom'] ?? ''} ${etudiant['nom'] ?? ''}';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                AppHelpers.getInitials(nom),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nom.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  etudiant['numero_etudiant'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    etudiant['statut'] ?? 'Actif',
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInscriptionCard() {
    final inscription = _data?['inscription_courante'];

    if (inscription == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.warning.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppTheme.warning),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Aucune inscription pour l\'année courante.',
                style: TextStyle(color: AppTheme.warning),
              ),
            ),
            TextButton(
              onPressed: () => Get.toNamed(AppRoutes.etudiantInscription),
              child: const Text("S'inscrire"),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Mon Inscription', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppHelpers.getStatutInscriptionColor(inscription['statut_inscription'] ?? '').withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  inscription['statut_inscription'] ?? '',
                  style: TextStyle(
                    color: AppHelpers.getStatutInscriptionColor(inscription['statut_inscription'] ?? ''),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow('N° Inscription', inscription['numero_inscription'] ?? ''),
          _InfoRow('Filière', inscription['nom_filiere'] ?? ''),
          _InfoRow('Niveau', inscription['nom_niveau'] ?? ''),
          _InfoRow('Année', inscription['code_annee'] ?? ''),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    final inscription = _data?['inscription_courante'];
    if (inscription == null) return const SizedBox.shrink();

    final total   = double.tryParse(inscription['montant_total']?.toString()   ?? '0') ?? 0;
    final paye    = double.tryParse(inscription['montant_paye']?.toString()    ?? '0') ?? 0;
    final restant = double.tryParse(inscription['montant_restant']?.toString() ?? '0') ?? 0;
    final progress = total > 0 ? paye / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Situation Financière', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 1.0 ? AppTheme.success : AppTheme.primary,
            ),
            minHeight: 10,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _FinanceItem('Total', AppHelpers.formatMontant(total), AppTheme.textSecondary),
              _FinanceItem('Payé', AppHelpers.formatMontant(paye), AppTheme.success),
              _FinanceItem('Restant', AppHelpers.formatMontant(restant), AppTheme.error),
            ],
          ),
        ],
      ),
    );
  }

  Widget _FinanceItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        SizedBox(
          width: (MediaQuery.of(context).size.width - 56) / 3,
          child: _ActionBtn('Inscription', Icons.how_to_reg_rounded, AppTheme.primary, () => Get.toNamed(AppRoutes.etudiantInscription)),
        ),
        SizedBox(
          width: (MediaQuery.of(context).size.width - 56) / 3,
          child: _ActionBtn('Paiements', Icons.payments_rounded, AppTheme.success, () => Get.toNamed(AppRoutes.etudiantPaiements)),
        ),
        SizedBox(
          width: (MediaQuery.of(context).size.width - 56) / 3,
          child: _ActionBtn('Mes Reçus', Icons.receipt_long_rounded, AppTheme.warning, () => Get.toNamed(AppRoutes.etudiantRecus)),
        ),
      ],
    );
  }

  Widget _ActionBtn(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentPaiements() {
    final paiements = (_data?['paiements_recents'] as List?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Derniers Paiements', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            TextButton(
              onPressed: () => Get.toNamed(AppRoutes.etudiantPaiements),
              child: const Text('Voir tout'),
            ),
          ],
        ),
        ...paiements.take(3).map((p) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p['nom_frais'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(AppHelpers.formatDate(p['date_paiement']), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
              ),
              const SizedBox(width: 8),
              Text(
                AppHelpers.formatMontant(double.tryParse(p['montant']?.toString() ?? '0') ?? 0),
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.success),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _InfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}