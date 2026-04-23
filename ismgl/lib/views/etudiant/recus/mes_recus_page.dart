import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ismgl/app/themes/app_theme.dart';
import 'package:ismgl/core/services/api_service.dart';
import 'package:ismgl/core/utils/download_share_helper.dart';
import 'package:ismgl/core/utils/helpers.dart';
import 'package:ismgl/views/shared/widgets/custom_app_bar.dart';
import 'package:ismgl/views/shared/widgets/empty_state.dart';
import 'package:ismgl/views/shared/widgets/loading_widget.dart';

class MesRecusPage extends StatefulWidget {
  const MesRecusPage({super.key});

  @override
  State<MesRecusPage> createState() => _MesRecusPageState();
}

class _MesRecusPageState extends State<MesRecusPage> {
  final ApiService _api = Get.find<ApiService>();

  List<dynamic> _recus = [];
  bool _isLoading = true;
  int? _busyRecuId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final result = await _api.get('/recus/me');
    if (result['success'] == true) {
      setState(() => _recus = (result['data'] as List?) ?? []);
    }
    setState(() => _isLoading = false);
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

  Future<void> _telechargerRecu(dynamic idRaw, String? numeroRecu) async {
    final id = idRaw is int ? idRaw : int.tryParse('$idRaw');
    if (id == null) return;

    setState(() => _busyRecuId = id);
    try {
      final safeNum =
          (numeroRecu ?? 'recu').replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');

      // 1) Génération (retourne souvent un fichier HTML dans `pdf_url`).
      debugPrint('🧾 Generate reçu id=$id');
      final gen = await _api.get('/recus/$id/generate');
      if (gen['success'] == true) {
        final ref = DownloadShareHelper.extractExportFileRef(gen['data']);
        if (ref != null && ref.isNotEmpty) {
          final ext = ref.toLowerCase().endsWith('.pdf') ? 'pdf' : 'html';
          final name = '$safeNum.$ext';
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
      debugPrint('🧾 Fallback download reçu id=$id');
      final bytes = await _api.fetchBytes('/recus/$id/download');
      if (bytes == null || bytes.isEmpty) {
        AppHelpers.showError(
          gen['message']?.toString() ??
              'Impossible de télécharger le reçu (réponse vide ou accès refusé)',
        );
        return;
      }
      final name = '$safeNum.${_extensionRecu(bytes)}';
      final ok = await DownloadShareHelper.shareBytes(bytes, name);
      if (ok) AppHelpers.showSuccess('Reçu prêt — enregistrez ou partagez');
    } finally {
      if (mounted) setState(() => _busyRecuId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Mes Reçus',
        showBack: true,
        showNotification: false,
        showProfile: false,
      ),
      body: _isLoading
          ? const LoadingWidget()
          : RefreshIndicator(
              onRefresh: _load,
              child: _recus.isEmpty
                  ? const EmptyState(message: 'Aucun reçu disponible', icon: Icons.receipt_long_outlined)
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _recus.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _buildCard(_recus[i]),
                    ),
            ),
    );
  }

  Widget _buildCard(Map<String, dynamic> r) {
    final idRecu = r['id_recu'];
    final busy = _busyRecuId != null &&
        idRecu != null &&
        _busyRecuId == (idRecu is int ? idRecu : int.tryParse('$idRecu'));

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(r['numero_recu'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary, fontSize: 15)),
                Text(
                  AppHelpers.formatMontant(double.tryParse(r['montant_total']?.toString() ?? '0') ?? 0),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.success, fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(r['nom_frais'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 14, color: AppTheme.textSecondary),
                const SizedBox(width: 6),
                Text(AppHelpers.formatDate(r['date_emission']), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                const Spacer(),
                const Icon(Icons.payment, size: 14, color: AppTheme.textSecondary),
                const SizedBox(width: 6),
                Text(r['nom_mode'] ?? '', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: busy
                  ? null
                  : () => _telechargerRecu(
                        idRecu,
                        r['numero_recu']?.toString(),
                      ),
              icon: busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download_outlined, size: 16),
              label: Text(
                busy ? 'Préparation…' : 'Télécharger le reçu',
                style: const TextStyle(fontSize: 12),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primary,
                side: const BorderSide(color: AppTheme.primary),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}