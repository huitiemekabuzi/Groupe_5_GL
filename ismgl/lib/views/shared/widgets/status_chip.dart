import 'package:flutter/material.dart';
import 'package:ismgl/core/utils/helpers.dart';

class StatusChip extends StatelessWidget {
  final String status;
  final String type; // 'inscription' | 'paiement' | 'etudiant'

  const StatusChip({super.key, required this.status, this.type = 'inscription'});

  @override
  Widget build(BuildContext context) {
    final color = type == 'paiement'
        ? AppHelpers.getStatutPaiementColor(status)
        : AppHelpers.getStatutInscriptionColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 92),
        child: Text(
          status,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
