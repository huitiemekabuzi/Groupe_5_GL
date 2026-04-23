import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ismgl/controllers/etudiant_controller.dart';

class EtudiantsBinding extends Bindings {
  @override
  void dependencies() {
    debugPrint('📌 Binding: EtudiantsBinding');
    Get.lazyPut<EtudiantController>(() => EtudiantController(), fenix: true);
  }
}
