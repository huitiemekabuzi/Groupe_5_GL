import 'package:get/get.dart';
import 'package:ismgl/controllers/auth_controller.dart';
import 'package:ismgl/controllers/notification_controller.dart';

class AdminDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
    Get.lazyPut<NotificationController>(() => NotificationController());
  }
}