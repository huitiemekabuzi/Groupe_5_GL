import 'package:get/get.dart';
import 'package:ismgl/controllers/theme_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Ces services sont déjà initialisés dans AppInitialization
    // Ici on s'assure qu'ils sont disponibles globalement
    Get.lazyPut<ThemeController>(() => ThemeController(), fenix: true);
  }
}