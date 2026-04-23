import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ismgl/core/services/api_service.dart';

class EtudiantService extends GetxService {
  final ApiService _api = Get.find<ApiService>();

  Future<Map<String, dynamic>> getEtudiants({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? statut,
    String? sexe,
  }) async {
    debugPrint('📚 EtudiantService.getEtudiants(page=$page, search=$search)');
    return _api.get(
      '/etudiants',
      params: {
        'page': page,
        'page_size': pageSize,
        if (search != null && search.isNotEmpty) 'search': search,
        if (statut != null && statut.isNotEmpty) 'statut': statut,
        if (sexe != null && sexe.isNotEmpty) 'sexe': sexe,
      },
    );
  }

  Future<Map<String, dynamic>> getEtudiant(int id) {
    debugPrint('📚 EtudiantService.getEtudiant($id)');
    return _api.get('/etudiants/$id');
  }

  Future<Map<String, dynamic>> getMe() {
    debugPrint('📚 EtudiantService.getMe()');
    return _api.get('/etudiants/me');
  }

  Future<Map<String, dynamic>> createEtudiant(
    Map<String, dynamic> data, {
    String? photoProfilPath,
    String? photoIdentitePath,
  }) async {
    debugPrint('📚 EtudiantService.createEtudiant()');
    if ((photoProfilPath == null || photoProfilPath.isEmpty) &&
        (photoIdentitePath == null || photoIdentitePath.isEmpty)) {
      return _api.post('/etudiants', data: data);
    }

    final files = <String, File>{};
    if (photoProfilPath != null && photoProfilPath.isNotEmpty) {
      files['photo_profil'] = File(photoProfilPath);
    }
    if (photoIdentitePath != null && photoIdentitePath.isNotEmpty) {
      files['photo_identite'] = File(photoIdentitePath);
    }

    return _api.upload('/etudiants', data, files: files);
  }

  Future<Map<String, dynamic>> updateStatut(int idEtudiant, String statut) {
    debugPrint('📚 EtudiantService.updateStatut($idEtudiant, $statut)');
    return _api.patch('/etudiants/$idEtudiant/statut', data: {'statut': statut});
  }
}
