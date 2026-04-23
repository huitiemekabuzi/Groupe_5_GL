class NiveauModel {
  final int idNiveau;
  final String codeNiveau;
  final String nomNiveau;
  final int ordre;
  final String? description;
  final bool estActif;
  final String? dateCreation;

  NiveauModel({
    required this.idNiveau,
    required this.codeNiveau,
    required this.nomNiveau,
    required this.ordre,
    this.description,
    this.estActif = true,
    this.dateCreation,
  });

  factory NiveauModel.fromJson(Map<String, dynamic> json) {
    return NiveauModel(
      idNiveau:    json['id_niveau']    as int,
      codeNiveau:  json['code_niveau'] as String,
      nomNiveau:   json['nom_niveau']  as String,
      ordre:       json['ordre']       as int,
      description: json['description'] as String?,
      estActif:    json['est_actif'] == true || json['est_actif'] == 1,
      dateCreation: json['date_creation'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id_niveau':    idNiveau,
        'code_niveau':  codeNiveau,
        'nom_niveau':   nomNiveau,
        'ordre':        ordre,
        'description':  description,
        'est_actif':    estActif,
      };

  @override
  String toString() => nomNiveau;
}
