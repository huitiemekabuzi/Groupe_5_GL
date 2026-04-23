import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ismgl/app/themes/app_theme.dart';
import 'package:ismgl/controllers/paiement_controller.dart';
import 'package:ismgl/data/models/paiement_model.dart';
import 'package:ismgl/core/utils/helpers.dart';

class PaiementDetailPage extends StatelessWidget {
  const PaiementDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final PaiementModel paiement = Get.arguments as PaiementModel;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          paiement.numeroPaiement,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (paiement.estValide)
            PopupMenuButton<String>(
              onSelected: (val) {
                if (val == 'annuler') {
                  _showAnnulDialog(context, paiement);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                    value: 'annuler',
                    child: Row(children: [
                      Icon(Icons.cancel_outlined, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Annuler le paiement',
                          style: TextStyle(color: Colors.red)),
                    ])),
              ],
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // En-tête montant
          _AmountCard(paiement: paiement),
          const SizedBox(height: 12),

          // Étudiant
          _Section(
            title: 'Étudiant',
            icon: Icons.person_outline,
            rows: [
              _Row('N° Étudiant', paiement.numeroEtudiant         ?? '—'),
              _Row('Nom complet', paiement.nomCompletEtudiant     ?? '—'),
              _Row('N° Inscription', paiement.numeroInscription   ?? '—'),
            ],
          ),
          const SizedBox(height: 12),

          // Détails paiement
          _Section(
            title: 'Détails du paiement',
            icon: Icons.payments_outlined,
            rows: [
              _Row('N° Paiement',   paiement.numeroPaiement),
              _Row('Date',          paiement.datePaiement         ?? '—'),
              _Row('Type de frais', paiement.nomFrais             ?? '—'),
              _Row('Mode',          paiement.modePaiement         ?? '—'),
              _Row('Référence',     paiement.referenceTransaction ?? '—'),
              _Row('Caissier',      paiement.recuParNom           ?? '—'),
              _Row('Statut',        paiement.statutPaiement),
            ],
          ),
          const SizedBox(height: 12),

          if (paiement.numeroRecu != null)
            _Section(
              title: 'Reçu',
              icon: Icons.receipt_outlined,
              rows: [
                _Row('N° Reçu', paiement.numeroRecu!),
              ],
            ),

          if (paiement.estAnnule)
            ...[
              const SizedBox(height: 12),
              _Section(
                title: 'Annulation',
                icon: Icons.cancel_outlined,
                borderColor: AppTheme.error,
                rows: [
                  _Row('Motif', paiement.motifAnnulation ?? '—'),
                  _Row('Date annulation', paiement.dateAnnulation ?? '—'),
                ],
              ),
            ],
        ],
      ),
    );
  }

  static void _showAnnulDialog(BuildContext ctx, PaiementModel paiement) {
    final motifCtrl = TextEditingController();
    Get.dialog(AlertDialog(
      title: const Text('Annuler le paiement'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${paiement.numeroPaiement} — ${AppHelpers.formatCurrency(paiement.montant)}'),
          const SizedBox(height: 12),
          TextField(
            controller: motifCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Motif d\'annulation...',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Annuler')),
        ElevatedButton(
          onPressed: () {
            if (motifCtrl.text.trim().isEmpty) return;
            Get.back();
            Get.find<PaiementController>()
                .annuler(paiement, motifCtrl.text.trim());
            Get.back();
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
          child: const Text('Confirmer', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }
}

class _AmountCard extends StatelessWidget {
  final PaiementModel paiement;
  const _AmountCard({required this.paiement});

  @override
  Widget build(BuildContext context) {
    final statusColor = paiement.estValide
        ? AppTheme.success
        : paiement.estAnnule
            ? AppTheme.error
            : AppTheme.warning;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: paiement.estValide
            ? AppTheme.successGradient
            : AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.payments, color: Colors.white, size: 40),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              AppHelpers.formatCurrency(paiement.montant),
              style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor),
            ),
            child: Text(
              paiement.statutPaiement,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> rows;
  final Color? borderColor;
  const _Section({
    required this.title,
    required this.icon,
    required this.rows,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: borderColor != null
            ? BorderSide(color: borderColor!, width: 1.5)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: borderColor ?? AppTheme.primary, size: 18),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ]),
            const Divider(height: 16),
            ...rows,
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
