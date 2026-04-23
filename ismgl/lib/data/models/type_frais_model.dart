class TypeFraisModel {
  final int idTypeFrais;
  final String codeFrais;
  final String nomFrais;
  final String? description;
  final double montantBase;
  final bool estObligatoire;
  final bool estActif;
  final String? dateCreation;
  final String? dateModification;

  TypeFraisModel({
    required this.idTypeFrais,
    required this.codeFrais,
    required this.nomFrais,
    this.description,
    required this.montantBase,
    this.estObligatoire = true,
    this.estActif = true,
    this.dateCreation,
    this.dateModification,
  });

  factory TypeFraisModel.fromJson(Map<String, dynamic> json) {
    return TypeFraisModel(
      idTypeFrais:      json['id_type_frais']   as int,
      codeFrais:        json['code_frais']      as String,
      nomFrais:         json['nom_frais']       as String,
      description:      json['description']     as String?,
      montantBase:      double.tryParse(json['montant_base']?.toString() ?? '0') ?? 0,
      estObligatoire:   json['est_obligatoire'] == true || json['est_obligatoire'] == 1,
      estActif:         json['est_actif'] == true || json['est_actif'] == 1,
      dateCreation:     json['date_creation']   as String?,
      dateModification: json['date_modification'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id_type_frais':   idTypeFrais,
        'code_frais':      codeFrais,
        'nom_frais':       nomFrais,
        'description':     description,
        'montant_base':    montantBase,
        'est_obligatoire': estObligatoire,
        'est_actif':       estActif,
      };

  @override
  String toString() => nomFrais;
}
