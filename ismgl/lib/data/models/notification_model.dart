class NotificationModel {
  final int idNotification;
  final int idUser;
  final String titre;
  final String message;
  final String typeNotification;
  final bool estLu;
  final String? dateLecture;
  final String? lien;
  final String? dateCreation;

  NotificationModel({
    required this.idNotification,
    required this.idUser,
    required this.titre,
    required this.message,
    this.typeNotification = 'Info',
    this.estLu = false,
    this.dateLecture,
    this.lien,
    this.dateCreation,
  });

  static int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  static String _asString(dynamic v) => v?.toString() ?? '';
  static bool _asBool(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v == 1;
    final s = v?.toString().trim().toLowerCase();
    return s == '1' || s == 'true' || s == 'oui' || s == 'yes';
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      idNotification:   _asInt(json['id_notification'] ?? json['id']),
      idUser:           _asInt(json['id_user']),
      titre:            _asString(json['titre'] ?? json['title'] ?? json['subject']),
      message:          _asString(json['message'] ?? json['contenu'] ?? json['body']),
      typeNotification: _asString(json['type_notification'] ?? json['type']).isEmpty
          ? 'Info'
          : _asString(json['type_notification'] ?? json['type']),
      estLu:            _asBool(json['est_lu'] ?? json['is_read'] ?? json['lu']),
      dateLecture:      (json['date_lecture'] ?? json['read_at'])?.toString(),
      lien:             json['lien'] as String?,
      dateCreation:     (json['date_creation'] ?? json['created_at'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id_notification':   idNotification,
        'id_user':           idUser,
        'titre':             titre,
        'message':           message,
        'type_notification': typeNotification,
        'est_lu':            estLu,
        'date_lecture':      dateLecture,
        'lien':              lien,
        'date_creation':     dateCreation,
      };
}