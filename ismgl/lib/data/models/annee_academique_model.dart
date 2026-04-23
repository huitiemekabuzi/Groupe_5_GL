class AnneeAcademiqueModel {
  final int idAnneeAcademique;
  final String codeAnnee;
  final int anneeDebut;
  final int anneeFin;
  final String dateDebut;
  final String dateFin;
  final bool estCourante;
  final bool estCloturee;
  final String? dateCloture;
  final String? dateCreation;

  AnneeAcademiqueModel({
    required this.idAnneeAcademique,
    required this.codeAnnee,
    required this.anneeDebut,
    required this.anneeFin,
    required this.dateDebut,
    required this.dateFin,
    this.estCourante = false,
    this.estCloturee = false,
    this.dateCloture,
    this.dateCreation,
  });

  factory AnneeAcademiqueModel.fromJson(Map<String, dynamic> json) {
    return AnneeAcademiqueModel(
      idAnneeAcademique: json['id_annee_academique'] as int,
      codeAnnee:         json['code_annee']          as String,
      anneeDebut:        json['annee_debut']          as int,
      anneeFin:          json['annee_fin']            as int,
      dateDebut:         json['date_debut']           as String,
      dateFin:           json['date_fin']             as String,
      estCourante:       json['est_courante'] == true || json['est_courante'] == 1,
      estCloturee:       json['est_cloturee'] == true || json['est_cloturee'] == 1,
      dateCloture:       json['date_cloture']     as String?,
      dateCreation:      json['date_creation']    as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id_annee_academique': idAnneeAcademique,
        'code_annee':          codeAnnee,
        'annee_debut':         anneeDebut,
        'annee_fin':           anneeFin,
        'date_debut':          dateDebut,
        'date_fin':            dateFin,
        'est_courante':        estCourante,
        'est_cloturee':        estCloturee,
      };

  @override
  String toString() => codeAnnee;
}
