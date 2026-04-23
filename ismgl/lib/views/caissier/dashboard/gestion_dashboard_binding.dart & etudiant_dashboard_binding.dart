// gestion_dashboard_binding.dart
import 'package:get/get.dart';
import 'package:ismgl/controllers/auth_controller.dart';
import 'package:ismgl/controllers/notification_controller.dart';

class GestionDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
    Get.lazyPut<NotificationController>(() => NotificationController());
  }
}

// etudiant_dashboard_binding.dart
class EtudiantDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
    Get.lazyPut<NotificationController>(() => NotificationController());
  }
}