import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ismgl/controllers/auth_controller.dart';
import 'package:ismgl/controllers/theme_controller.dart';
import 'package:ismgl/core/services/storage_service.dart';
import 'package:ismgl/core/services/api_service.dart';
import 'package:ismgl/core/services/auth_service.dart';
import 'package:ismgl/core/services/dashboard_service.dart';
import 'package:ismgl/core/services/user_service.dart';
import 'package:ismgl/core/services/etudiant_service.dart';
import 'package:ismgl/core/services/inscription_service.dart';
import 'package:ismgl/core/services/paiement_service.dart';
import 'package:ismgl/core/services/recu_service.dart';
import 'package:ismgl/core/services/filiere_service.dart';
import 'package:ismgl/core/services/config_service.dart';
import 'package:ismgl/core/services/rapport_service.dart';
import 'package:ismgl/core/services/notification_service.dart';

class AppInitialization {
  static Future<void> initialize() async {
    // 1. SharedPreferences
    final prefs = await SharedPreferences.getInstance();

    // 2. Services core (permanent = toujours en mémoire)
    Get.put<SharedPreferences>(prefs,        permanent: true);
    Get.put<StorageService>(StorageService(prefs), permanent: true);
    Get.put<ApiService>(ApiService(),         permanent: true);
    Get.put<AuthService>(AuthService(),        permanent: true);
    Get.put<Connectivity>(Connectivity(),      permanent: true);

    // 3. Services métier (permanent pour accès global)
    Get.put<DashboardService>(DashboardService(),    permanent: true);
    Get.put<UserService>(UserService(),               permanent: true);
    Get.put<EtudiantService>(EtudiantService(),       permanent: true);
    Get.put<InscriptionService>(InscriptionService(), permanent: true);
    Get.put<PaiementService>(PaiementService(),       permanent: true);
    Get.put<RecuService>(RecuService(),               permanent: true);
    Get.put<FiliereService>(FiliereService(),         permanent: true);
    Get.put<ConfigService>(ConfigService(),           permanent: true);
    Get.put<RapportService>(RapportService(),         permanent: true);
    Get.put<NotificationService>(NotificationService(), permanent: true);

    // 4. Contrôleurs globaux
    Get.put<ThemeController>(ThemeController(), permanent: true);
    Get.put<AuthController>(AuthController(), permanent: true);
  }
}