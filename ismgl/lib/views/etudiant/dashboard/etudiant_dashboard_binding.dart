import 'package:get/get.dart';
import 'package:ismgl/controllers/auth_controller.dart';
import 'package:ismgl/controllers/notification_controller.dart';

class EtudiantDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    Get.lazyPut<NotificationController>(() => NotificationController(), fenix: true);
  }
}