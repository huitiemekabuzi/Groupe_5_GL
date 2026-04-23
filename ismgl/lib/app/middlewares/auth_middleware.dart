import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ismgl/app/routes/app_routes.dart';
import 'package:ismgl/core/services/storage_service.dart';

class AuthMiddleware extends GetMiddleware {
  final List<String> allowedRoles;

  AuthMiddleware({required this.allowedRoles});

  @override
  RouteSettings? redirect(String? route) {
    final storage = Get.find<StorageService>();
    final token = storage.getToken();
    final role  = storage.getUserRole();

    if (token == null || token.isEmpty) {
      return const RouteSettings(name: AppRoutes.login);
    }

    if (allowedRoles.isNotEmpty && role != null && !allowedRoles.contains(role)) {
      return RouteSettings(name: _getDefaultRouteForRole(role));
    }

    return null;
  }

  String _getDefaultRouteForRole(String role) {
    switch (role) {
      case 'Administrateur': return AppRoutes.adminDashboard;
      case 'Caissier':       return AppRoutes.caissierDashboard;
      case 'Gestionnaire':   return AppRoutes.gestionDashboard;
      case 'Etudiant':       return AppRoutes.etudiantDashboard;
      case 'Comptable':      return AppRoutes.adminRapports;
      default:               return AppRoutes.login;
    }
  }
}