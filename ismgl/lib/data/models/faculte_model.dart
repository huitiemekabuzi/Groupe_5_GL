class FaculteModel {
  final int idFaculte;
  final String codeFaculte;
  final String nomFaculte;
  final String? description;
  final String? doyen;
  final String? email;
  final String? telephone;
  final bool estActif;
  final String? dateCreation;
  final String? dateModification;

  FaculteModel({
    required this.idFaculte,
    required this.codeFaculte,
    required this.nomFaculte,
    this.description,
    this.doyen,
    this.email,
    this.telephone,
    this.estActif = true,
    this.dateCreation,
    this.dateModification,
  });

  factory FaculteModel.fromJson(Map<String, dynamic> json) {
    return FaculteModel(
      idFaculte:        json['id_faculte']       as int,
      codeFaculte:      json['code_faculte']     as String,
      nomFaculte:       json['nom_faculte']      as String,
      description:      json['description']      as String?,
      doyen:            json['doyen']            as String?,
      email:            json['email']            as String?,
      telephone:        json['telephone']        as String?,
      estActif:         json['est_actif'] == true || json['est_actif'] == 1,
      dateCreation:     json['date_creation']    as String?,
      dateModification: json['date_modification'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id_faculte':        idFaculte,
        'code_faculte':      codeFaculte,
        'nom_faculte':       nomFaculte,
        'description':       description,
        'doyen':             doyen,
        'email':             email,
        'telephone':         telephone,
        'est_actif':         estActif,
        'date_creation':     dateCreation,
        'date_modification': dateModification,
      };

  @override
  String toString() => nomFaculte;
}
