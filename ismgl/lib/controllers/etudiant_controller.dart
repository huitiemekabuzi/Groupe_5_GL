import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ismgl/core/services/etudiant_service.dart';
import 'package:ismgl/core/utils/helpers.dart';
import 'package:ismgl/data/models/etudiant_model.dart';
import 'package:ismgl/data/responses/paginated_response.dart';

class EtudiantController extends GetxController {
  final EtudiantService _service = Get.find<EtudiantService>();

  final isLoading     = false.obs;
  final isSubmitting  = false.obs;
  final etudiants     = <EtudiantModel>[].obs;
  final selectedEtudiant = Rxn<EtudiantModel>();
  final totalItems    = 0.obs;
  final currentPage   = 1.obs;
  final totalPages    = 1.obs;

  final search        = ''.obs;
  final filterStatut  = Rxn<String>();
  final filterSexe    = Rxn<String>();

  // Profil étudiant connecté (rôle Etudiant)
  final monProfil     = Rxn<EtudiantModel>();

  static const int _pageSize = 20;

  @override
  void onInit() {
    super.onInit();
    debugPrint('🟢 EtudiantController.onInit()');
    loadEtudiants();
  }

  Future<void> loadEtudiants({bool reset = false}) async {
    if (reset) {
      currentPage.value = 1;
      etudiants.clear();
    }
    
    debugPrint('\n📥 EtudiantController.loadEtudiants()');
    debugPrint('   Page: ${currentPage.value}');
    debugPrint('   Search: ${search.value}');
    debugPrint('   Statut: ${filterStatut.value}');
    debugPrint('   Sexe: ${filterSexe.value}');
    
    isLoading.value = true;
    try {
      final result = await _service.getEtudiants(
        page:     currentPage.value,
        pageSize: _pageSize,
        search:   search.value.isEmpty ? null : search.value,
        statut:   filterStatut.value,
        sexe:     filterSexe.value,
      );
      
      debugPrint('   Response success: ${result['success']}');
      
      if (result['success'] == true) {
        final data = result['data'];
        debugPrint('   Data: $data');
        
        final resp = PaginatedResponse.fromJson(
          data as Map<String, dynamic>,
          (j) => EtudiantModel.fromJson(j),
        );
        
        debugPrint('   Parsed items: ${resp.items.length}');
        
        if (reset || currentPage.value == 1) {
          etudiants.assignAll(resp.items);
        } else {
          etudiants.addAll(resp.items);
        }
        totalItems.value = resp.totalItems;
        totalPages.value = resp.totalPages;
        
        debugPrint('   ✅ Total items: ${totalItems.value}, Pages: ${totalPages.value}');
      } else {
        debugPrint('   ❌ Error: ${result['message']}');
        AppHelpers.showError(result['message'] ?? 'Erreur lors du chargement');
      }
    } catch (e) {
      debugPrint('   ❌ Exception: $e');
      AppHelpers.showError('Erreur réseau: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMonProfil() async {
    debugPrint('\n📥 EtudiantController.loadMonProfil()');
    isLoading.value = true;
    try {
      final result = await _service.getMe();
      if (result['success'] == true) {
        monProfil.value = EtudiantModel.fromJson(
            result['data'] as Map<String, dynamic>);
        debugPrint('   ✅ Profile loaded: ${monProfil.value?.nom}');
      }
    } catch (e) {
      debugPrint('   ❌ Exception: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadDetail(int id) async {
    debugPrint('\n📥 EtudiantController.loadDetail($id)');
    isLoading.value = true;
    try {
      final result = await _service.getEtudiant(id);
      if (result['success'] == true) {
        selectedEtudiant.value = EtudiantModel.fromJson(
            result['data'] as Map<String, dynamic>);
        debugPrint('   ✅ Detail loaded: ${selectedEtudiant.value?.nom}');
      }
    } catch (e) {
      debugPrint('   ❌ Exception: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createEtudiant(
    Map<String, dynamic> data, {
    String? photoProfilPath,
    String? photoIdentitePath,
  }) async {
    debugPrint('\n📤 EtudiantController.createEtudiant()');
    debugPrint('   Data: $data');
    
    isSubmitting.value = true;
    try {
      final result = await _service.createEtudiant(
        data,
        photoProfilPath:   photoProfilPath,
        photoIdentitePath: photoIdentitePath,
      );
      
      if (result['success'] == true) {
        debugPrint('   ✅ Étudiant créé avec succès');
        AppHelpers.showSuccess('Étudiant créé avec succès');
        await loadEtudiants(reset: true);
        return true;
      } else {
        debugPrint('   ❌ Erreur: ${result['message']}');
        AppHelpers.showError(result['message'] ?? 'Erreur création');
        return false;
      }
    } catch (e) {
      debugPrint('   ❌ Exception: $e');
      AppHelpers.showError('Erreur: $e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> updateStatut(EtudiantModel etudiant, String statut) async {
    debugPrint('\n📤 EtudiantController.updateStatut(${etudiant.idEtudiant}, $statut)');
    
    isSubmitting.value = true;
    try {
      final result = await _service.updateStatut(etudiant.idEtudiant, statut);
      if (result['success'] == true) {
        debugPrint('   ✅ Statut mis à jour avec succès');
        AppHelpers.showSuccess('Statut mis à jour');
        await loadEtudiants(reset: true);
      } else {
        debugPrint('   ❌ Erreur: ${result['message']}');
        AppHelpers.showError(result['message'] ?? 'Erreur');
      }
    } catch (e) {
      debugPrint('   ❌ Exception: $e');
      AppHelpers.showError('Erreur: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  void onSearch(String value) {
    debugPrint('🔍 Search: $value');
    search.value = value;
    if (value.length >= 3 || value.isEmpty) loadEtudiants(reset: true);
  }

  void setFilterStatut(String? statut) {
    debugPrint('🏷️ Filter statut: $statut');
    filterStatut.value = statut;
    loadEtudiants(reset: true);
  }

  void setFilterSexe(String? sexe) {
    debugPrint('🏷️ Filter sexe: $sexe');
    filterSexe.value = sexe;
    loadEtudiants(reset: true);
  }

  void loadMore() {
    if (currentPage.value < totalPages.value && !isLoading.value) {
      debugPrint('📥 Load more page: ${currentPage.value + 1}');
      currentPage.value++;
      loadEtudiants();
    }
  }
}
