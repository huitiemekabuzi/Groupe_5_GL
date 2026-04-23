class AppValidators {
  static String? required(String? value, [String field = 'Ce champ']) {
    if (value == null || value.trim().isEmpty) {
      return '$field est requis';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'L\'email est requis';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value)) return 'Email invalide';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Le mot de passe est requis';
    if (value.length < 8) return 'Au moins 8 caractères';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Au moins une majuscule';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Au moins un chiffre';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return null;
    final regex = RegExp(r'^(\+243|0)[0-9]{9}$');
    if (!regex.hasMatch(value)) return 'Numéro invalide (+243XXXXXXXXX)';
    return null;
  }

  static String? numeric(String? value, [String field = 'Ce champ']) {
    if (value == null || value.isEmpty) return null;
    if (double.tryParse(value) == null) return '$field doit être numérique';
    return null;
  }

  static String? minAmount(String? value, double min) {
    if (value == null || value.isEmpty) return 'Montant requis';
    final amount = double.tryParse(value);
    if (amount == null) return 'Montant invalide';
    if (amount < min) return 'Montant minimum: $min FC';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value != password) return 'Les mots de passe ne correspondent pas';
    return null;
  }
}