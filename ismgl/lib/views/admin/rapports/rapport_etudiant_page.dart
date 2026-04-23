import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ismgl/app/themes/app_theme.dart';
import 'package:ismgl/controllers/rapport_controller.dart';
import 'package:ismgl/core/utils/helpers.dart';

class RapportEtudiantPage extends StatefulWidget {
  const RapportEtudiantPage({super.key});

  @override
  State<RapportEtudiantPage> createState() => _RapportEtudiantPageState();
}

class _RapportEtudiantPageState extends State<RapportEtudiantPage> {
  final RapportController _ctrl = Get.find<RapportController>();
  late final int _idEtudiant;

  @override
  void initState() {
    super.initState();
    _idEtudiant = Get.arguments as int? ?? 0;
    _ctrl.loadSituationEtudiant(_idEtudiant);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Situation Financière'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (_ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final ins = _ctrl.situationEtudiant.value;
        final paiements = _ctrl.paiementsEtudiant;

        if (ins == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 64, color: AppTheme.textSecondary),
                SizedBox(height: 16),
                Text('Aucune inscription trouvée pour l\'année courante',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textSecondary)),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _InscriptionCard(data: ins),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [
                      Icon(Icons.history, color: AppTheme.primary, size: 18),
                      SizedBox(width: 8),
                      Text('Historique des paiements',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ]),
                    const Divider(height: 16),
                    if (paiements.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text('Aucun paiement',
                              style: TextStyle(color: AppTheme.textSecondary)),
                        ),
                      )
                    else
                      ...paiements.map((p) => _PaiementTile(paiement: p)),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _InscriptionCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _InscriptionCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final montantTotal   = double.tryParse(data['montant_total']?.toString()   ?? '0') ?? 0;
    final montantPaye    = double.tryParse(data['montant_paye']?.toString()    ?? '0') ?? 0;
    final montantRestant = double.tryParse(data['montant_restant']?.toString() ?? '0') ?? 0;
    final estComplete    = data['est_complete'] == true || data['est_complete'] == 1;
    final pct = montantTotal > 0 ? (montantPaye / montantTotal).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: estComplete ? AppTheme.successGradient : AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data['numero_inscription'] as String? ?? '—',
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 4),
          Text('${data['nom_filiere'] ?? '—'} — ${data['nom_niveau'] ?? '—'}',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(height: 16),
          Row(children: [
            _Stat('Total attendu',  AppHelpers.formatCurrency(montantTotal)),
            const SizedBox(width: 16),
            _Stat('Payé',          AppHelpers.formatCurrency(montantPaye)),
            const SizedBox(width: 16),
            _Stat('Restant',       AppHelpers.formatCurrency(montantRestant)),
          ]),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: pct,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            valueColor: const AlwaysStoppedAnimation(Colors.white),
            borderRadius: BorderRadius.circular(4),
            minHeight: 8,
          ),
          const SizedBox(height: 4),
          Text('${(pct * 100).toStringAsFixed(1)}% payé',
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14)),
      ]),
    );
  }
}

class _PaiementTile extends StatelessWidget {
  final Map<String, dynamic> paiement;
  const _PaiementTile({required this.paiement});

  @override
  Widget build(BuildContext context) {
    final montant = double.tryParse(paiement['montant']?.toString() ?? '0') ?? 0;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppTheme.success.withValues(alpha: 0.1),
        child: const Icon(Icons.payments,
            color: AppTheme.success, size: 20),
      ),
      title: Text(paiement['nom_frais'] as String? ?? '—',
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
      subtitle: Text(
          '${paiement['date_paiement'] ?? ''} — ${paiement['nom_mode'] ?? ''}',
          style: const TextStyle(fontSize: 12)),
      trailing: Text(
        AppHelpers.formatCurrency(montant),
        style: const TextStyle(
            color: AppTheme.success,
            fontWeight: FontWeight.bold,
            fontSize: 14),
      ),
    );
  }
}
