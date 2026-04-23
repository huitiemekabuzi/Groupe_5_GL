import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ismgl/app/themes/app_theme.dart';
import 'package:ismgl/core/services/api_service.dart';
import 'package:ismgl/core/services/storage_service.dart';
import 'package:ismgl/core/utils/helpers.dart';
import 'package:ismgl/data/models/inscription_model.dart';
import 'package:ismgl/views/shared/widgets/custom_app_bar.dart';
import 'package:ismgl/views/shared/widgets/loading_widget.dart';
import 'package:ismgl/views/shared/widgets/status_chip.dart';

class InscriptionPage extends StatefulWidget {
  const InscriptionPage({super.key});

  @override
  State<InscriptionPage> createState() => _InscriptionPageState();
}

class _InscriptionPageState extends State<InscriptionPage> {
  final ApiService     _api     = Get.find<ApiService>();
  final StorageService _storage = Get.find<StorageService>();

  List<InscriptionModel> _inscriptions = [];
  Map<String, dynamic>?  _fraisDetail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);

    final result = await _api.get('/inscriptions/me');
    if (result['success'] == true) {
      setState(() {
        _inscriptions = (result['data'] as List)
            .map((i) => InscriptionModel.fromJson(i))
            .toList();
      });
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Mes Inscriptions',
        showBack: true,
        showNotification: false,
        showProfile: false,
      ),
      body: _isLoading
          ? const LoadingWidget()
          : RefreshIndicator(
              onRefresh: _load,
              child: _inscriptions.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.how_to_reg_outlined, size: 80, color: AppTheme.textSecondary),
                          SizedBox(height: 16),
                          Text('Aucune inscription', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
                          SizedBox(height: 8),
                          Text('Contactez la scolarité pour vous inscrire', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13), textAlign: TextAlign.center),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _inscriptions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _buildCard(_inscriptions[i]),
                    ),
            ),
    );
  }

  Widget _buildCard(InscriptionModel ins) {
    final progress = ins.montantTotal > 0 ? ins.montantPaye / ins.montantTotal : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          // En-tête coloré
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: ins.estValidee ? AppTheme.successGradient : AppTheme.primaryGradient,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ins.numeroInscription ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(ins.codeAnnee ?? '', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
                StatusChip(status: ins.statutInscription),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filière & Niveau
                Row(
                  children: [
                    const Icon(Icons.school_outlined, size: 18, color: AppTheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('${ins.nomFiliere ?? ''} - ${ins.nomNiveau ?? ''}',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.category_outlined, size: 16, color: AppTheme.textSecondary),
                    const SizedBox(width: 8),
                    Text(ins.typeInscription, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 16, color: AppTheme.textSecondary),
                    const SizedBox(width: 8),
                    Text('Inscrit le ${AppHelpers.formatDate(ins.dateInscription)}',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  ],
                ),
                const Divider(height: 24),

                // Situation financière
                const Text('Situation Financière', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    ins.estComplete ? AppTheme.success : AppTheme.primary,
                  ),
                  borderRadius: BorderRadius.circular(6),
                  minHeight: 10,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _MoneyItem('Total dû', ins.montantTotal, AppTheme.textSecondary),
                    _MoneyItem('Payé', ins.montantPaye, AppTheme.success),
                    _MoneyItem('Restant', ins.montantRestant, AppTheme.error),
                  ],
                ),

                // Message si complet
                if (ins.estComplete) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: AppTheme.success, size: 18),
                        SizedBox(width: 8),
                        Text('Paiement complet !', style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],

                // Message si rejeté
                if (ins.statutInscription == 'Rejetée') ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.error_outline, color: AppTheme.error, size: 18),
                        SizedBox(width: 8),
                        Expanded(child: Text('Inscription rejetée. Contactez la scolarité.', style: TextStyle(color: AppTheme.error, fontSize: 13))),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _MoneyItem(String label, double amount, Color color) {
    return Column(
      children: [
        Text(AppHelpers.formatMontant(amount, devise: 'FC'), style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 12)),
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
      ],
    );
  }
}