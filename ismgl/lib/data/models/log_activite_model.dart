class LogActiviteModel {
  final int idLog;
  final int? idUser;
  final String? utilisateur;
  final String action;
  final String module;
  final String? description;
  final String? ipAddress;
  final String? userAgent;
  final dynamic donneesAvant;
  final dynamic donneesApres;
  final String dateAction;

  LogActiviteModel({
    required this.idLog,
    this.idUser,
    this.utilisateur,
    required this.action,
    required this.module,
    this.description,
    this.ipAddress,
    this.userAgent,
    this.donneesAvant,
    this.donneesApres,
    required this.dateAction,
  });

  factory LogActiviteModel.fromJson(Map<String, dynamic> json) {
    return LogActiviteModel(
      idLog:         json['id_log']       as int,
      idUser:        json['id_user']      as int?,
      utilisateur:   json['utilisateur']  as String?,
      action:        json['action']       as String,
      module:        json['module']       as String,
      description:   json['description'] as String?,
      ipAddress:     json['ip_address']  as String?,
      userAgent:     json['user_agent']  as String?,
      donneesAvant:  json['donnees_avant'],
      donneesApres:  json['donnees_apres'],
      dateAction:    json['date_action'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id_log':       idLog,
        'id_user':      idUser,
        'action':       action,
        'module':       module,
        'description':  description,
        'ip_address':   ipAddress,
        'date_action':  dateAction,
      };
}
