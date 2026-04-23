import 'package:get/get.dart';
import 'package:ismgl/app/routes/app_routes.dart';
import 'package:ismgl/core/services/api_service.dart';
import 'package:ismgl/core/services/storage_service.dart';
import 'package:ismgl/data/models/user_model.dart';
import 'package:ismgl/data/responses/auth_response.dart';

class AuthService extends GetxService {
  final ApiService     _api     = Get.find<ApiService>();
  final StorageService _storage = Get.find<StorageService>();

  // ── Connexion ──────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> login(String email, String password) async {
    // Always clear the previous local session before a new login attempt.
    // This prevents stale token/role/user when another user connects.
    await _storage.clearSession();

    final result = await _api.post('/auth/login', data: {
      'email': email.trim(),
      'mot_de_passe': password,
    });

    print('🔍 Réponse login: $result');

    if (result['success'] == true && result['data'] != null) {
      try {
        final data = result['data'] as Map<String, dynamic>;
        print('📦 Data reçue: $data');
        
        final response = AuthResponse.fromJson(data);
        
        // Vérification du token
        if (response.token.isEmpty) {
          print('❌ ERREUR: Token vide reçu du serveur');
          print('   token: "${response.token}"');
          print('   refreshToken: "${response.refreshToken}"');
          print('   expiresIn: ${response.expiresIn}');
          return {
            'success': false,
            'message': 'Erreur serveur: Token absent',
          };
        }

        print('✅ Token reçu: ${response.token.substring(0, 30)}...');
        
        // Sauvegarder le token
        await _storage.saveToken(response.token);
        print('✅ Token sauvegardé dans SharedPreferences');
        
        final savedToken = _storage.getToken();
        print('✅ Token vérifié après sauvegarde: ${savedToken?.substring(0, 30)}...');
        
        if (response.refreshToken.isNotEmpty) {
          await _storage.saveRefreshToken(response.refreshToken);
        }
        await _storage.saveTokenExpiry(
          DateTime.now().add(Duration(seconds: response.expiresIn)),
        );
        
        await _saveUserToStorage(response.user);
        print('✅ Données utilisateur sauvegardées');
      } catch (e) {
        print('❌ Erreur parsing réponse: $e');
        return {
          'success': false,
          'message': 'Erreur parsing: $e',
        };
      }
    } else {
      print('❌ Connexion échouée: ${result['message']}');
    }
    return result;
  }

  // ── Déconnexion ────────────────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      await _api.post('/auth/logout', data: {});
    } catch (_) {}
    await _storage.clearAll();
    Get.offAllNamed(AppRoutes.login);
  }

  // ── Profil connecté ────────────────────────────────────────────────────────
  Future<UserModel?> getMe() async {
    final result = await _api.get('/auth/me');
    if (result['success'] == true && result['data'] != null) {
      final user = UserModel.fromJson(result['data'] as Map<String, dynamic>);
      await _saveUserToStorage(user);
      return user;
    }
    return null;
  }

  // ── Changer mot de passe ───────────────────────────────────────────────────
  Future<Map<String, dynamic>> changePassword({
    required String ancienMotDePasse,
    required String nouveauMotDePasse,
    required String confirmationMotDePasse,
  }) async {
    return _api.post('/auth/change-password', data: {
      'ancien_mot_de_passe':       ancienMotDePasse,
      'nouveau_mot_de_passe':      nouveauMotDePasse,
      'confirmation_mot_de_passe': confirmationMotDePasse,
    });
  }

  // ── Mot de passe oublié ────────────────────────────────────────────────────
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    return _api.post('/auth/forgot-password', data: {'email': email});
  }

  // ── Réinitialiser mot de passe ─────────────────────────────────────────────
  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String nouveauMotDePasse,
    required String confirmationMotDePasse,
  }) async {
    return _api.post('/auth/reset-password', data: {
      'token':                     token,
      'nouveau_mot_de_passe':      nouveauMotDePasse,
      'confirmation_mot_de_passe': confirmationMotDePasse,
    });
  }

  // ── Helpers internes ───────────────────────────────────────────────────────
  Future<void> _saveUserToStorage(UserModel user) async {
    await _storage.saveUser(
      id:         user.id,
      nom:        user.nom,
      prenom:     user.prenom,
      email:      user.email,
      role:       user.nomRole,
      roleId:     user.idRole,
      matricule:  user.matricule,
      telephone:  user.telephone,
      photo:      user.photoProfil,
    );
  }

  // ── Getters publics ────────────────────────────────────────────────────────
  bool get isLoggedIn => _storage.getToken() != null;

  String? get currentRole => _storage.getUserRole();

  void redirectToDashboard() {
    final role = currentRole;
    if (role != null) {
      Get.offAllNamed(_getDashboardRoute(role));
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  String _getDashboardRoute(String role) {
    switch (role) {
      case 'Administrateur': return AppRoutes.adminDashboard;
      case 'Caissier':       return AppRoutes.caissierDashboard;
      case 'Gestionnaire':   return AppRoutes.gestionDashboard;
      case 'Etudiant':       return AppRoutes.etudiantDashboard;
      case 'Comptable':      return AppRoutes.adminRapports;
      default:               return AppRoutes.login;
    }
  }
}