import 'package:get/get.dart';
import 'package:ismgl/core/services/dashboard_service.dart';
import 'package:ismgl/core/utils/helpers.dart';
import 'package:ismgl/data/responses/dashboard_response.dart';

class DashboardController extends GetxController {
  final DashboardService _service = Get.find<DashboardService>();

  final isLoading = true.obs;
  final rawData   = Rxn<Map<String, dynamic>>();

  // Parsed admin data
  final adminData   = Rxn<AdminDashboardResponse>();
  // Parsed caissier data
  final caissierData = Rxn<CaissierDashboardResponse>();

  final String role;
  DashboardController({required this.role});

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final result = await _service.getDashboard();
      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>;
        rawData.value = data;

        if (role == 'Administrateur' || role == 'Gestionnaire' || role == 'Comptable') {
          adminData.value = AdminDashboardResponse.fromJson(data);
        } else if (role == 'Caissier') {
          caissierData.value = CaissierDashboardResponse.fromJson(data);
        }
      } else {
        AppHelpers.showError(result['message'] ?? 'Erreur chargement dashboard');
      }
    } catch (e) {
      AppHelpers.showError('Erreur réseau: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Helpers for template access
  DashboardStatistiques get stats =>
      adminData.value?.statistiques ?? DashboardStatistiques();

  List<Map<String, dynamic>> get paiementsRecents =>
      adminData.value?.paiementsRecents ?? [];

  int get etudiantsImpayesCount =>
      adminData.value?.etudiantsImpayesCount ?? 0;
}
