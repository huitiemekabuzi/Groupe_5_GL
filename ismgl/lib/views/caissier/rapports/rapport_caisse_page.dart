import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ismgl/app/themes/app_theme.dart';
import 'package:ismgl/core/services/api_service.dart';
import 'package:ismgl/core/utils/download_share_helper.dart';
import 'package:ismgl/core/utils/helpers.dart';
import 'package:ismgl/views/shared/widgets/custom_app_bar.dart';
import 'package:ismgl/views/shared/widgets/loading_widget.dart';

class RapportCaissePage extends StatefulWidget {
  const RapportCaissePage({super.key});

  @override
  State<RapportCaissePage> createState() => _RapportCaissePageState();
}

class _RapportCaissePageState extends State<RapportCaissePage> {
  final ApiService _api = Get.find<ApiService>();

  bool _isLoading = true;
  bool _isExporting = false;
  Map<String, dynamic>? _data;

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final result = await _api.get('/rapports/journalier');
      if (result['success'] == true) {
        setState(() => _data = result['data'] as Map<String, dynamic>?);
      } else {
        AppHelpers.showError(result['message'] ?? 'Erreur chargement rapport');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _export(String format) async {
    setState(() => _isExporting = true);
    try {
      final endpoint = switch (format) {
        'excel' => '/rapports/export/excel',
        'csv' => '/rapports/export/csv',
        _ => '/rapports/export/pdf',
      };
      final ext = switch (format) {
        'excel' => 'xlsx',
        'csv' => 'csv',
        _ => 'pdf',
      };

      // Caisse: rapport des paiements.
      final result = await _api.get(endpoint, params: {'type': 'paiements'});
      if (result['success'] != true) {
        AppHelpers.showError(result['message'] ?? 'Erreur export');
        return;
      }

      final ref = DownloadShareHelper.extractExportFileRef(result['data']);
      if (ref == null || ref.isEmpty) {
        AppHelpers.showError('Lien du fichier non reçu par l’API');
        return;
      }

      final name = DownloadShareHelper.exportFilename('caisse_jour', ext);
      final ok = await DownloadShareHelper.downloadExportAndShare(_api, ref, name);
      if (ok) {
        AppHelpers.showSuccess('Fichier prêt — enregistrez ou partagez');
      } else {
        AppHelpers.showError('Échec du téléchargement');
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final details = (_data?['details'] as List?) ?? [];
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Rapport de caisse',
        showBack: true,
        showNotification: false,
        showProfile: false,
        actions: [
          if (_isExporting)
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            PopupMenuButton<String>(
              icon: const Icon(Icons.download_outlined),
              onSelected: _export,
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'pdf', child: Text('Exporter PDF')),
                PopupMenuItem(value: 'csv', child: Text('Exporter CSV')),
                PopupMenuItem(value: 'excel', child: Text('Exporter Excel')),
              ],
            ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Chargement du rapport…')
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Rapport du jour', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 6),
                      Text(
                        AppHelpers.formatMontant(double.tryParse(_data?['montant_total']?.toString() ?? '0') ?? 0),
                        style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_data?['nombre_transactions'] ?? 0} transaction(s)',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (details.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: Text('Aucune donnée', style: TextStyle(color: AppTheme.textSecondary)),
                    ),
                  )
                else
                  ...details.map((d) {
                    final montant = double.tryParse(d['montant_total']?.toString() ?? '0') ?? 0;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              d['nom_mode'] ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${d['nombre_transactions'] ?? 0} tx',
                                style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                              ),
                              Text(
                                AppHelpers.formatMontant(montant),
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.success),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
    );
  }
}

