class ModePaiementModel {
  final int idModePaiement;
  final String codeMode;
  final String nomMode;
  final String? description;
  final bool estActif;
  final String? dateCreation;

  ModePaiementModel({
    required this.idModePaiement,
    required this.codeMode,
    required this.nomMode,
    this.description,
    this.estActif = true,
    this.dateCreation,
  });

  factory ModePaiementModel.fromJson(Map<String, dynamic> json) {
    return ModePaiementModel(
      idModePaiement: json['id_mode_paiement'] as int,
      codeMode:       json['code_mode']        as String,
      nomMode:        json['nom_mode']         as String,
      description:    json['description']      as String?,
      estActif:       json['est_actif'] == true || json['est_actif'] == 1,
      dateCreation:   json['date_creation']    as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id_mode_paiement': idModePaiement,
        'code_mode':        codeMode,
        'nom_mode':         nomMode,
        'description':      description,
        'est_actif':        estActif,
      };

  @override
  String toString() => nomMode;
}
