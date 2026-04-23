import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ismgl/core/services/inscription_service.dart';
import 'package:ismgl/core/utils/helpers.dart';
import 'package:ismgl/data/models/inscription_model.dart';
import 'package:ismgl/data/responses/paginated_response.dart';

class InscriptionController extends GetxController {
  final InscriptionService _service = Get.find<InscriptionService>();

  final isLoading     = false.obs;
  final isSubmitting  = false.obs;
  final inscriptions  = <InscriptionModel>[].obs;
  final selectedInscription = Rxn<InscriptionModel>();
  final totalItems    = 0.obs;
  final currentPage   = 1.obs;
  final totalPages    = 1.obs;

  final search        = ''.obs;
  final filterStatut  = Rxn<String>();

  // Frais calculés pour le formulaire d'inscription
  final fraisListe    = <Map<String, dynamic>>[].obs;
  final montantTotal  = 0.0.obs;
  final isLoadingFrais = false.obs;

  // Mes inscriptions (étudiant)
  final mesInscriptions = <InscriptionModel>[].obs;

  static const int _pageSize = 20;

  @override
  void onInit() {
    super.onInit();
    debugPrint('🟢 InscriptionController.onInit()');
    loadInscriptions();
  }

  Future<void> loadInscriptions({bool reset = false}) async {
    if (reset) {
      currentPage.value = 1;
      inscriptions.clear();
    }
    
    debugPrint('\n📥 InscriptionController.loadInscriptions()');
    debugPrint('   Page: ${currentPage.value}');
    debugPrint('   Search: ${search.value}');
    debugPrint('   Statut: ${filterStatut.value}');
    
    isLoading.value = true;
    try {
      final result = await _service.getInscriptions(
        page:     currentPage.value,
        pageSize: _pageSize,
        search:   search.value.isEmpty ? null : search.value,
        statut:   filterStatut.value,
      );
      
      debugPrint('   Response success: ${result['success']}');
      
      if (result['success'] == true) {
        final data = result['data'];
        debugPrint('   Data keys: ${(data as Map).keys}');
        
        final resp = PaginatedResponse.fromJson(
          data as Map<String, dynamic>,
          (j) => InscriptionModel.fromJson(j),
        );
        
        debugPrint('   Parsed items: ${resp.items.length}');
        
        if (reset || currentPage.value == 1) {
          inscriptions.assignAll(resp.items);
        } else {
          inscriptions.addAll(resp.items);
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

  Future<void> loadMesInscriptions() async {
    debugPrint('\n📥 InscriptionController.loadMesInscriptions()');
    isLoading.value = true;
    try {
      final result = await _service.getMesInscriptions();
      if (result['success'] == true) {
        final list = (result['data'] as List<dynamic>)
            .map((e) => InscriptionModel.fromJson(e as Map<String, dynamic>))
            .toList();
        mesInscriptions.assignAll(list);
        debugPrint('   ✅ Inscriptions loaded: ${list.length}');
      }
    } catch (e) {
      debugPrint('   ❌ Exception: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadFrais({
    required int idFiliere,
    required int idNiveau,
    required int idAnneeAcademique,
  }) async {
    debugPrint('\n📥 InscriptionController.loadFrais()');
    debugPrint('   idFiliere: $idFiliere, idNiveau: $idNiveau, idAnneeAcademique: $idAnneeAcademique');
    
    isLoadingFrais.value = true;
    try {
      final result = await _service.getFraisScolarite(
        idFiliere:          idFiliere,
        idNiveau:           idNiveau,
        idAnneeAcademique:  idAnneeAcademique,
      );
      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>;
        fraisListe.assignAll(
            (data['frais'] as List<dynamic>).cast<Map<String, dynamic>>());
        montantTotal.value =
            double.tryParse(data['montant_total']?.toString() ?? '0') ?? 0;
        debugPrint('   ✅ Frais loaded: ${fraisListe.length}, Montant total: ${montantTotal.value}');
      }
    } catch (e) {
      debugPrint('   ❌ Exception: $e');
    } finally {
      isLoadingFrais.value = false;
    }
  }

  Future<bool> createInscription(Map<String, dynamic> data) async {
    debugPrint('\n📤 InscriptionController.createInscription()');
    debugPrint('   Data: $data');
    
    isSubmitting.value = true;
    try {
      final result = await _service.createInscription(data);
      if (result['success'] == true) {
        debugPrint('   ✅ Inscription créée avec succès');
        AppHelpers.showSuccess('Inscription enregistrée avec succès');
        await loadInscriptions(reset: true);
        return true;
      } else {
        debugPrint('   ❌ Erreur: ${result['message']}');
        AppHelpers.showError(result['message'] ?? 'Erreur inscription');
        return false;
      }
    } catch (e) {
      debugPrint('   ❌ Exception: $e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> valider(InscriptionModel ins) async {
    debugPrint('\n📤 InscriptionController.valider(${ins.idInscription})');
    
    final confirm = await AppHelpers.showConfirmDialog(
      title:       'Valider inscription',
      message:     'Valider l\'inscription de ${ins.nomCompletDisplay} ?',
      confirmText: 'Valider',
    );
    if (!confirm) return;
    
    final result = await _service.valider(ins.idInscription);
    if (result['success'] == true) {
      debugPrint('   ✅ Inscription validée');
      AppHelpers.showSuccess('Inscription validée');
      await loadInscriptions(reset: true);
    } else {
      debugPrint('   ❌ Erreur: ${result['message']}');
      AppHelpers.showError(result['message'] ?? 'Erreur');
    }
  }

  Future<void> rejeter(InscriptionModel ins, String motif) async {
    debugPrint('\n📤 InscriptionController.rejeter(${ins.idInscription})');
    debugPrint('   Motif: $motif');
    
    final result = await _service.rejeter(ins.idInscription, motif);
    if (result['success'] == true) {
      debugPrint('   ✅ Inscription rejetée');
      AppHelpers.showSuccess('Inscription rejetée');
      await loadInscriptions(reset: true);
    } else {
      debugPrint('   ❌ Erreur: ${result['message']}');
      AppHelpers.showError(result['message'] ?? 'Erreur');
    }
  }

  void setFilterStatut(String? statut) {
    debugPrint('🏷️ Filter statut: $statut');
    filterStatut.value = statut;
    loadInscriptions(reset: true);
  }

  void onSearch(String value) {
    debugPrint('🔍 Search: $value');
    search.value = value;
    if (value.length >= 3 || value.isEmpty) loadInscriptions(reset: true);
  }
}
