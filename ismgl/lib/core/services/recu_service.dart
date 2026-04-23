import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ismgl/core/services/api_service.dart';

class RecuService extends GetxService {
  final ApiService _api = Get.find<ApiService>();

  Future<Map<String, dynamic>> getRecu(int id) {
    debugPrint('🧾 RecuService.getRecu($id)');
    return _api.get('/recus/$id');
  }

  Future<Map<String, dynamic>> generateRecu(int id) {
    debugPrint('🧾 RecuService.generateRecu($id)');
    return _api.get('/recus/$id/generate');
  }

  String getDownloadUrl(int id) {
    final base = _api.baseUrl;
    return '$base/recus/$id/download';
  }
}
