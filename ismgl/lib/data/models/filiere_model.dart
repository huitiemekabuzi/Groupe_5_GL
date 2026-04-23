class FiliereModel {
  final int idFiliere;
  final String codeFiliere;
  final String nomFiliere;
  final int idDepartement;
  final String? nomDepartement;
  final String? nomFaculte;
  final String? diplomeDelivre;
  final int dureeEtudes;
  final String? description;
  final bool estActif;
  final String? dateCreation;
  final String? dateModification;

  FiliereModel({
    required this.idFiliere,
    required this.codeFiliere,
    required this.nomFiliere,
    required this.idDepartement,
    this.nomDepartement,
    this.nomFaculte,
    this.diplomeDelivre,
    this.dureeEtudes = 3,
    this.description,
    this.estActif = true,
    this.dateCreation,
    this.dateModification,
  });

  factory FiliereModel.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '0') ?? 0;
    String asString(dynamic v) => v?.toString() ?? '';
    return FiliereModel(
      idFiliere:        asInt(json['id_filiere']),
      codeFiliere:      asString(json['code_filiere']),
      nomFiliere:       asString(json['nom_filiere']),
      idDepartement:    asInt(json['id_departement']),
      nomDepartement:   json['nom_departement']  as String?,
      nomFaculte:       json['nom_faculte']      as String?,
      diplomeDelivre:   json['diplome_delivre']  as String?,
      dureeEtudes:      asInt(json['duree_etudes']) == 0 ? 3 : asInt(json['duree_etudes']),
      description:      json['description']      as String?,
      estActif:         json['est_actif'] == true || json['est_actif'] == 1,
      dateCreation:     json['date_creation']    as String?,
      dateModification: json['date_modification'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id_filiere':       idFiliere,
        'code_filiere':     codeFiliere,
        'nom_filiere':      nomFiliere,
        'id_departement':   idDepartement,
        'diplome_delivre':  diplomeDelivre,
        'duree_etudes':     dureeEtudes,
        'description':      description,
        'est_actif':        estActif,
      };

  @override
  String toString() => nomFiliere;
}
