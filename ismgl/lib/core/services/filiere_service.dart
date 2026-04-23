import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ismgl/core/services/api_service.dart';

class FiliereService extends GetxService {
  final ApiService _api = Get.find<ApiService>();

  Future<Map<String, dynamic>> getFilieres() {
    debugPrint('📚 FiliereService.getFilieres()');
    return _api.get('/filieres');
  }

  Future<Map<String, dynamic>> getFiliere(int id) {
    debugPrint('📚 FiliereService.getFiliere($id)');
    return _api.get('/filieres/$id');
  }

  Future<Map<String, dynamic>> createFiliere(Map<String, dynamic> data) {
    debugPrint('📚 FiliereService.createFiliere()');
    return _api.post('/filieres', data: data);
  }

  Future<Map<String, dynamic>> updateFiliere(int id, Map<String, dynamic> data) {
    debugPrint('📚 FiliereService.updateFiliere($id)');
    return _api.put('/filieres/$id', data: data);
  }

  Future<Map<String, dynamic>> deleteFiliere(int id) {
    debugPrint('📚 FiliereService.deleteFiliere($id)');
    return _api.delete('/filieres/$id');
  }
}
