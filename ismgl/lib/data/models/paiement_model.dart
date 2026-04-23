class PaiementModel {
  final int idPaiement;
  final String numeroPaiement;
  final int idInscription;
  final int idEtudiant;
  final int idTypeFrais;
  final int idModePaiement;
  final double montant;
  final String? datePaiement;
  final String? referenceTransaction;
  final int recuPar;
  final String statutPaiement;
  final String? motifAnnulation;
  final int? annulePar;
  final String? dateAnnulation;
  final String? notes;
  final String? dateCreation;
  final String? dateModification;

  // Champs joints (vues API)
  final String? numeroEtudiant;
  final String? nomCompletEtudiant;
  final String? numeroInscription;
  final String? nomFrais;
  final String? modePaiement;
  final String? recuParNom;
  final String? numeroRecu;

  PaiementModel({
    required this.idPaiement,
    required this.numeroPaiement,
    required this.idInscription,
    required this.idEtudiant,
    required this.idTypeFrais,
    required this.idModePaiement,
    required this.montant,
    this.datePaiement,
    this.referenceTransaction,
    required this.recuPar,
    this.statutPaiement = 'Validé',
    this.motifAnnulation,
    this.annulePar,
    this.dateAnnulation,
    this.notes,
    this.dateCreation,
    this.dateModification,
    this.numeroEtudiant,
    this.nomCompletEtudiant,
    this.numeroInscription,
    this.nomFrais,
    this.modePaiement,
    this.recuParNom,
    this.numeroRecu,
  });

  factory PaiementModel.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '0') ?? 0;
    String asString(dynamic v) => v?.toString() ?? '';
    return PaiementModel(
      idPaiement:           asInt(json['id_paiement']),
      numeroPaiement:       asString(json['numero_paiement']),
      idInscription:        asInt(json['id_inscription']),
      idEtudiant:           asInt(json['id_etudiant']),
      idTypeFrais:          asInt(json['id_type_frais']),
      idModePaiement:       asInt(json['id_mode_paiement']),
      montant:              double.tryParse(json['montant']?.toString() ?? '0') ?? 0,
      datePaiement:         json['date_paiement']        as String?,
      referenceTransaction: json['reference_transaction'] as String?,
      recuPar:              asInt(json['recu_par']),
      statutPaiement:       json['statut_paiement']      as String? ?? 'Validé',
      motifAnnulation:      json['motif_annulation']     as String?,
      annulePar:            json['annule_par']           as int?,
      dateAnnulation:       json['date_annulation']      as String?,
      notes:                json['notes']                as String?,
      dateCreation:         json['date_creation']        as String?,
      dateModification:     json['date_modification']    as String?,
      numeroEtudiant:       json['numero_etudiant']      as String?,
      nomCompletEtudiant:   json['nom_complet_etudiant'] as String?,
      numeroInscription:    json['numero_inscription']   as String?,
      nomFrais:             json['nom_frais']            as String?,
      modePaiement:         json['mode_paiement']        as String?,
      recuParNom:           json['recu_par_nom']         as String?,
      numeroRecu:           json['numero_recu']          as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id_paiement':          idPaiement,
        'numero_paiement':      numeroPaiement,
        'id_inscription':       idInscription,
        'id_etudiant':          idEtudiant,
        'id_type_frais':        idTypeFrais,
        'id_mode_paiement':     idModePaiement,
        'montant':              montant,
        'date_paiement':        datePaiement,
        'reference_transaction': referenceTransaction,
        'recu_par':             recuPar,
        'statut_paiement':      statutPaiement,
        'motif_annulation':     motifAnnulation,
        'notes':                notes,
      };

  bool get estValide    => statutPaiement == 'Validé';
  bool get estAnnule    => statutPaiement == 'Annulé';
  bool get estRembourse => statutPaiement == 'Remboursé';
}