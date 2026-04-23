import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ismgl/app/routes/app_routes.dart';
import 'package:ismgl/app/themes/app_theme.dart';
import 'package:ismgl/core/services/api_service.dart';
import 'package:ismgl/core/utils/helpers.dart';
import 'package:ismgl/data/models/paiement_model.dart';
import 'package:ismgl/views/shared/widgets/custom_app_bar.dart';
import 'package:ismgl/views/shared/widgets/empty_state.dart';
import 'package:ismgl/views/shared/widgets/loading_widget.dart';

class MesPaiementsPage extends StatefulWidget {
  const MesPaiementsPage({super.key});

  @override
  State<MesPaiementsPage> createState() => _MesPaiementsPageState();
}

class _MesPaiementsPageState extends State<MesPaiementsPage> {
  final ApiService _api = Get.find<ApiService>();

  List<PaiementModel> _paiements = [];
  bool _isLoading = true;
  double _totalPaye = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);

    final result = await _api.get('/paiements/me');
    if (result['success'] == true) {
      final items = (result['data'] as List).map((p) => PaiementModel.fromJson(p)).toList();
      setState(() {
        _paiements = items;
        _totalPaye = items.fold(0.0, (sum, p) => sum + p.montant);
      });
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Mes Paiements',
        showBack: true,
        showNotification: false,
        showProfile: false,
      ),
      body: _isLoading
          ? const LoadingWidget()
          : RefreshIndicator(
              onRefresh: _load,
              child: _paiements.isEmpty
                  ? const EmptyState(message: 'Aucun paiement effectué', icon: Icons.payments_outlined)
                  : Column(
                      children: [
                        // Total
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: AppTheme.successGradient,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Total payé', style: TextStyle(color: Colors.white70, fontSize: 13)),
                                  Text('Tous les paiements', style: TextStyle(color: Colors.white60, fontSize: 11)),
                                ],
                              ),
                              Text(
                                AppHelpers.formatMontant(_totalPaye),
                                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: _paiements.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (_, i) => _buildCard(_paiements[i]),
                          ),
                        ),
                      ],
                    ),
            ),
    );
  }

  Widget _buildCard(PaiementModel p) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outline, color: AppTheme.success, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.nomFrais ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(p.numeroPaiement, style: const TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.w500)),
                Text(
                  '${AppHelpers.formatDate(p.datePaiement)} • ${p.modePaiement ?? ''}',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppHelpers.formatMontant(p.montant),
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.success, fontSize: 15),
              ),
              if (p.numeroRecu != null)
                GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.etudiantRecus),
                  child: const Text('Voir reçu', style: TextStyle(color: AppTheme.primary, fontSize: 11, decoration: TextDecoration.underline)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}