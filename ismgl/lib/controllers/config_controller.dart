import 'package:get/get.dart';
import 'package:ismgl/core/services/config_service.dart';
import 'package:ismgl/core/services/filiere_service.dart';
import 'package:ismgl/core/utils/helpers.dart';
import 'package:ismgl/data/models/annee_academique_model.dart';
import 'package:ismgl/data/models/type_frais_model.dart';
import 'package:ismgl/data/models/faculte_model.dart';
import 'package:ismgl/data/models/departement_model.dart';
import 'package:ismgl/data/models/filiere_model.dart';
import 'package:ismgl/data/models/niveau_model.dart';
import 'package:ismgl/data/models/mode_paiement_model.dart';
import 'package:ismgl/data/models/role_model.dart';
import 'package:ismgl/data/models/permission_model.dart';

class ConfigController extends GetxController {
  final ConfigService  _config  = Get.find<ConfigService>();
  final FiliereService _filieres = Get.find<FiliereService>();

  final isLoading    = true.obs;
  final isSubmitting = false.obs;

  // Listes observables
  final annees        = <AnneeAcademiqueModel>[].obs;
  final typesFrais    = <TypeFraisModel>[].obs;
  final filieres      = <FiliereModel>[].obs;
  final facultes      = <FaculteModel>[].obs;
  final departements  = <DepartementModel>[].obs;
  final niveaux       = <NiveauModel>[].obs;
  final modesPaiement = <ModePaiementModel>[].obs;
  final roles         = <RoleModel>[].obs;
  final permissions   = <PermissionModel>[].obs;

  // Frais scolarité calculés
  final fraisScolarite  = <Map<String, dynamic>>[].obs;
  final montantTotalFrais = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  Future<void> loadAll() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _config.getAnnees(),
        _config.getTypesFrais(),
        _config.getNiveaux(),
        _config.getFacultes(),
        _filieres.getFilieres(),
        _config.getModesPaiement(),
        _config.getRoles(),
      ]);

      annees.assignAll((results[0]['data'] as List<dynamic>?)
              ?.map((e) => AnneeAcademiqueModel.fromJson(e as Map<String, dynamic>))
              .toList() ?? []);
      typesFrais.assignAll((results[1]['data'] as List<dynamic>?)
              ?.map((e) => TypeFraisModel.fromJson(e as Map<String, dynamic>))
              .toList() ?? []);
      niveaux.assignAll((results[2]['data'] as List<dynamic>?)
              ?.map((e) => NiveauModel.fromJson(e as Map<String, dynamic>))
              .toList() ?? []);
      facultes.assignAll((results[3]['data'] as List<dynamic>?)
              ?.map((e) => FaculteModel.fromJson(e as Map<String, dynamic>))
              .toList() ?? []);
      filieres.assignAll((results[4]['data'] as List<dynamic>?)
              ?.map((e) => FiliereModel.fromJson(e as Map<String, dynamic>))
              .toList() ?? []);
      modesPaiement.assignAll((results[5]['data'] as List<dynamic>?)
              ?.map((e) => ModePaiementModel.fromJson(e as Map<String, dynamic>))
              .toList() ?? []);
      roles.assignAll((results[6]['data'] as List<dynamic>?)
              ?.map((e) => RoleModel.fromJson(e as Map<String, dynamic>))
              .toList() ?? []);
    } catch (e) {
      AppHelpers.showError('Erreur chargement configuration: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Années ─────────────────────────────────────────────────────────────────
  Future<bool> createAnnee(Map<String, dynamic> data) async {
    isSubmitting.value = true;
    try {
      final result = await _config.createAnnee(data);
      if (result['success'] == true) {
        AppHelpers.showSuccess('Année créée');
        await loadAll();
        return true;
      }
      AppHelpers.showError(result['message'] ?? 'Erreur');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> setAnneeCourante(int id) async {
    final result = await _config.setAnneeCourante(id);
    if (result['success'] == true) {
      AppHelpers.showSuccess('Année définie comme courante');
      await loadAll();
    } else {
      AppHelpers.showError(result['message'] ?? 'Erreur');
    }
  }

  Future<void> cloturerAnnee(int id) async {
    final confirm = await AppHelpers.showConfirmDialog(
      title:       'Clôturer l\'année',
      message:     'Cette action est irréversible. Confirmer ?',
      confirmText: 'Clôturer',
    );
    if (!confirm) return;
    final result = await _config.cloturerAnnee(id);
    if (result['success'] == true) {
      AppHelpers.showSuccess('Année clôturée');
      await loadAll();
    } else {
      AppHelpers.showError(result['message'] ?? 'Erreur');
    }
  }

  // ── Types de frais ─────────────────────────────────────────────────────────
  Future<bool> createTypeFrais(Map<String, dynamic> data) async {
    isSubmitting.value = true;
    try {
      final result = await _config.createTypeFrais(data);
      if (result['success'] == true) {
        AppHelpers.showSuccess('Type de frais créé');
        await loadAll();
        return true;
      }
      AppHelpers.showError(result['message'] ?? 'Erreur');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // ── Filières ───────────────────────────────────────────────────────────────
  Future<bool> createFiliere(Map<String, dynamic> data) async {
    isSubmitting.value = true;
    try {
      final result = await _filieres.createFiliere(data);
      if (result['success'] == true) {
        AppHelpers.showSuccess('Filière créée');
        await loadAll();
        return true;
      }
      AppHelpers.showError(result['message'] ?? 'Erreur');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // ── Facultés ───────────────────────────────────────────────────────────────
  Future<bool> createFaculte(Map<String, dynamic> data) async {
    isSubmitting.value = true;
    try {
      final result = await _config.createFaculte(data);
      if (result['success'] == true) {
        AppHelpers.showSuccess('Faculté créée');
        await loadAll();
        return true;
      }
      AppHelpers.showError(result['message'] ?? 'Erreur');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // ── Frais scolarité ────────────────────────────────────────────────────────
  Future<void> loadFraisScolarite({
    required int idFiliere,
    required int idNiveau,
    required int idAnneeAcademique,
  }) async {
    isLoading.value = true;
    try {
      final result = await _config.getFraisScolarite(
        idFiliere:         idFiliere,
        idNiveau:          idNiveau,
        idAnneeAcademique: idAnneeAcademique,
      );
      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>;
        fraisScolarite.assignAll(
            (data['frais'] as List<dynamic>).cast<Map<String, dynamic>>());
        montantTotalFrais.value =
            double.tryParse(data['montant_total']?.toString() ?? '0') ?? 0;
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ── Getters pratiques ──────────────────────────────────────────────────────
  AnneeAcademiqueModel? get anneeCourante =>
      annees.firstWhereOrNull((a) => a.estCourante);
}
