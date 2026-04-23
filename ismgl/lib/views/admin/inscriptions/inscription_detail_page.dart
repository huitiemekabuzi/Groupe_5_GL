import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ismgl/app/themes/app_theme.dart';
import 'package:ismgl/controllers/inscription_controller.dart';
import 'package:ismgl/data/models/inscription_model.dart';
import 'package:ismgl/core/utils/helpers.dart';

class InscriptionDetailPage extends StatelessWidget {
  const InscriptionDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final InscriptionModel ins = Get.arguments as InscriptionModel;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          ins.numeroInscription ?? 'Détail Inscription',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatusCard(inscription: ins),
          const SizedBox(height: 12),
          _InfoCard(
            title: 'Informations académiques',
            icon: Icons.school_outlined,
            rows: [
              _Row('Étudiant',       ins.nomCompletDisplay),
              _Row('N° Étudiant',    ins.numeroEtudiant ?? '—'),
              _Row('Filière',        ins.nomFiliere     ?? '—'),
              _Row('Niveau',         ins.nomNiveau      ?? '—'),
              _Row('Année',          ins.codeAnnee      ?? '—'),
              _Row('Type',           ins.typeInscription),
              _Row('Date inscription', ins.dateInscription ?? '—'),
            ],
          ),
          const SizedBox(height: 12),
          _FinancialCard(inscription: ins),
          const SizedBox(height: 12),
          if (ins.motifRejet != null && ins.estRejetee)
            _InfoCard(
              title: 'Motif de rejet',
              icon: Icons.cancel_outlined,
              rows: [_Row('Motif', ins.motifRejet!)],
              borderColor: AppTheme.error,
            ),
          const SizedBox(height: 16),
          if (ins.estEnAttente) _ActionButtons(inscription: ins),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final InscriptionModel inscription;
  const _StatusCard({required this.inscription});

  Color get _statusColor {
    switch (inscription.statutInscription) {
      case 'Validée':    return AppTheme.success;
      case 'Rejetée':    return AppTheme.error;
      case 'Annulée':    return AppTheme.textSecondary;
      default:           return AppTheme.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            inscription.nomCompletDisplay,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            inscription.numeroInscription ?? '',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _statusColor),
            ),
            child: Text(
              inscription.statutInscription,
              style: TextStyle(color: _statusColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _FinancialCard extends StatelessWidget {
  final InscriptionModel inscription;
  const _FinancialCard({required this.inscription});

  @override
  Widget build(BuildContext context) {
    final pct = inscription.montantTotal > 0
        ? (inscription.montantPaye / inscription.montantTotal * 100)
            .clamp(0.0, 100.0)
        : 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(children: [
              Icon(Icons.payments_outlined, color: AppTheme.primary),
              SizedBox(width: 8),
              Text('Situation financière',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ]),
            const Divider(height: 16),
            _Row('Montant total',   AppHelpers.formatCurrency(inscription.montantTotal)),
            _Row('Montant payé',    AppHelpers.formatCurrency(inscription.montantPaye),
                color: AppTheme.success),
            _Row('Montant restant', AppHelpers.formatCurrency(inscription.montantRestant),
                color: inscription.montantRestant > 0 ? AppTheme.error : AppTheme.success),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: pct / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(
                  inscription.estComplete ? AppTheme.success : AppTheme.warning),
              borderRadius: BorderRadius.circular(4),
              minHeight: 8,
            ),
            const SizedBox(height: 4),
            Text(
              '${inscription.pourcentagePaye ?? '${pct.toStringAsFixed(1)}%'} payé',
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_Row> rows;
  final Color? borderColor;
  const _InfoCard({
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
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
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
  final Color? color;
  const _Row(this.label, this.value, {this.color});

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
                style:
                    const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    color: color)),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final InscriptionModel inscription;
  const _ActionButtons({required this.inscription});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<InscriptionController>();
    return Obx(() => Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: ctrl.isSubmitting.value ? null : () => ctrl.valider(inscription),
            icon: ctrl.isSubmitting.value
                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.check_circle_outline),
            label: Text(ctrl.isSubmitting.value ? '...' : 'Valider'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.success,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: ctrl.isSubmitting.value ? null : () => _showRejectDialog(context, ctrl),
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('Rejeter'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    ));
  }

  void _showRejectDialog(BuildContext ctx, InscriptionController ctrl) {
    final motifCtrl = TextEditingController();
    Get.dialog(AlertDialog(
      title: const Text('Motif de rejet'),
      content: TextField(
        controller: motifCtrl,
        maxLines: 3,
        decoration: const InputDecoration(
          hintText: 'Expliquez la raison du rejet...',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Annuler')),
        ElevatedButton(
          onPressed: () {
            if (motifCtrl.text.trim().isEmpty) return;
            Get.back();
            ctrl.rejeter(inscription, motifCtrl.text.trim());
            Get.back();
          },
          style:
              ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
          child: const Text('Confirmer rejet',
              style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }
}
