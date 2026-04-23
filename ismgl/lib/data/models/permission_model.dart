class PermissionModel {
  final int idPermission;
  final String nomPermission;
  final String codePermission;
  final String module;
  final String? description;
  final String? dateCreation;

  PermissionModel({
    required this.idPermission,
    required this.nomPermission,
    required this.codePermission,
    required this.module,
    this.description,
    this.dateCreation,
  });

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      idPermission:    json['id_permission']   as int,
      nomPermission:   json['nom_permission']  as String,
      codePermission:  json['code_permission'] as String,
      module:          json['module']          as String,
      description:     json['description']     as String?,
      dateCreation:    json['date_creation']   as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id_permission':   idPermission,
        'nom_permission':  nomPermission,
        'code_permission': codePermission,
        'module':          module,
        'description':     description,
        'date_creation':   dateCreation,
      };

  @override
  String toString() => nomPermission;
}
