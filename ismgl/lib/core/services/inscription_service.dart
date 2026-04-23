import 'package:get/get.dart';
import 'package:ismgl/core/services/api_service.dart';

class InscriptionService extends GetxService {
  final ApiService _api = Get.find<ApiService>();

  /// Liste paginée des inscriptions.
  Future<Map<String, dynamic>> getInscriptions({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? statut,
    String? type,
    int? idAnneeAcademique,
    int? idFiliere,
    int? idNiveau,
  }) async {
    return _api.get('/inscriptions', params: {
      'page':      page,
      'page_size': pageSize,
      if (search  != null && search.isNotEmpty) 'search': search,
      if (statut  != null) 'statut':           statut,
      if (type    != null) 'type':             type,
      if (idAnneeAcademique != null) 'annee_academique': idAnneeAcademique,
      if (idFiliere         != null) 'filiere':          idFiliere,
      if (idNiveau          != null) 'niveau':           idNiveau,
    });
  }

  /// Créer une inscription.
  Future<Map<String, dynamic>> createInscription(Map<String, dynamic> data) async {
    return _api.post('/inscriptions', data: data);
  }

  /// Valider une inscription.
  Future<Map<String, dynamic>> valider(int id) async {
    return _api.patch('/inscriptions/$id/valider');
  }

  /// Rejeter une inscription.
  Future<Map<String, dynamic>> rejeter(int id, String motif) async {
    return _api.patch('/inscriptions/$id/rejeter', data: {'motif': motif});
  }

  /// Mes inscriptions (étudiant connecté).
  Future<Map<String, dynamic>> getMesInscriptions() async {
    return _api.get('/inscriptions/me');
  }

  /// Frais calculés pour une combinaison filière/niveau/année.
  Future<Map<String, dynamic>> getFraisScolarite({
    required int idFiliere,
    required int idNiveau,
    required int idAnneeAcademique,
  }) async {
    return _api.get('/config/frais-scolarite', params: {
      'filiere': idFiliere,
      'niveau':  idNiveau,
      'annee':   idAnneeAcademique,
    });
  }
}
