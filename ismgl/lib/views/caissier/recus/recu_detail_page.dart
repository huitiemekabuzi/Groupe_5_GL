import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ismgl/app/themes/app_theme.dart';
import 'package:ismgl/controllers/recu_controller.dart';

class RecuDetailPage extends StatelessWidget {
  const RecuDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<RecuController>();
    final int id = Get.arguments as int? ?? 0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ctrl.loadRecu(id);
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Détail du Reçu'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Obx(() {
            if (ctrl.isGenerating.value) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2)),
              );
            }
            return IconButton(
              icon: const Icon(Icons.download_outlined),
              tooltip: 'Télécharger le reçu',
              onPressed: () => ctrl.downloadRecu(id),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final recu = ctrl.selectedRecu.value;
        if (recu == null) {
          return const Center(child: Text('Reçu introuvable'));
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // En-tête reçu
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.successGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.receipt_long, color: Colors.white, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    recu.numeroRecu,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Text(
                    'Émis le ${recu.dateEmission}',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${recu.montantTotal.toStringAsFixed(0)} FC',
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Informations étudiant
            _Section(
              title: 'Étudiant',
              icon: Icons.person_outline,
              rows: [
                _Row('N° Étudiant', recu.numeroEtudiant ?? '—'),
                _Row('Nom complet', recu.nomCompletEtudiant ?? '—'),
                _Row('Email',       recu.email ?? '—'),
              ],
            ),
            const SizedBox(height: 12),

            // Informations paiement
            _Section(
              title: 'Paiement',
              icon: Icons.payments_outlined,
              rows: [
                _Row('N° Paiement',    recu.numeroPaiement ?? '—'),
                _Row('Date paiement',  recu.datePaiement   ?? '—'),
                _Row('Type de frais',  recu.nomFrais       ?? '—'),
                _Row('Mode paiement',  recu.modePaiement   ?? '—'),
                _Row('Référence',      recu.referenceTransaction ?? '—'),
                _Row('Émis par',       recu.emisParNom     ?? '—'),
              ],
            ),
            const SizedBox(height: 12),

            // Informations inscription
            _Section(
              title: 'Inscription',
              icon: Icons.school_outlined,
              rows: [
                _Row('N° Inscription', recu.numeroInscription ?? '—'),
                _Row('Filière',        recu.nomFiliere        ?? '—'),
                _Row('Niveau',         recu.nomNiveau         ?? '—'),
                _Row('Année',          recu.codeAnnee         ?? '—'),
              ],
            ),
            const SizedBox(height: 12),

            // Impressions
            _Section(
              title: 'Impressions',
              icon: Icons.print_outlined,
              rows: [
                _Row('Imprimé',      recu.estImprime ? 'Oui' : 'Non'),
                _Row('Nb impressions', '${recu.nombreImpressions}'),
                _Row('Date impression', recu.dateImpression ?? '—'),
              ],
            ),
            const SizedBox(height: 16),

            // Bouton téléchargement
            Obx(() {
              final url = ctrl.pdfUrl.value;
              if (url != null) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.success, width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppTheme.success),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Dernier fichier : $url',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox();
            }),
          ],
        );
      }),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_Row> rows;
  const _Section({required this.title, required this.icon, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: AppTheme.primary, size: 18),
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
              width: 130,
              child: Text(label,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13))),
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
