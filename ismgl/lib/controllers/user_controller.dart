import 'package:flutter/material.dart' show Color;
import 'package:get/get.dart';
import 'package:ismgl/core/services/user_service.dart';
import 'package:ismgl/core/utils/helpers.dart';
import 'package:ismgl/data/models/user_model.dart';
import 'package:ismgl/data/responses/paginated_response.dart';

class UserController extends GetxController {
  final UserService _service = Get.find<UserService>();

  final isLoading     = false.obs;
  final isSubmitting  = false.obs;
  final users         = <UserModel>[].obs;
  final selectedUser  = Rxn<UserModel>();
  final totalItems    = 0.obs;
  final currentPage   = 1.obs;
  final totalPages    = 1.obs;

  final search      = ''.obs;
  final filterRole  = Rxn<String>();

  static const int _pageSize = 20;

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  Future<void> loadUsers({bool reset = false}) async {
    if (reset) {
      currentPage.value = 1;
      users.clear();
    }
    isLoading.value = true;
    try {
      final result = await _service.getUsers(
        page:     currentPage.value,
        pageSize: _pageSize,
        search:   search.value.isEmpty ? null : search.value,
        role:     filterRole.value,
      );
      if (result['success'] == true) {
        final resp = PaginatedResponse.fromJson(
          result['data'] as Map<String, dynamic>,
          (j) => UserModel.fromJson(j),
        );
        users.assignAll(resp.items);
        totalItems.value  = resp.totalItems;
        totalPages.value  = resp.totalPages;
      } else {
        AppHelpers.showError(result['message'] ?? 'Erreur');
      }
    } catch (e) {
      AppHelpers.showError('Erreur réseau: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createUser(Map<String, dynamic> data) async {
    isSubmitting.value = true;
    try {
      final result = await _service.createUser(data);
      if (result['success'] == true) {
        AppHelpers.showSuccess('Utilisateur créé avec succès');
        await loadUsers(reset: true);
        return true;
      } else {
        AppHelpers.showError(result['message'] ?? 'Erreur création');
        return false;
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> updateUser(int id, Map<String, dynamic> data) async {
    isSubmitting.value = true;
    try {
      final result = await _service.updateUser(id, data);
      if (result['success'] == true) {
        AppHelpers.showSuccess('Utilisateur modifié');
        await loadUsers(reset: true);
        return true;
      } else {
        AppHelpers.showError(result['message'] ?? 'Erreur modification');
        return false;
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> deleteUser(UserModel user) async {
    final confirm = await AppHelpers.showConfirmDialog(
      title:       'Supprimer ${user.fullName}',
      message:     'Cette action est irréversible.',
      confirmText: 'Supprimer',
      confirmColor: const Color(0xFFEF4444),
    );
    if (!confirm) return;
    final result = await _service.deleteUser(user.id);
    if (result['success'] == true) {
      AppHelpers.showSuccess('Utilisateur supprimé');
      await loadUsers(reset: true);
    } else {
      AppHelpers.showError(result['message'] ?? 'Erreur suppression');
    }
  }

  Future<void> toggleUser(UserModel user) async {
    final result = await _service.toggleUser(user.id);
    if (result['success'] == true) {
      AppHelpers.showSuccess('Statut modifié');
      await loadUsers(reset: true);
    } else {
      AppHelpers.showError(result['message'] ?? 'Erreur');
    }
  }

  Future<void> unlockUser(UserModel user) async {
    final result = await _service.unlockUser(user.id);
    if (result['success'] == true) {
      AppHelpers.showSuccess('Compte déverrouillé');
      await loadUsers(reset: true);
    } else {
      AppHelpers.showError(result['message'] ?? 'Erreur');
    }
  }

  void onSearch(String value) {
    search.value = value;
    if (value.length >= 3 || value.isEmpty) loadUsers(reset: true);
  }

  void onFilterRole(String? role) {
    filterRole.value = role;
    loadUsers(reset: true);
  }

  void loadMore() {
    if (currentPage.value < totalPages.value && !isLoading.value) {
      currentPage.value++;
      loadUsers();
    }
  }
}
