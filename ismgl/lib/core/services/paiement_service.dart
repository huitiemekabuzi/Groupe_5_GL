import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ismgl/core/services/api_service.dart';

class PaiementService extends GetxService {
  final ApiService _api = Get.find<ApiService>();

  Future<Map<String, dynamic>> getPaiements({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? statut,
    String? dateDebut,
    String? dateFin,
  }) async {
    debugPrint('💳 PaiementService.getPaiements(page=$page)');
    return _api.get(
      '/paiements',
      params: {
        'page': page,
        'page_size': pageSize,
        if (search != null && search.isNotEmpty) 'search': search,
        if (statut != null && statut.isNotEmpty) 'statut': statut,
        if (dateDebut != null && dateDebut.isNotEmpty) 'date_debut': dateDebut,
        if (dateFin != null && dateFin.isNotEmpty) 'date_fin': dateFin,
      },
    );
  }

  Future<Map<String, dynamic>> createPaiement(Map<String, dynamic> body) {
    debugPrint('💳 PaiementService.createPaiement()');
    return _api.post(
      '/paiements',
      data: body,
    );
  }

  Future<Map<String, dynamic>> annuler(int idPaiement, String motif) {
    debugPrint('💳 PaiementService.annuler($idPaiement)');
    return _api.patch(
      '/paiements/$idPaiement/annuler',
      data: {'motif': motif},
    );
  }

  Future<Map<String, dynamic>> getRapportJournalier({String? date}) {
    debugPrint('💳 PaiementService.getRapportJournalier($date)');
    return _api.get(
      '/paiements/journalier',
      params: {
        if (date != null && date.isNotEmpty) 'date': date,
      },
    );
  }
}
