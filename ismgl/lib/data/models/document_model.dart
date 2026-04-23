class DocumentModel {
  final int idDocument;
  final int idEtudiant;
  final String typeDocument;
  final String nomFichier;
  final String cheminFichier;
  final int? tailleFichier;
  final String? extension;
  final int? telechargepar;
  final String? dateUpload;

  DocumentModel({
    required this.idDocument,
    required this.idEtudiant,
    required this.typeDocument,
    required this.nomFichier,
    required this.cheminFichier,
    this.tailleFichier,
    this.extension,
    this.telechargepar,
    this.dateUpload,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      idDocument:    json['id_document']   as int,
      idEtudiant:    json['id_etudiant']   as int,
      typeDocument:  json['type_document'] as String,
      nomFichier:    json['nom_fichier']   as String,
      cheminFichier: json['chemin_fichier'] as String,
      tailleFichier: json['taille_fichier'] as int?,
      extension:     json['extension']     as String?,
      telechargepar: json['telecharge_par'] as int?,
      dateUpload:    json['date_upload']   as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id_document':   idDocument,
        'id_etudiant':   idEtudiant,
        'type_document': typeDocument,
        'nom_fichier':   nomFichier,
        'chemin_fichier': cheminFichier,
        'taille_fichier': tailleFichier,
        'extension':     extension,
      };
}
