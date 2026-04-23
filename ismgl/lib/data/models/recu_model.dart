class RecuModel {
  final int idRecu;
  final String numeroRecu;
  final int idPaiement;
  final int idEtudiant;
  final double montantTotal;
  final String dateEmission;
  final int emisPar;
  final String? fichierPdf;
  final bool estImprime;
  final String? dateImpression;
  final int nombreImpressions;
  final String? dateCreation;

  // Champs joints (vues API)
  final String? numeroPaiement;
  final String? datePaiement;
  final String? numeroEtudiant;
  final String? nomCompletEtudiant;
  final String? email;
  final String? nomFrais;
  final String? modePaiement;
  final String? referenceTransaction;
  final String? numeroInscription;
  final String? nomFiliere;
  final String? nomNiveau;
  final String? codeAnnee;
  final String? emisParNom;
  final String? pdfUrl;

  RecuModel({
    required this.idRecu,
    required this.numeroRecu,
    required this.idPaiement,
    required this.idEtudiant,
    required this.montantTotal,
    required this.dateEmission,
    required this.emisPar,
    this.fichierPdf,
    this.estImprime = false,
    this.dateImpression,
    this.nombreImpressions = 0,
    this.dateCreation,
    this.numeroPaiement,
    this.datePaiement,
    this.numeroEtudiant,
    this.nomCompletEtudiant,
    this.email,
    this.nomFrais,
    this.modePaiement,
    this.referenceTransaction,
    this.numeroInscription,
    this.nomFiliere,
    this.nomNiveau,
    this.codeAnnee,
    this.emisParNom,
    this.pdfUrl,
  });

  factory RecuModel.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '0') ?? 0;
    String asString(dynamic v) => v?.toString() ?? '';
    return RecuModel(
      idRecu:               asInt(json['id_recu']),
      numeroRecu:           asString(json['numero_recu']),
      idPaiement:           asInt(json['id_paiement']),
      idEtudiant:           asInt(json['id_etudiant']),
      montantTotal:         double.tryParse(json['montant_total']?.toString() ?? '0') ?? 0,
      dateEmission:         asString(json['date_emission']),
      emisPar:              asInt(json['emis_par']),
      fichierPdf:           json['fichier_pdf']          as String?,
      estImprime:           json['est_imprime'] == true || json['est_imprime'] == 1,
      dateImpression:       json['date_impression']      as String?,
      nombreImpressions:    asInt(json['nombre_impressions']),
      dateCreation:         json['date_creation']        as String?,
      numeroPaiement:       json['numero_paiement']      as String?,
      datePaiement:         json['date_paiement']        as String?,
      numeroEtudiant:       json['numero_etudiant']      as String?,
      nomCompletEtudiant:   json['nom_complet_etudiant'] as String?,
      email:                json['email']                as String?,
      nomFrais:             json['nom_frais']            as String?,
      modePaiement:         json['mode_paiement']        as String?,
      referenceTransaction: json['reference_transaction'] as String?,
      numeroInscription:    json['numero_inscription']   as String?,
      nomFiliere:           json['nom_filiere']          as String?,
      nomNiveau:            json['nom_niveau']           as String?,
      codeAnnee:            json['code_annee']           as String?,
      emisParNom:           json['emis_par_nom']         as String?,
      pdfUrl:               json['pdf_url']              as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id_recu':          idRecu,
        'numero_recu':      numeroRecu,
        'id_paiement':      idPaiement,
        'id_etudiant':      idEtudiant,
        'montant_total':    montantTotal,
        'date_emission':    dateEmission,
        'emis_par':         emisPar,
        'est_imprime':      estImprime,
        'nombre_impressions': nombreImpressions,
      };
}
