import 'package:flutter/material.dart';
import 'package:ismgl/app/themes/app_theme.dart';

class RoleBadge extends StatelessWidget {
  final String role;

  const RoleBadge({super.key, required this.role});

  Color _getColor() {
    switch (role) {
      case 'Administrateur': return AppTheme.error;
      case 'Caissier':       return AppTheme.success;
      case 'Gestionnaire':   return AppTheme.warning;
      case 'Etudiant':       return AppTheme.primary;
      case 'Comptable':      return AppTheme.info;
      default:               return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 110),
        child: Text(
          role,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
