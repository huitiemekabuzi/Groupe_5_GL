import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ismgl/core/services/api_service.dart';

class RapportService extends GetxService {
  final ApiService _api = Get.find<ApiService>();

  Future<Map<String, dynamic>> getStatistiques({int? idAnnee}) {
    debugPrint('📊 RapportService.getStatistiques($idAnnee)');
    return _api.get(
      '/rapports/statistiques',
      params: {if (idAnnee != null) 'annee': idAnnee},
    );
  }

  Future<Map<String, dynamic>> getFinancier({int? idAnnee}) {
    debugPrint('📊 RapportService.getFinancier($idAnnee)');
    return _api.get(
      '/rapports/financier',
      params: {if (idAnnee != null) 'annee': idAnnee},
    );
  }

  Future<Map<String, dynamic>> getImpayes({int? idAnnee}) {
    debugPrint('📊 RapportService.getImpayes($idAnnee)');
    return _api.get(
      '/rapports/impayes',
      params: {if (idAnnee != null) 'annee': idAnnee},
    );
  }

  Future<Map<String, dynamic>> getFilieres({int? idAnnee}) {
    debugPrint('📊 RapportService.getFilieres($idAnnee)');
    return _api.get(
      '/rapports/filieres',
      params: {if (idAnnee != null) 'annee': idAnnee},
    );
  }

  Future<Map<String, dynamic>> getJournalier({String? date}) {
    debugPrint('📊 RapportService.getJournalier($date)');
    return _api.get(
      '/rapports/journalier',
      params: {if (date != null && date.isNotEmpty) 'date': date},
    );
  }

  Future<Map<String, dynamic>> getSituationEtudiant(int idEtudiant, {int? idAnnee}) {
    debugPrint('📊 RapportService.getSituationEtudiant($idEtudiant)');
    return _api.get(
      '/rapports/etudiant/$idEtudiant',
      params: {if (idAnnee != null) 'annee': idAnnee},
    );
  }

  Future<Map<String, dynamic>> exportPDF({required String type}) {
    debugPrint('📊 RapportService.exportPDF($type)');
    return _api.get('/rapports/export/pdf', params: {'type': type});
  }

  Future<Map<String, dynamic>> getLogs({
    String? module,
    String? dateDebut,
    int page = 1,
    int pageSize = 20,
  }) {
    debugPrint('📊 RapportService.getLogs(page=$page, module=$module)');
    return _api.get(
      '/rapports/logs',
      params: {
        'page': page,
        'page_size': pageSize,
        if (module != null && module.isNotEmpty) 'module': module,
        if (dateDebut != null && dateDebut.isNotEmpty) 'date_debut': dateDebut,
      },
    );
  }
}
