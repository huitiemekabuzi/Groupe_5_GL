import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // Keys
  static const _tokenKey        = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey       = 'user_id';
  static const _userNomKey      = 'user_nom';
  static const _userPrenomKey   = 'user_prenom';
  static const _userEmailKey    = 'user_email';
  static const _userRoleKey     = 'user_role';
  static const _userRoleIdKey   = 'user_role_id';
  static const _userMatriculeKey = 'user_matricule';
  static const _userTelephoneKey = 'user_telephone';
  static const _userPhotoKey    = 'user_photo';
  static const _themeKey        = 'theme_mode';
  static const _etudiantIdKey   = 'etudiant_id';
  static const _tokenExpiryKey  = 'token_expiry';

  // Token
  Future<void> saveToken(String token) => _prefs.setString(_tokenKey, token.trim());
  String? getToken() => _prefs.getString(_tokenKey)?.trim();
  Future<void> removeToken() => _prefs.remove(_tokenKey);

  // Refresh Token
  Future<void> saveRefreshToken(String token) =>
      _prefs.setString(_refreshTokenKey, token.trim());
  String? getRefreshToken() => _prefs.getString(_refreshTokenKey)?.trim();

  // Token Expiry
  Future<void> saveTokenExpiry(DateTime expiry) =>
      _prefs.setString(_tokenExpiryKey, expiry.toIso8601String());
  DateTime? getTokenExpiry() {
    final s = _prefs.getString(_tokenExpiryKey);
    return s != null ? DateTime.tryParse(s) : null;
  }

  bool isTokenExpired() {
    final expiry = getTokenExpiry();
    if (expiry == null) return true;
    return DateTime.now().isAfter(expiry.subtract(const Duration(minutes: 5)));
  }

  // User Info
  Future<void> saveUser({
    required int id,
    required String nom,
    required String prenom,
    required String email,
    required String role,
    required int roleId,
    required String matricule,
    String? telephone,
    String? photo,
    int? etudiantId,
  }) async {
    await Future.wait([
      _prefs.setInt(_userIdKey, id),
      _prefs.setString(_userNomKey, nom),
      _prefs.setString(_userPrenomKey, prenom),
      _prefs.setString(_userEmailKey, email),
      _prefs.setString(_userRoleKey, role),
      _prefs.setInt(_userRoleIdKey, roleId),
      _prefs.setString(_userMatriculeKey, matricule),
      if (telephone != null) _prefs.setString(_userTelephoneKey, telephone),
      if (photo != null) _prefs.setString(_userPhotoKey, photo),
      if (etudiantId != null) _prefs.setInt(_etudiantIdKey, etudiantId),
    ]);
  }

  int? getUserId()       => _prefs.getInt(_userIdKey);
  String? getUserNom()   => _prefs.getString(_userNomKey);
  String? getUserPrenom() => _prefs.getString(_userPrenomKey);
  String? getUserEmail() => _prefs.getString(_userEmailKey);
  String? getUserRole()  => _prefs.getString(_userRoleKey);
  int? getUserRoleId()   => _prefs.getInt(_userRoleIdKey);
  String? getMatricule() => _prefs.getString(_userMatriculeKey);
  String? getUserTelephone() => _prefs.getString(_userTelephoneKey);
  String? getUserPhoto() => _prefs.getString(_userPhotoKey);
  int? getEtudiantId()   => _prefs.getInt(_etudiantIdKey);

  String get userFullName {
    final nom    = getUserNom() ?? '';
    final prenom = getUserPrenom() ?? '';
    return '$prenom $nom'.trim();
  }

  // Theme
  Future<void> saveTheme(String theme) => _prefs.setString(_themeKey, theme);
  String? getTheme() => _prefs.getString(_themeKey);

  // Clear all
  Future<void> clearAll() => _prefs.clear();

  Future<void> clearSession() async {
    final keys = [_tokenKey, _refreshTokenKey, _tokenExpiryKey, _userIdKey,
                  _userNomKey, _userPrenomKey, _userEmailKey, _userRoleKey,
                  _userRoleIdKey, _userMatriculeKey, _userTelephoneKey, _userPhotoKey, _etudiantIdKey];
    await Future.wait(keys.map((k) => _prefs.remove(k)));
  }

  bool get isLoggedIn {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }
}