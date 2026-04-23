class InscriptionModel {
  final int idInscription;
  final String? numeroInscription;
  final int idEtudiant;
  final int? idFiliere;
  final int? idNiveau;
  final int? idAnneeAcademique;
  final String? dateInscription;
  final String typeInscription;
  final String statutInscription;
  final double montantTotal;
  final double montantPaye;
  final double montantRestant;
  final bool estComplete;
  final String? dateValidation;
  final int? valideePar;
  final String? motifRejet;
  final String? notes;
  final String? pourcentagePaye;
  final String? dateCreation;
  final String? dateModification;

  // Champs joints
  final String? nomComplet;
  final String? numeroEtudiant;
  final String? nomFiliere;
  final String? nomNiveau;
  final String? codeAnnee;

  InscriptionModel({
    required this.idInscription,
    this.numeroInscription,
    required this.idEtudiant,
    this.idFiliere,
    this.idNiveau,
    this.idAnneeAcademique,
    this.dateInscription,
    this.typeInscription = 'Nouvelle',
    this.statutInscription = 'En attente',
    this.montantTotal = 0,
    this.montantPaye = 0,
    this.montantRestant = 0,
    this.estComplete = false,
    this.dateValidation,
    this.valideePar,
    this.motifRejet,
    this.notes,
    this.pourcentagePaye,
    this.dateCreation,
    this.dateModification,
    this.nomComplet,
    this.numeroEtudiant,
    this.nomFiliere,
    this.nomNiveau,
    this.codeAnnee,
  });

  factory InscriptionModel.fromJson(Map<String, dynamic> json) {
    return InscriptionModel(
      idInscription:    json['id_inscription']      as int,
      numeroInscription: json['numero_inscription'] as String?,
      idEtudiant:       json['id_etudiant']         as int? ?? 0,
      idFiliere:        json['id_filiere']           as int?,
      idNiveau:         json['id_niveau']            as int?,
      idAnneeAcademique: json['id_annee_academique'] as int?,
      dateInscription:  json['date_inscription']    as String?,
      typeInscription:  json['type_inscription']    as String? ?? 'Nouvelle',
      statutInscription: json['statut_inscription'] as String? ?? 'En attente',
      montantTotal:     double.tryParse(json['montant_total']?.toString() ?? '0') ?? 0,
      montantPaye:      double.tryParse(json['montant_paye']?.toString() ?? '0') ?? 0,
      montantRestant:   double.tryParse(json['montant_restant']?.toString() ?? '0') ?? 0,
      estComplete:      json['est_complete'] == true || json['est_complete'] == 1,
      dateValidation:   json['date_validation']     as String?,
      valideePar:       json['validee_par']         as int?,
      motifRejet:       json['motif_rejet']         as String?,
      notes:            json['notes']               as String?,
      pourcentagePaye:  json['pourcentage_paye']    as String?,
      dateCreation:     json['date_creation']       as String?,
      dateModification: json['date_modification']   as String?,
      nomComplet:       json['nom_complet']         as String? ??
                        (json['nom'] != null && json['prenom'] != null
                            ? '${json['prenom']} ${json['nom']}'
                            : null),
      numeroEtudiant:   json['numero_etudiant']     as String?,
      nomFiliere:       json['nom_filiere']         as String?,
      nomNiveau:        json['nom_niveau']          as String?,
      codeAnnee:        json['code_annee']          as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id_inscription':     idInscription,
        'numero_inscription': numeroInscription,
        'id_etudiant':        idEtudiant,
        'id_filiere':         idFiliere,
        'id_niveau':          idNiveau,
        'id_annee_academique': idAnneeAcademique,
        'type_inscription':   typeInscription,
        'statut_inscription': statutInscription,
        'montant_total':      montantTotal,
        'montant_paye':       montantPaye,
        'montant_restant':    montantRestant,
        'est_complete':       estComplete,
        'motif_rejet':        motifRejet,
        'notes':              notes,
      };

  bool get estEnAttente  => statutInscription == 'En attente';
  bool get estValidee    => statutInscription == 'Validée';
  bool get estRejetee    => statutInscription == 'Rejetée';
  bool get estAnnulee    => statutInscription == 'Annulée';
  String get nomCompletDisplay => nomComplet ?? '';
}