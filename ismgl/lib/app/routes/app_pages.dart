import 'package:get/get.dart';
import 'package:ismgl/app/routes/app_routes.dart';
import 'package:ismgl/views/caissier/dashboard/gestion_dashboard_page.dart';
import 'package:ismgl/views/public/splash/splash_page.dart';
import 'package:ismgl/views/public/welcome/welcome_page.dart';
import 'package:ismgl/views/auth/login/login_page.dart';
import 'package:ismgl/views/auth/forgot_password/forgot_password_page.dart';
import 'package:ismgl/views/auth/forgot_password/reset_password_page.dart';

// Admin Views
import 'package:ismgl/views/admin/dashboard/admin_dashboard_page.dart';
import 'package:ismgl/views/admin/users/users_page.dart';
import 'package:ismgl/views/admin/users/user_form_page.dart';
import 'package:ismgl/views/admin/etudiants/etudiants_page.dart';
import 'package:ismgl/views/admin/etudiants/etudiant_detail_page.dart';
import 'package:ismgl/views/admin/inscriptions/inscriptions_page.dart';
import 'package:ismgl/views/admin/inscriptions/inscription_detail_page.dart';
import 'package:ismgl/views/admin/rapports/rapports_page.dart';
import 'package:ismgl/views/admin/rapports/rapport_etudiant_page.dart';
import 'package:ismgl/views/admin/rapports/admin_logs_page.dart';
import 'package:ismgl/views/admin/configuration/configuration_page.dart';

// Caissier Views
import 'package:ismgl/views/caissier/dashboard/caissier_dashboard_page.dart';
import 'package:ismgl/views/caissier/paiements/paiements_page.dart';
import 'package:ismgl/views/caissier/paiements/nouveau_paiement_page.dart';
import 'package:ismgl/views/caissier/paiements/paiement_detail_page.dart';
import 'package:ismgl/views/caissier/recus/recus_page.dart';
import 'package:ismgl/views/caissier/recus/recu_detail_page.dart';
import 'package:ismgl/views/caissier/rapports/rapport_caisse_page.dart';

// Gestionnaire Views
import 'package:ismgl/views/gestionnaire/etudiants/etudiants_gestion_page.dart';
import 'package:ismgl/views/gestionnaire/etudiants/etudiant_form_page.dart';
import 'package:ismgl/views/gestionnaire/inscriptions/inscriptions_gestion_page.dart';
import 'package:ismgl/views/gestionnaire/inscriptions/inscription_form_page.dart';

// Étudiant Views
import 'package:ismgl/views/etudiant/dashboard/etudiant_dashboard_page.dart';
import 'package:ismgl/views/etudiant/inscription/inscription_page.dart';
import 'package:ismgl/views/etudiant/paiements/mes_paiements_page.dart';
import 'package:ismgl/views/etudiant/recus/mes_recus_page.dart';

// Shared Views
import 'package:ismgl/views/shared/profile/profile_page.dart';
import 'package:ismgl/views/shared/profile/change_password_page.dart';
import 'package:ismgl/views/shared/notifications/notifications_page.dart';

// Bindings
import 'package:ismgl/views/admin/dashboard/admin_dashboard_binding.dart';
import 'package:ismgl/views/admin/etudiants/etudiants_binding.dart';
import 'package:ismgl/views/caissier/dashboard/caissier_dashboard_binding.dart';
import 'package:ismgl/views/gestionnaire/dashboard/gestion_dashboard_binding.dart';
import 'package:ismgl/views/etudiant/dashboard/etudiant_dashboard_binding.dart';
import 'package:ismgl/app/middlewares/auth_middleware.dart';

class AppPages {
  static final pages = [
    // ── Public ─────────────────────────────────────────────────────────────
    GetPage(name: AppRoutes.splash,   page: () => const SplashPage()),
    GetPage(name: AppRoutes.welcome,  page: () => const WelcomePage()),
    GetPage(name: AppRoutes.login,    page: () => const LoginPage()),
    GetPage(name: AppRoutes.forgotPassword, page: () => const ForgotPasswordPage()),
    GetPage(name: AppRoutes.resetPassword,  page: () => const ResetPasswordPage()),

    // ── Admin ───────────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const AdminDashboardPage(),
      binding: AdminDashboardBinding(),
      middlewares: [AuthMiddleware(allowedRoles: ['Administrateur'])],
    ),
    GetPage(
      name: AppRoutes.adminUsers,
      page: () => const UsersPage(),
      middlewares: [AuthMiddleware(allowedRoles: ['Administrateur'])],
    ),
    GetPage(name: AppRoutes.adminUserForm,  page: () => const UserFormPage()),
    GetPage(
      name: AppRoutes.adminEtudiants,
      page: () => const EtudiantsPage(),
      binding: EtudiantsBinding(),
      middlewares: [AuthMiddleware(allowedRoles: ['Administrateur', 'Gestionnaire'])],
    ),
    GetPage(
      name: AppRoutes.adminEtudiantDetail,
      page: () => const EtudiantDetailPage(),
      middlewares: [AuthMiddleware(allowedRoles: ['Administrateur', 'Gestionnaire'])],
    ),
    GetPage(
      name: AppRoutes.adminInscriptions,
      page: () => const InscriptionsPage(),
      middlewares: [AuthMiddleware(allowedRoles: ['Administrateur', 'Gestionnaire'])],
    ),
    GetPage(
      name: AppRoutes.adminInscriptionDetail,
      page: () => const InscriptionDetailPage(),
      middlewares: [AuthMiddleware(allowedRoles: ['Administrateur', 'Gestionnaire'])],
    ),
    GetPage(
      name: AppRoutes.adminRapports,
      page: () => const RapportsPage(),
      middlewares: [AuthMiddleware(allowedRoles: ['Administrateur', 'Comptable'])],
    ),
    GetPage(
      name: AppRoutes.adminRapportEtudiant,
      page: () => const RapportEtudiantPage(),
      middlewares: [AuthMiddleware(allowedRoles: ['Administrateur', 'Gestionnaire', 'Comptable'])],
    ),
    GetPage(
      name: AppRoutes.adminLogs,
      page: () => const AdminLogsPage(),
      middlewares: [AuthMiddleware(allowedRoles: ['Administrateur'])],
    ),
    GetPage(
      name: AppRoutes.adminConfiguration,
      page: () => const ConfigurationPage(),
      middlewares: [AuthMiddleware(allowedRoles: ['Administrateur'])],
    ),

