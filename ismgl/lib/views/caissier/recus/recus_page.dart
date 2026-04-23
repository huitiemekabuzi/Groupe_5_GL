import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ismgl/app/themes/app_theme.dart';
import 'package:ismgl/core/services/api_service.dart';
import 'package:ismgl/core/utils/download_share_helper.dart';
import 'package:ismgl/core/utils/helpers.dart';
import 'package:ismgl/views/shared/widgets/button.dart';
import 'package:ismgl/views/shared/widgets/custom_app_bar.dart';
import 'package:ismgl/views/shared/widgets/empty_state.dart';
import 'package:ismgl/views/shared/widgets/loading_widget.dart';

class RecusPage extends StatefulWidget {
  const RecusPage({super.key});

  @override
  State<RecusPage> createState() => _RecusPageState();
}

class _RecusPageState extends State<RecusPage> {
  final ApiService _api = Get.find<ApiService>();

  List<dynamic> _recus = [];
  bool _isLoading = true;
  int? _idPaiement;
  Map<String, dynamic>? _recuDetail;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _idPaiement = Get.arguments as int?;
    if (_idPaiement != null) {
      _loadRecuByPaiement(_idPaiement!);
    } else {
      _loadRecentRecus();
    }
  }

  Future<void> _loadRecuByPaiement(int idPaiement) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final result = await _api.get('/paiements/$idPaiement');
    if (!mounted) return;
    if (result['success'] == true) {
      final recuId = result['data']?['id_recu'] ?? result['data']?['recu_id'];
      if (recuId != null) {
        final recuResult = await _api.get('/recus/$recuId');
        if (!mounted) return;
        if (recuResult['success'] == true) {
          setState(() => _recuDetail = recuResult['data']);
        }
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadRecentRecus() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final result = await _api.get('/paiements',
        params: {'page': 1, 'page_size': 30, 'statut': 'Validé'});
    if (!mounted) return;
    if (result['success'] == true) {
      setState(() => _recus = (result['data']['items'] as List?) ?? []);
    }
    if (mounted) setState(() => _isLoading = false);
  }

  String _extensionRecu(Uint8List bytes) {
    if (bytes.length >= 4 &&
        bytes[0] == 0x25 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x44 &&
        bytes[3] == 0x46) {
      return 'pdf';
    }
    return 'html';
  }

  Future<void> _genererRecu(dynamic idRecuRaw) async {
    final id = idRecuRaw is int ? idRecuRaw : int.tryParse('$idRecuRaw');
    if (id == null) return;

    setState(() => _isGenerating = true);
    try {
      // 1) Génération (retourne souvent un fichier HTML dans `pdf_url`).
      debugPrint('🧾 Generate reçu caissier id=$id');
      final gen = await _api.get('/recus/$id/generate');
      if (gen['success'] == true) {
        final ref = DownloadShareHelper.extractExportFileRef(gen['data']);
        if (ref != null && ref.isNotEmpty) {
          final ext = ref.toLowerCase().endsWith('.pdf') ? 'pdf' : 'html';
          final name = 'recu_$id.$ext';
          final ok = await DownloadShareHelper.downloadExportAndShare(
            _api,
            ref,
            name,
          );
          if (ok) {
            AppHelpers.showSuccess('Reçu prêt — enregistrez ou partagez');
            return;
          }
        }
      }

      // 2) Fallback : téléchargement direct.
      debugPrint('🧾 Fallback download reçu caissier id=$id');
      final bytes = await _api.fetchBytes('/recus/$id/download');
      if (bytes == null || bytes.isEmpty) {
        AppHelpers.showError(
            gen['message']?.toString() ?? 'Impossible de télécharger le reçu');
        return;
      }
      final name = 'recu_$id.${_extensionRecu(bytes)}';
      final ok = await DownloadShareHelper.shareBytes(bytes, name);
      if (ok) AppHelpers.showSuccess('Reçu prêt — enregistrez ou partagez');
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Reçus',
        showBack: true,
        showNotification: false,
        showProfile: false,
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _recuDetail != null
              ? _buildRecuDetail()
              : _buildRecuList(),
    );
  }

  Widget _buildRecuDetail() {
    final r = _recuDetail!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // En-tête reçu
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(Icons.school_rounded, size: 40, color: Colors.white),
                const SizedBox(height: 8),
                const Text('ISMGL',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3)),
                const Text('REÇU DE PAIEMENT',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 8),
                Text(r['numero_recu'] ?? '',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Infos étudiant
          _buildSection('Informations Étudiant', [
            _buildInfoRow('N° Étudiant', r['numero_etudiant']),
            _buildInfoRow('Nom Complet', r['nom_complet_etudiant']),
            _buildInfoRow('Filière', r['nom_filiere']),
            _buildInfoRow('Niveau', r['nom_niveau']),
            _buildInfoRow('Année Acad.', r['code_annee']),
          ]),
          const SizedBox(height: 12),

          // Infos paiement
          _buildSection('Détails du Paiement', [
            _buildInfoRow('N° Paiement', r['numero_paiement']),
            _buildInfoRow(
                'Date', AppHelpers.formatDateTime(r['date_paiement'])),
            _buildInfoRow('Type de frais', r['nom_frais']),
            _buildInfoRow('Mode', r['mode_paiement']),
            if (r['reference_transaction'] != null)
              _buildInfoRow('Référence', r['reference_transaction']),
            _buildInfoRow('Reçu par', r['emis_par_nom']),
          ]),
          const SizedBox(height: 16),

          // Montant
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: AppTheme.success.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                const Text('MONTANT PAYÉ',
                    style:
                        TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                const SizedBox(height: 6),
                Text(
                  AppHelpers.formatMontant(
                      double.tryParse(r['montant_total']?.toString() ?? '0') ??
                          0),
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.success),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Bouton générer
          AppButton(
            label: 'Télécharger le reçu',
            onPressed: _isGenerating ? null : () => _genererRecu(r['id_recu']),
            isLoading: _isGenerating,
            icon: Icons.download_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppTheme.primary)),
          const Divider(height: 16),
          ...rows,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 110,
              child: Text(label,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13))),
          Expanded(
              child: Text(value ?? 'N/A',
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildRecuList() {
    if (_recus.isEmpty)
      return const EmptyState(
          message: 'Aucun reçu disponible', icon: Icons.receipt_long_outlined);

    return RefreshIndicator(
      onRefresh: _loadRecentRecus,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _recus.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final p = _recus[i];
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                      color: AppTheme.success.withValues(alpha: 0.1),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.receipt_long_rounded,
                      color: AppTheme.success, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p['nom_complet_etudiant'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(p['numero_paiement'] ?? '',
                          style: const TextStyle(
                              color: AppTheme.primary, fontSize: 12)),
                      Text(AppHelpers.formatDate(p['date_paiement']),
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 11)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      AppHelpers.formatMontant(
                          double.tryParse(p['montant']?.toString() ?? '0') ??
                              0),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: AppTheme.success),
                    ),
                    if (p['numero_recu'] != null)
                      Text(p['numero_recu'],
                          style: const TextStyle(
                              fontSize: 10, color: AppTheme.textSecondary)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
