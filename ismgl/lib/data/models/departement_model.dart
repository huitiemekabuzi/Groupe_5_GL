class DepartementModel {
  final int idDepartement;
  final String codeDepartement;
  final String nomDepartement;
  final int idFaculte;
  final String? nomFaculte;
  final String? chefDepartement;
  final String? email;
  final String? telephone;
  final bool estActif;
  final String? dateCreation;
  final String? dateModification;

  DepartementModel({
    required this.idDepartement,
    required this.codeDepartement,
    required this.nomDepartement,
    required this.idFaculte,
    this.nomFaculte,
    this.chefDepartement,
    this.email,
    this.telephone,
    this.estActif = true,
    this.dateCreation,
    this.dateModification,
  });

  factory DepartementModel.fromJson(Map<String, dynamic> json) {
    return DepartementModel(
      idDepartement:    json['id_departement']    as int,
      codeDepartement:  json['code_departement']  as String,
      nomDepartement:   json['nom_departement']   as String,
      idFaculte:        json['id_faculte']        as int,
      nomFaculte:       json['nom_faculte']       as String?,
      chefDepartement:  json['chef_departement']  as String?,
      email:            json['email']             as String?,
      telephone:        json['telephone']         as String?,
      estActif:         json['est_actif'] == true || json['est_actif'] == 1,
      dateCreation:     json['date_creation']     as String?,
      dateModification: json['date_modification'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id_departement':    idDepartement,
        'code_departement':  codeDepartement,
        'nom_departement':   nomDepartement,
        'id_faculte':        idFaculte,
        'chef_departement':  chefDepartement,
        'email':             email,
        'telephone':         telephone,
        'est_actif':         estActif,
      };

  @override
  String toString() => nomDepartement;
}
