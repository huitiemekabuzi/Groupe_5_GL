/// Modèles de réponse pour les dashboards (admin, caissier, etc.)
library;

class DashboardAnneeCourante {
  final int idAnneeAcademique;
  final String codeAnnee;
  final bool estCourante;

  DashboardAnneeCourante({
    required this.idAnneeAcademique,
    required this.codeAnnee,
    required this.estCourante,
  });

  factory DashboardAnneeCourante.fromJson(Map<String, dynamic> json) =>
      DashboardAnneeCourante(
        idAnneeAcademique: json['id_annee_academique'] as int,
        codeAnnee:         json['code_annee']          as String,
        estCourante:       json['est_courante'] == true || json['est_courante'] == 1,
      );
}

class DashboardStatistiques {
  final int totalEtudiantsActifs;
  final int totalInscriptions;
  final int inscriptionsPayees;
  final double montantTotalAttendu;
  final double montantTotalPercu;
  final double montantTotalImpaye;
  final int paiementsAujourdhui;
  final double montantAujourdhui;

  DashboardStatistiques({
    this.totalEtudiantsActifs = 0,
    this.totalInscriptions = 0,
    this.inscriptionsPayees = 0,
    this.montantTotalAttendu = 0,
    this.montantTotalPercu = 0,
    this.montantTotalImpaye = 0,
    this.paiementsAujourdhui = 0,
    this.montantAujourdhui = 0,
  });

  factory DashboardStatistiques.fromJson(Map<String, dynamic> json) =>
      DashboardStatistiques(
        totalEtudiantsActifs:  json['total_etudiants_actifs']  as int? ?? 0,
        totalInscriptions:     json['total_inscriptions']      as int? ?? 0,
        inscriptionsPayees:    json['inscriptions_payees']     as int? ?? 0,
        montantTotalAttendu:   double.tryParse(json['montant_total_attendu']?.toString() ?? '0') ?? 0,
        montantTotalPercu:     double.tryParse(json['montant_total_percu']?.toString()   ?? '0') ?? 0,
        montantTotalImpaye:    double.tryParse(json['montant_total_impaye']?.toString()  ?? '0') ?? 0,
        paiementsAujourdhui:   json['paiements_aujourdhui']   as int? ?? 0,
        montantAujourdhui:     double.tryParse(json['montant_aujourdhui']?.toString()   ?? '0') ?? 0,
      );

  double get tauxRecouvrement =>
      montantTotalAttendu > 0 ? (montantTotalPercu / montantTotalAttendu * 100) : 0;
}

class DashboardModePaiement {
  final String nomMode;
  final int nombre;
  final double total;

  DashboardModePaiement({
    required this.nomMode,
    required this.nombre,
    required this.total,
  });

  factory DashboardModePaiement.fromJson(Map<String, dynamic> json) =>
      DashboardModePaiement(
        nomMode: json['nom_mode'] as String,
        nombre:  json['nombre']   as int? ?? 0,
        total:   double.tryParse(json['total']?.toString() ?? '0') ?? 0,
      );
}

class AdminDashboardResponse {
  final String role;
  final DashboardAnneeCourante? anneeCourante;
  final DashboardStatistiques statistiques;
  final List<Map<String, dynamic>> paiementsRecents;
  final List<Map<String, dynamic>> inscriptionsRecentes;
  final int etudiantsImpayesCount;
  final int utilisateursActifs;

  AdminDashboardResponse({
    required this.role,
    this.anneeCourante,
    required this.statistiques,
    this.paiementsRecents = const [],
    this.inscriptionsRecentes = const [],
    this.etudiantsImpayesCount = 0,
    this.utilisateursActifs = 0,
  });

  factory AdminDashboardResponse.fromJson(Map<String, dynamic> json) {
    return AdminDashboardResponse(
      role: json['role'] as String? ?? 'Administrateur',
      anneeCourante: json['annee_courante'] != null
          ? DashboardAnneeCourante.fromJson(json['annee_courante'] as Map<String, dynamic>)
          : null,
      statistiques: json['statistiques'] != null
          ? DashboardStatistiques.fromJson(json['statistiques'] as Map<String, dynamic>)
          : DashboardStatistiques(),
      paiementsRecents: (json['paiements_recents'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ?? [],
      inscriptionsRecentes: (json['inscriptions_recentes'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ?? [],
      etudiantsImpayesCount: json['etudiants_impayes_count'] as int? ?? 0,
      utilisateursActifs:    json['utilisateurs_actifs']     as int? ?? 0,
    );
  }
}

class CaissierDashboardResponse {
  final String role;
  final List<Map<String, dynamic>> paiementsAujourdhui;
  final double montantAujourdhui;
  final int nombrePaiementsJour;
  final List<DashboardModePaiement> rapportModesPaiement;

  CaissierDashboardResponse({
    required this.role,
    this.paiementsAujourdhui = const [],
    this.montantAujourdhui = 0,
    this.nombrePaiementsJour = 0,
    this.rapportModesPaiement = const [],
  });

  factory CaissierDashboardResponse.fromJson(Map<String, dynamic> json) {
    return CaissierDashboardResponse(
      role: json['role'] as String? ?? 'Caissier',
      paiementsAujourdhui: (json['paiements_aujourd_hui'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ?? [],
      montantAujourdhui:   double.tryParse(json['montant_aujourd_hui']?.toString() ?? '0') ?? 0,
      nombrePaiementsJour: json['nombre_paiements_jour'] as int? ?? 0,
      rapportModesPaiement: (json['rapport_modes_paiement'] as List<dynamic>?)
              ?.map((e) => DashboardModePaiement.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
    );
  }
}
