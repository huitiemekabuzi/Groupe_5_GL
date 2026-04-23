import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ismgl/core/services/paiement_service.dart';
import 'package:ismgl/core/utils/helpers.dart';
import 'package:ismgl/data/models/paiement_model.dart';
import 'package:ismgl/data/responses/paginated_response.dart';

class PaiementController extends GetxController {
  final PaiementService _service = Get.find<PaiementService>();

  final isLoading    = false.obs;
  final isSubmitting = false.obs;
  final paiements    = <PaiementModel>[].obs;
  final selectedPaiement = Rxn<PaiementModel>();
  final totalItems   = 0.obs;
  final currentPage  = 1.obs;
  final totalPages   = 1.obs;

  final search        = ''.obs;
  final filterStatut  = Rxn<String>();
  final filterDateDebut = Rxn<String>();
  final filterDateFin   = Rxn<String>();

  // Rapport journalier
  final rapportJournalier = Rxn<Map<String, dynamic>>();
  final montantJour      = 0.0.obs;
  final nombrePaiementsJour = 0.obs;

  static const int _pageSize = 20;

  @override
  void onInit() {
    super.onInit();
    debugPrint('🟢 PaiementController.onInit()');
    loadPaiements();
  }

  Future<void> loadPaiements({bool reset = false}) async {
    if (reset) {
      currentPage.value = 1;
      paiements.clear();
    }
    
    debugPrint('\n📥 PaiementController.loadPaiements()');
    debugPrint('   Page: ${currentPage.value}');
    debugPrint('   Search: ${search.value}');
    debugPrint('   Statut: ${filterStatut.value}');
    debugPrint('   Date: ${filterDateDebut.value} - ${filterDateFin.value}');
    
    isLoading.value = true;
    try {
      final result = await _service.getPaiements(
        page:      currentPage.value,
        pageSize:  _pageSize,
        search:    search.value.isEmpty ? null : search.value,
        statut:    filterStatut.value,
        dateDebut: filterDateDebut.value,
        dateFin:   filterDateFin.value,
      );
      
      debugPrint('   Response success: ${result['success']}');
      
      if (result['success'] == true) {
        final data = result['data'];
        debugPrint('   Data keys: ${(data as Map).keys}');
        
        final resp = PaginatedResponse.fromJson(
          data as Map<String, dynamic>,
          (j) => PaiementModel.fromJson(j),
        );
        
        debugPrint('   Parsed items: ${resp.items.length}');
        
        if (reset || currentPage.value == 1) {
          paiements.assignAll(resp.items);
        } else {
          paiements.addAll(resp.items);
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

  Future<bool> createPaiement(Map<String, dynamic> data) async {
    debugPrint('\n📤 PaiementController.createPaiement()');
    debugPrint('   Data: $data');
    
    isSubmitting.value = true;
    try {
      final result = await _service.createPaiement(data);
      if (result['success'] == true) {
        debugPrint('   ✅ Paiement créé avec succès');
        AppHelpers.showSuccess('Paiement enregistré avec succès');
        await loadPaiements(reset: true);
        return true;
      } else {
        debugPrint('   ❌ Erreur: ${result['message']}');
        AppHelpers.showError(result['message'] ?? 'Erreur paiement');
        return false;
      }
    } catch (e) {
      debugPrint('   ❌ Exception: $e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> annuler(PaiementModel paiement, String motif) async {
    debugPrint('\n📤 PaiementController.annuler(${paiement.idPaiement})');
    debugPrint('   Motif: $motif');
    
    final result = await _service.annuler(paiement.idPaiement, motif);
    if (result['success'] == true) {
      debugPrint('   ✅ Paiement annulé');
      AppHelpers.showSuccess('Paiement annulé');
      await loadPaiements(reset: true);
    } else {
      debugPrint('   ❌ Erreur: ${result['message']}');
      AppHelpers.showError(result['message'] ?? 'Erreur annulation');
    }
  }

  Future<void> loadRapportJournalier({String? date}) async {
    debugPrint('\n📥 PaiementController.loadRapportJournalier()');
    debugPrint('   Date: $date');
    
    isLoading.value = true;
    try {
      final result = await _service.getRapportJournalier(date: date);
      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>;
        rapportJournalier.value = data;
        montantJour.value = double.tryParse(
                data['montant_total']?.toString() ?? '0') ?? 0;
        nombrePaiementsJour.value =
            (data['details'] as List<dynamic>?)
                ?.fold<int>(0, (sum, e) => sum + ((e as Map)['nombre_transactions'] as int? ?? 0)) ?? 0;
      }
    } finally {
      isLoading.value = false;
    }
  }

  void onSearch(String value) {
    search.value = value;
    if (value.length >= 3 || value.isEmpty) loadPaiements(reset: true);
  }

  void setDateFilter(String? debut, String? fin) {
    filterDateDebut.value = debut;
    filterDateFin.value   = fin;
    loadPaiements(reset: true);
  }
}
