abstract class AppRoutes {
  static const splash        = '/splash';
  static const welcome       = '/welcome';
  static const login         = '/login';
  static const forgotPassword  = '/forgot-password';
  static const resetPassword   = '/reset-password';

  // Admin
  static const adminDashboard     = '/admin/dashboard';
  static const adminUsers         = '/admin/users';
  static const adminUserForm      = '/admin/users/form';
  static const adminEtudiants     = '/admin/etudiants';
  static const adminEtudiantDetail = '/admin/etudiants/detail';
  static const adminInscriptions  = '/admin/inscriptions';
  static const adminInscriptionDetail = '/admin/inscriptions/detail';
  static const adminRapports      = '/admin/rapports';
  static const adminRapportEtudiant = '/admin/rapports/etudiant';
  static const adminLogs          = '/admin/logs';
  static const adminConfiguration = '/admin/configuration';

  // Caissier
  static const caissierDashboard       = '/caissier/dashboard';
  static const caissierPaiements       = '/caissier/paiements';
  static const caissierNouveauPaiement = '/caissier/paiements/nouveau';
  static const caissierPaiementDetail  = '/caissier/paiements/detail';
  static const caissierRecus           = '/caissier/recus';
  static const caissierRecuDetail      = '/caissier/recus/detail';
  static const caissierRapport         = '/caissier/rapport';

  // Gestionnaire
  static const gestionDashboard        = '/gestionnaire/dashboard';
  static const gestionEtudiants        = '/gestionnaire/etudiants';
  static const gestionEtudiantForm     = '/gestionnaire/etudiants/form';
  static const gestionInscriptions     = '/gestionnaire/inscriptions';
  static const gestionInscriptionForm  = '/gestionnaire/inscriptions/form';

  // Étudiant
  static const etudiantDashboard   = '/etudiant/dashboard';
  static const etudiantInscription = '/etudiant/inscription';
  static const etudiantPaiements   = '/etudiant/paiements';
  static const etudiantRecus       = '/etudiant/recus';

  // Commun
  static const profile         = '/profile';
  static const notifications   = '/notifications';
  static const changePassword  = '/change-password';
  static const detail          = '/detail';
}