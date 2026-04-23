import 'package:ismgl/data/models/permission_model.dart';

class UserModel {
  final int id;
  final String matricule;
  final String nom;
  final String prenom;
  final String email;
  final String? telephone;
  final int idRole;
  final String nomRole;
  final String? photoProfil;
  final bool estActif;
  final bool compteBloque;
  final String? derniereConnexion;
  final String? dateCreation;
  final String? dateModification;
  final List<PermissionModel> permissions;

  UserModel({
    required this.id,
    required this.matricule,
    required this.nom,
    required this.prenom,
    required this.email,
    this.telephone,
    required this.idRole,
    required this.nomRole,
    this.photoProfil,
    this.estActif = true,
    this.compteBloque = false,
    this.derniereConnexion,
    this.dateCreation,
    this.dateModification,
    this.permissions = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Gérer rôle imbriqué (format login) ou aplati (format liste)
    final roleMap = json['role'] as Map<String, dynamic>?;

    return UserModel(
      id:                 json['id_user']              as int? ??
                          json['id']                   as int? ?? 0,
      matricule:          json['matricule']             as String? ?? '',
      nom:                json['nom']                  as String,
      prenom:             json['prenom']               as String,
      email:              json['email']                as String,
      telephone:          json['telephone']            as String?,
      idRole:             roleMap?['id']               as int? ??
                          json['id_role']              as int? ?? 0,
      nomRole:            roleMap?['nom']              as String? ??
                          json['nom_role']             as String? ?? '',
      photoProfil:        json['photo_profil']         as String?,
      estActif:           json['est_actif'] == true || json['est_actif'] == 1,
      compteBloque:       json['compte_bloque'] == true || json['compte_bloque'] == 1,
      derniereConnexion:  json['derniere_connexion']   as String?,
      dateCreation:       json['date_creation']        as String?,
      dateModification:   json['date_modification']    as String?,
      permissions: (json['permissions'] as List<dynamic>?)
              ?.map((p) => PermissionModel.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id_user':             id,
        'matricule':           matricule,
        'nom':                 nom,
        'prenom':              prenom,
        'email':               email,
        'telephone':           telephone,
        'id_role':             idRole,
        'nom_role':            nomRole,
        'photo_profil':        photoProfil,
        'est_actif':           estActif,
        'compte_bloque':       compteBloque,
        'derniere_connexion':  derniereConnexion,
        'date_creation':       dateCreation,
      };

  String get fullName => '$prenom $nom';
  String get initials {
    final p = prenom.isNotEmpty ? prenom[0] : '';
    final n = nom.isNotEmpty    ? nom[0]    : '';
    return '$p$n'.toUpperCase();
  }

  bool hasPermission(String codePermission) =>
      permissions.any((p) => p.codePermission == codePermission);
}