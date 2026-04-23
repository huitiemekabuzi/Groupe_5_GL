import 'package:ismgl/data/models/user_model.dart';

class AuthResponse {
  final String    token;
  final String    refreshToken;
  final int       expiresIn;
  final UserModel user;

  AuthResponse({
    required this.token,
    required this.refreshToken,
    required this.expiresIn,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    print('🔍 AuthResponse.fromJson() - Input: $json');
    
    // Essayer plusieurs formats possibles de clés
    final String token = json['token'] as String? ?? 
                         json['access_token'] as String? ?? 
                         '';
    
    final String refreshToken = json['refresh_token'] as String? ?? 
                                json['refreshToken'] as String? ?? 
                                '';
    
    final int expiresIn = json['expires_in'] as int? ?? 
                          json['expiresIn'] as int? ?? 
                          86400;
    
    // Essayer plusieurs formats pour l'utilisateur
    Map<String, dynamic> userData = json['user'] as Map<String, dynamic>? ?? 
                                    json['data'] as Map<String, dynamic>? ?? 
                                    {};
    
    // Si user est aussi imbriqué
    if (userData.isEmpty && json.containsKey('data') && json['data'] is Map) {
      userData = (json['data'] as Map<String, dynamic>)['user'] as Map<String, dynamic>? ?? {};
    }

    print('   Token extrait: ${token.isNotEmpty ? "✅ ${token.substring(0, 30)}..." : "❌ vide"}');
    print('   Refresh token: ${refreshToken.isNotEmpty ? "✅ présent" : "❌ vide"}');
    print('   Expires in: $expiresIn sec');
    print('   User data: $userData');

    return AuthResponse(
      token:        token,
      refreshToken: refreshToken,
      expiresIn:    expiresIn,
      user:         UserModel.fromJson(userData),
    );
  }
}