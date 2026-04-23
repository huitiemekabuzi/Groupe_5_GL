import 'package:get/get.dart';
import 'package:ismgl/core/services/api_service.dart';

class DashboardService extends GetxService {
  final ApiService _api = Get.find<ApiService>();

  /// Charge le dashboard (la réponse varie selon le rôle de l'utilisateur).
  Future<Map<String, dynamic>> getDashboard() async {
    return _api.get('/dashboard');
  }
}
