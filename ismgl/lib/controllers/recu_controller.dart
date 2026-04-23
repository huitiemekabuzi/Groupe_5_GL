import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:ismgl/core/services/api_service.dart';
import 'package:ismgl/core/services/recu_service.dart';
import 'package:ismgl/core/utils/download_share_helper.dart';
import 'package:ismgl/core/utils/helpers.dart';
import 'package:ismgl/data/models/recu_model.dart';

class RecuController extends GetxController {
  final RecuService _service = Get.find<RecuService>();

  final isLoading   = false.obs;
  final isGenerating = false.obs;
  final selectedRecu = Rxn<RecuModel>();
  final pdfUrl       = Rxn<String>();

  Future<void> loadRecu(int id) async {
    isLoading.value = true;
    try {
      final result = await _service.getRecu(id);
      if (result['success'] == true) {
        selectedRecu.value =
            RecuModel.fromJson(result['data'] as Map<String, dynamic>);
      } else {
        AppHelpers.showError(result['message'] ?? 'Reçu introuvable');
      }
    } catch (e) {
      AppHelpers.showError('Erreur réseau: $e');
    } finally {
      isLoading.value = false;
    }
  }

  static String _extensionRecu(Uint8List bytes) {
    if (bytes.length >= 4 &&
        bytes[0] == 0x25 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x44 &&
        bytes[3] == 0x46) {
      return 'pdf';
    }
    return 'html';
  }

  /// Télécharge le reçu (HTML/PDF) depuis l’API puis ouvre le partage système.
  Future<void> downloadRecu(int id) async {
    isGenerating.value = true;
    try {
      final api = Get.find<ApiService>();

      // 1) Génération (retourne souvent une URL de fichier HTML/PDF).
      final gen = await _service.generateRecu(id);
      if (gen['success'] == true) {
        final ref = DownloadShareHelper.extractExportFileRef(gen['data']);
        if (ref != null && ref.isNotEmpty) {
          final ext = ref.toLowerCase().endsWith('.pdf') ? 'pdf' : 'html';
          final name = 'recu_$id.$ext';
          final ok =
              await DownloadShareHelper.downloadExportAndShare(api, ref, name);
          if (ok) {
            pdfUrl.value = ref;
            AppHelpers.showSuccess('Reçu prêt — enregistrez ou partagez');
            return;
          }
        }
      }

      // 2) Fallback : téléchargement direct.
      final bytes = await api.fetchBytes('/recus/$id/download');
      if (bytes == null || bytes.isEmpty) {
        AppHelpers.showError(gen['message']?.toString() ?? 'Impossible de télécharger le reçu');
        return;
      }
      final name = 'recu_$id.${_extensionRecu(bytes)}';
      final ok = await DownloadShareHelper.shareBytes(bytes, name);
      if (ok) {
        pdfUrl.value = name;
        AppHelpers.showSuccess('Reçu prêt — enregistrez ou partagez');
      }
    } finally {
      isGenerating.value = false;
    }
  }

  String getDownloadUrl(int id) => _service.getDownloadUrl(id);
}
