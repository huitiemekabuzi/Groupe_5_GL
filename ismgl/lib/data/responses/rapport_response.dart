/// Modèles de réponse pour les rapports financiers et statistiques.
library;

class RapportStatistiques {
  final int totalEtudiantsActifs;
  final int totalInscriptions;
  final int inscriptionsPayees;
  final double montantTotalAttendu;
  final double montantTotalPercu;
  final double montantTotalImpaye;
  final int paiementsAujourdhui;
  final double montantAujourdhui;

  RapportStatistiques({
    this.totalEtudiantsActifs = 0,
    this.totalInscriptions = 0,
    this.inscriptionsPayees = 0,
    this.montantTotalAttendu = 0,
    this.montantTotalPercu = 0,
    this.montantTotalImpaye = 0,
    this.paiementsAujourdhui = 0,
    this.montantAujourdhui = 0,
  });

  factory RapportStatistiques.fromJson(Map<String, dynamic> json) =>
      RapportStatistiques(
        totalEtudiantsActifs:  json['total_etudiants_actifs']  as int? ?? 0,
        totalInscriptions:     json['total_inscriptions']      as int? ?? 0,
        inscriptionsPayees:    json['inscriptions_payees']     as int? ?? 0,
        montantTotalAttendu:   double.tryParse(json['montant_total_attendu']?.toString() ?? '0') ?? 0,
        montantTotalPercu:     double.tryParse(json['montant_total_percu']?.toString()   ?? '0') ?? 0,
        montantTotalImpaye:    double.tryParse(json['montant_total_impaye']?.toString()  ?? '0') ?? 0,
        paiementsAujourdhui:   json['paiements_aujourdhui']   as int? ?? 0,
        montantAujourdhui:     double.tryParse(json['montant_aujourdhui']?.toString()   ?? '0') ?? 0,
      );
}

class RapportFinancier {
  final double montantAttendu;
  final double montantPercu;
  final double montantImpaye;
  final int nombreInscriptions;
  final int inscriptionsCompletes;
  final double tauxRecouvrement;

  RapportFinancier({
    this.montantAttendu = 0,
    this.montantPercu = 0,
    this.montantImpaye = 0,
    this.nombreInscriptions = 0,
    this.inscriptionsCompletes = 0,
    this.tauxRecouvrement = 0,
  });

  factory RapportFinancier.fromJson(Map<String, dynamic> json) =>
      RapportFinancier(
        montantAttendu:      double.tryParse(json['montant_attendu']?.toString()  ?? '0') ?? 0,
        montantPercu:        double.tryParse(json['montant_percu']?.toString()    ?? '0') ?? 0,
        montantImpaye:       double.tryParse(json['montant_impaye']?.toString()   ?? '0') ?? 0,
        nombreInscriptions:  json['nombre_inscriptions']  as int? ?? 0,
        inscriptionsCompletes: json['inscriptions_completes'] as int? ?? 0,
        tauxRecouvrement:    double.tryParse(json['taux_recouvrement']?.toString() ?? '0') ?? 0,
      );
}

class RapportImpaye {
  final int nombreEtudiants;
  final double montantTotal;
  final List<Map<String, dynamic>> etudiants;

  RapportImpaye({
    this.nombreEtudiants = 0,
    this.montantTotal = 0,
    this.etudiants = const [],
  });

  factory RapportImpaye.fromJson(Map<String, dynamic> json) => RapportImpaye(
        nombreEtudiants: json['nombre_etudiants'] as int? ?? 0,
        montantTotal:    double.tryParse(json['montant_total']?.toString() ?? '0') ?? 0,
        etudiants: (json['etudiants'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>() ?? [],
      );
}

class RapportJournalierDetail {
  final String dateOperation;
  final int nombreTransactions;
  final double montantTotal;
  final String nomMode;
  final String? caissier;

  RapportJournalierDetail({
    required this.dateOperation,
    required this.nombreTransactions,
    required this.montantTotal,
    required this.nomMode,
    this.caissier,
  });

  factory RapportJournalierDetail.fromJson(Map<String, dynamic> json) =>
      RapportJournalierDetail(
        dateOperation:       json['date_operation']       as String,
        nombreTransactions:  json['nombre_transactions']  as int? ?? 0,
        montantTotal:        double.tryParse(json['montant_total']?.toString() ?? '0') ?? 0,
        nomMode:             json['nom_mode']             as String,
        caissier:            json['caissier']             as String?,
      );
}

class RapportFiliere {
  final int idFiliere;
  final String nomFiliere;
  final String? codeAnnee;
  final int nombreInscriptions;
  final int inscriptionsCompletes;
  final double montantTotalAttendu;
  final double montantTotalPercu;
  final double montantTotalRestant;

  RapportFiliere({
    required this.idFiliere,
    required this.nomFiliere,
    this.codeAnnee,
    this.nombreInscriptions = 0,
    this.inscriptionsCompletes = 0,
    this.montantTotalAttendu = 0,
    this.montantTotalPercu = 0,
    this.montantTotalRestant = 0,
  });

  factory RapportFiliere.fromJson(Map<String, dynamic> json) => RapportFiliere(
        idFiliere:            json['id_filiere']             as int,
        nomFiliere:           json['nom_filiere']            as String,
        codeAnnee:            json['code_annee']             as String?,
        nombreInscriptions:   json['nombre_inscriptions']    as int? ?? 0,
        inscriptionsCompletes: json['inscriptions_completes'] as int? ?? 0,
        montantTotalAttendu:  double.tryParse(json['montant_total_attendu']?.toString() ?? '0') ?? 0,
        montantTotalPercu:    double.tryParse(json['montant_total_percu']?.toString()   ?? '0') ?? 0,
        montantTotalRestant:  double.tryParse(json['montant_total_restant']?.toString() ?? '0') ?? 0,
      );

  double get tauxRecouvrement =>
      montantTotalAttendu > 0 ? (montantTotalPercu / montantTotalAttendu * 100) : 0;
}
