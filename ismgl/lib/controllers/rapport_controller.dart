import 'package:get/get.dart';
import 'package:ismgl/core/services/api_service.dart';
import 'package:ismgl/core/services/rapport_service.dart';
import 'package:ismgl/core/utils/download_share_helper.dart';
import 'package:ismgl/core/utils/helpers.dart';
import 'package:ismgl/data/responses/rapport_response.dart';

class RapportController extends GetxController {
  final RapportService _service = Get.find<RapportService>();

  final isLoading    = true.obs;
  final isExporting  = false.obs;

  final stats         = Rxn<RapportStatistiques>();
  final financier     = Rxn<RapportFinancier>();
  final impayes       = Rxn<RapportImpaye>();
  final filieres      = <RapportFiliere>[].obs;
  final journalier    = <RapportJournalierDetail>[].obs;
  final logsItems     = <Map<String, dynamic>>[].obs;

  // Situation étudiant
  final situationEtudiant = Rxn<Map<String, dynamic>>();
  final paiementsEtudiant = <Map<String, dynamic>>[].obs;

  // Export
  final pdfUrl = Rxn<String>();

  int? _idAnnee;

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  Future<void> loadAll({int? idAnnee}) async {
    _idAnnee = idAnnee;
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _service.getStatistiques(idAnnee: idAnnee),
        _service.getFinancier(idAnnee: idAnnee),
        _service.getImpayes(idAnnee: idAnnee),
        _service.getFilieres(idAnnee: idAnnee),
        _service.getJournalier(),
      ]);

      if (results[0]['data'] != null) {
        stats.value = RapportStatistiques.fromJson(
            results[0]['data'] as Map<String, dynamic>);
      }
      if (results[1]['data'] != null) {
        financier.value = RapportFinancier.fromJson(
            results[1]['data'] as Map<String, dynamic>);
      }
      if (results[2]['data'] != null) {
        impayes.value = RapportImpaye.fromJson(
            results[2]['data'] as Map<String, dynamic>);
      }
      filieres.assignAll((results[3]['data'] as List<dynamic>?)
              ?.map((e) => RapportFiliere.fromJson(e as Map<String, dynamic>))
              .toList() ?? []);

      final journalierData = results[4]['data'] as Map<String, dynamic>?;
      journalier.assignAll(
        (journalierData?['details'] as List<dynamic>?)
                ?.map((e) => RapportJournalierDetail.fromJson(
                    e as Map<String, dynamic>))
                .toList() ?? [],
      );
    } catch (e) {
      AppHelpers.showError('Erreur chargement rapports: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadSituationEtudiant(int idEtudiant) async {
    isLoading.value = true;
    try {
      final result = await _service.getSituationEtudiant(idEtudiant,
          idAnnee: _idAnnee);
      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>;
        situationEtudiant.value =
            data['inscription'] as Map<String, dynamic>?;
        paiementsEtudiant.assignAll(
            (data['paiements'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>() ?? []);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> exportPDF(String type) async {
    isExporting.value = true;
    try {
      final api = Get.find<ApiService>();
      final result = await _service.exportPDF(type: type);
      if (result['success'] != true) {
        AppHelpers.showError(
          result['message']?.toString() ?? 'Erreur export PDF',
        );
        return;
      }
      final ref = DownloadShareHelper.extractExportFileRef(result['data']);
      if (ref == null || ref.isEmpty) {
        AppHelpers.showError('Lien du fichier non reçu');
        return;
      }
      final name = DownloadShareHelper.exportFilename(type, 'pdf');
      final ok =
          await DownloadShareHelper.downloadExportAndShare(api, ref, name);
      if (ok) {
        pdfUrl.value = ref;
        AppHelpers.showSuccess('Fichier prêt — enregistrez ou partagez');
      } else {
        AppHelpers.showError('Échec du téléchargement du rapport');
      }
    } finally {
      isExporting.value = false;
    }
  }

  Future<void> loadLogs({String? module}) async {
    isLoading.value = true;
    try {
      final result = await _service.getLogs(module: module);
      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>;
        logsItems.assignAll(
            (data['items'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>() ?? []);
      }
    } finally {
      isLoading.value = false;
    }
  }
}
