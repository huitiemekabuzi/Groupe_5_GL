class RoleModel {
  final int idRole;
  final String nomRole;
  final String? description;
  final bool estActif;
  final String? dateCreation;
  final String? dateModification;

  RoleModel({
    required this.idRole,
    required this.nomRole,
    this.description,
    this.estActif = true,
    this.dateCreation,
    this.dateModification,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      idRole:           json['id_role']          as int,
      nomRole:          json['nom_role']          as String,
      description:      json['description']       as String?,
      estActif:         json['est_actif'] == true || json['est_actif'] == 1,
      dateCreation:     json['date_creation']     as String?,
      dateModification: json['date_modification'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id_role':          idRole,
        'nom_role':         nomRole,
        'description':      description,
        'est_actif':        estActif,
        'date_creation':    dateCreation,
        'date_modification': dateModification,
      };

  @override
  String toString() => nomRole;
}