    // ── Caissier ────────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.caissierDashboard,
      page: () => const CaissierDashboardPage(),
      binding: CaissierDashboardBinding(),
      middlewares: [AuthMiddleware(allowedRoles: ['Caissier', 'Administrateur'])],
    ),
    GetPage(
      name: AppRoutes.caissierPaiements,
      page: () => const PaiementsPage(),
      middlewares: [AuthMiddleware(allowedRoles: ['Caissier', 'Administrateur'])],
    ),
    GetPage(
      name: AppRoutes.caissierNouveauPaiement,
      page: () => const NouveauPaiementPage(),
      middlewares: [AuthMiddleware(allowedRoles: ['Caissier', 'Administrateur'])],
    ),
    GetPage(
      name: AppRoutes.caissierPaiementDetail,
      page: () => const PaiementDetailPage(),
      middlewares: [AuthMiddleware(allowedRoles: ['Caissier', 'Administrateur'])],
    ),
    GetPage(
      name: AppRoutes.caissierRecus,
      page: () => const RecusPage(),
      middlewares: [AuthMiddleware(allowedRoles: ['Caissier', 'Administrateur'])],
    ),
    GetPage(
      name: AppRoutes.caissierRecuDetail,
      page: () => const RecuDetailPage(),
      middlewares: [AuthMiddleware(allowedRoles: ['Caissier', 'Administrateur'])],
    ),
    GetPage(
      name: AppRoutes.caissierRapport,
      page: () => const RapportCaissePage(),
      middlewares: [AuthMiddleware(allowedRoles: ['Caissier', 'Administrateur'])],
    ),

    // ── Gestionnaire ────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.gestionDashboard,
      page: () => const GestionDashboardPage(),
      binding: GestionDashboardBinding(),
      middlewares: [AuthMiddleware(allowedRoles: ['Gestionnaire', 'Administrateur'])],
    ),
    GetPage(
      name: AppRoutes.gestionEtudiants,
      page: () => const EtudiantsGestionPage(),
      middlewares: [AuthMiddleware(allowedRoles: ['Gestionnaire', 'Administrateur'])],
    ),
    GetPage(
      name: AppRoutes.gestionEtudiantForm,
      page: () => const EtudiantFormPage(),
      middlewares: [AuthMiddleware(allowedRoles: ['Gestionnaire', 'Administrateur'])],
    ),
    GetPage(
      name: AppRoutes.gestionInscriptions,
      page: () => const InscriptionsGestionPage(),
      middlewares: [AuthMiddleware(allowedRoles: ['Gestionnaire', 'Administrateur'])],
    ),
    GetPage(
      name: AppRoutes.gestionInscriptionForm,
      page: () => const InscriptionFormPage(),
      middlewares: [AuthMiddleware(allowedRoles: ['Gestionnaire', 'Administrateur'])],
    ),

    // ── Étudiant ────────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.etudiantDashboard,
      page: () => const EtudiantDashboardPage(),
      binding: EtudiantDashboardBinding(),
      middlewares: [AuthMiddleware(allowedRoles: ['Etudiant'])],
    ),
    GetPage(
      name: AppRoutes.etudiantInscription,
      page: () => const InscriptionPage(),
      middlewares: [AuthMiddleware(allowedRoles: ['Etudiant'])],
    ),
    GetPage(
      name: AppRoutes.etudiantPaiements,
      page: () => const MesPaiementsPage(),
      middlewares: [AuthMiddleware(allowedRoles: ['Etudiant'])],
    ),
    GetPage(
      name: AppRoutes.etudiantRecus,
      page: () => const MesRecusPage(),
      middlewares: [AuthMiddleware(allowedRoles: ['Etudiant'])],
    ),

    // ── Shared ──────────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfilePage(),
      middlewares: [AuthMiddleware(allowedRoles: const <String>[])],
    ),
    GetPage(
      name: AppRoutes.changePassword,
      page: () => const ChangePasswordPage(),
      middlewares: [AuthMiddleware(allowedRoles: const <String>[])],
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsPage(),
      middlewares: [AuthMiddleware(allowedRoles: const <String>[])],
    ),
  ];
}