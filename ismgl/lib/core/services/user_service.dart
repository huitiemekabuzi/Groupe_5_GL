import 'package:get/get.dart';
import 'package:ismgl/core/services/api_service.dart';

class UserService extends GetxService {
  final ApiService _api = Get.find<ApiService>();

  /// Liste paginée des utilisateurs.
  Future<Map<String, dynamic>> getUsers({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? role,
    bool? actif,
  }) async {
    return _api.get('/users', params: {
      'page':      page,
      'page_size': pageSize,
      if (search != null && search.isNotEmpty) 'search': search,
      if (role   != null) 'role':  role,
      if (actif  != null) 'actif': actif ? 1 : 0,
    });
  }

  /// Détail d'un utilisateur.
  Future<Map<String, dynamic>> getUser(int id) async {
    return _api.get('/users/$id');
  }

  /// Créer un utilisateur.
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> data) async {
    return _api.post('/users', data: data);
  }

  /// Modifier un utilisateur.
  Future<Map<String, dynamic>> updateUser(int id, Map<String, dynamic> data) async {
    return _api.put('/users/$id', data: data);
  }

  /// Supprimer un utilisateur.
  Future<Map<String, dynamic>> deleteUser(int id) async {
    return _api.delete('/users/$id');
  }

  /// Activer / désactiver un utilisateur.
  Future<Map<String, dynamic>> toggleUser(int id) async {
    return _api.patch('/users/$id/toggle');
  }

  /// Déverrouiller un compte bloqué.
  Future<Map<String, dynamic>> unlockUser(int id) async {
    return _api.patch('/users/$id/unlock');
  }
}
