class FraisScolariteModel {
  final int idFrais;
  final int idFiliere;
  final int idNiveau;
  final int idAnneeAcademique;
  final int idTypeFrais;
  final String? nomFrais;
  final String? codeAnnee;
  final double montant;
  final String dateDebutValidite;
  final String dateFinValidite;
  final bool estActif;
  final bool estObligatoire;
  final String? dateCreation;
  final String? dateModification;

  FraisScolariteModel({
    required this.idFrais,
    required this.idFiliere,
    required this.idNiveau,
    required this.idAnneeAcademique,
    required this.idTypeFrais,
    this.nomFrais,
    this.codeAnnee,
    required this.montant,
    required this.dateDebutValidite,
    required this.dateFinValidite,
    this.estActif = true,
    this.estObligatoire = true,
    this.dateCreation,
    this.dateModification,
  });

  factory FraisScolariteModel.fromJson(Map<String, dynamic> json) {
    return FraisScolariteModel(
      idFrais:              json['id_frais']              as int,
      idFiliere:            json['id_filiere']            as int,
      idNiveau:             json['id_niveau']             as int,
      idAnneeAcademique:    json['id_annee_academique']   as int,
      idTypeFrais:          json['id_type_frais']         as int,
      nomFrais:             json['nom_frais']             as String?,
      codeAnnee:            json['code_annee']            as String?,
      montant:              double.tryParse(json['montant']?.toString() ?? '0') ?? 0,
      dateDebutValidite:    json['date_debut_validite']   as String,
      dateFinValidite:      json['date_fin_validite']     as String,
      estActif:             json['est_actif'] == true || json['est_actif'] == 1,
      estObligatoire:       json['est_obligatoire'] == true || json['est_obligatoire'] == 1,
      dateCreation:         json['date_creation']         as String?,
      dateModification:     json['date_modification']     as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id_frais':              idFrais,
        'id_filiere':            idFiliere,
        'id_niveau':             idNiveau,
        'id_annee_academique':   idAnneeAcademique,
        'id_type_frais':         idTypeFrais,
        'montant':               montant,
        'date_debut_validite':   dateDebutValidite,
        'date_fin_validite':     dateFinValidite,
        'est_actif':             estActif,
      };
}
