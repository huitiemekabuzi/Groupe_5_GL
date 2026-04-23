import 'package:get/get.dart';
import 'package:ismgl/core/services/api_service.dart';

class ConfigService extends GetxService {
  final ApiService _api = Get.find<ApiService>();

  // ── Années académiques ─────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getAnnees() => _api.get('/config/annees');

  Future<Map<String, dynamic>> createAnnee(Map<String, dynamic> data) =>
      _api.post('/config/annees', data: data);

  Future<Map<String, dynamic>> setAnneeCourante(int id) =>
      _api.patch('/config/annees/$id/courante');

  Future<Map<String, dynamic>> cloturerAnnee(int id) =>
      _api.patch('/config/annees/$id/cloturer');

  // ── Types de frais ─────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getTypesFrais() => _api.get('/config/types-frais');

  Future<Map<String, dynamic>> createTypeFrais(Map<String, dynamic> data) =>
      _api.post('/config/types-frais', data: data);

  // ── Frais de scolarité ─────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getFraisScolarite({
    int? idFiliere,
    int? idNiveau,
    int? idAnneeAcademique,
  }) =>
      _api.get('/config/frais-scolarite', params: {
        if (idFiliere          != null) 'filiere': idFiliere,
        if (idNiveau           != null) 'niveau':  idNiveau,
        if (idAnneeAcademique  != null) 'annee':   idAnneeAcademique,
      });

  Future<Map<String, dynamic>> createFraisScolarite(Map<String, dynamic> data) =>
      _api.post('/config/frais-scolarite', data: data);

  // ── Niveaux ────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getNiveaux() => _api.get('/config/niveaux');

  // ── Facultés ───────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getFacultes() => _api.get('/config/facultes');

  Future<Map<String, dynamic>> createFaculte(Map<String, dynamic> data) =>
      _api.post('/config/facultes', data: data);

  // ── Départements ───────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getDepartements({int? idFaculte}) =>
      _api.get('/config/departements', params: {
        if (idFaculte != null) 'faculte': idFaculte,
      });

  Future<Map<String, dynamic>> createDepartement(Map<String, dynamic> data) =>
      _api.post('/config/departements', data: data);

  // ── Modes de paiement ──────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getModesPaiement() =>
      _api.get('/config/modes-paiement');

  // ── Rôles & Permissions ────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getRoles() => _api.get('/config/roles');

  Future<Map<String, dynamic>> getRolePermissions(int idRole) =>
      _api.get('/config/roles/$idRole/permissions');

  Future<Map<String, dynamic>> setRolePermissions(
    int idRole,
    List<int> idPermissions,
  ) =>
      _api.post('/config/roles/$idRole/permissions',
          data: {'permissions': idPermissions});

  Future<Map<String, dynamic>> getPermissions() =>
      _api.get('/config/permissions');
}
