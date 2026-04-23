import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ismgl/app/themes/app_theme.dart';
import 'package:ismgl/controllers/etudiant_controller.dart';
import 'package:ismgl/data/models/etudiant_model.dart';

class EtudiantDetailPage extends StatelessWidget {
  const EtudiantDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<EtudiantController>();
    final int id = Get.arguments as int? ?? 0;

    // Charger le détail si pas déjà chargé
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ctrl.selectedEtudiant.value?.idEtudiant != id) {
        ctrl.loadDetail(id);
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Détail Étudiant'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Obx(() {
            final e = ctrl.selectedEtudiant.value;
            if (e == null) return const SizedBox();
            return PopupMenuButton<String>(
              onSelected: (val) => _onAction(context, val, e, ctrl),
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'actif',    child: Text('Activer/Désactiver')),
                const PopupMenuItem(value: 'suspendu', child: Text('Suspendre')),
                const PopupMenuItem(value: 'diplome',  child: Text('Marquer diplômé')),
              ],
            );
          }),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final e = ctrl.selectedEtudiant.value;
        if (e == null) {
          return const Center(child: Text('Étudiant introuvable'));
        }
        return _Body(etudiant: e, ctrl: ctrl);
      }),
    );
  }

  void _onAction(BuildContext ctx, String action, EtudiantModel e,
      EtudiantController ctrl) {
    final statutMap = {
      'actif':    e.statut == 'Actif' ? 'Suspendu' : 'Actif',
      'suspendu': 'Suspendu',
      'diplome':  'Diplômé',
    };
    ctrl.updateStatut(e, statutMap[action] ?? e.statut);
  }
}

class _Body extends StatelessWidget {
  final EtudiantModel etudiant;
  final EtudiantController ctrl;
  const _Body({required this.etudiant, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Header(etudiant: etudiant),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Informations personnelles',
          icon: Icons.person_outline,
          children: [
            _InfoRow('Numéro étudiant', etudiant.numeroEtudiant),
            _InfoRow('Matricule',        etudiant.matricule),
            _InfoRow('Nom complet',      etudiant.fullName),
            _InfoRow('Email',            etudiant.email),
            _InfoRow('Téléphone',        etudiant.telephone ?? '—'),
            _InfoRow('Date naissance',   etudiant.dateNaissance),
            _InfoRow('Lieu naissance',   etudiant.lieuNaissance ?? '—'),
            _InfoRow('Sexe',             etudiant.sexe == 'M' ? 'Masculin' : 'Féminin'),
            _InfoRow('Nationalité',      etudiant.nationalite ?? '—'),
            _InfoRow('Groupe sanguin',   etudiant.groupeSanguin ?? '—'),
          ],
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Adresse',
          icon: Icons.location_on_outlined,
          children: [
            _InfoRow('Adresse',  etudiant.adresse ?? '—'),
            _InfoRow('Ville',    etudiant.ville    ?? '—'),
            _InfoRow('Province', etudiant.province ?? '—'),
          ],
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Famille & Urgence',
          icon: Icons.family_restroom,
          children: [
            _InfoRow('Père',               etudiant.nomPere          ?? '—'),
            _InfoRow('Mère',               etudiant.nomMere          ?? '—'),
            _InfoRow('Tél. urgence',        etudiant.telephoneUrgence ?? '—'),
          ],
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Statut académique',
          icon: Icons.school_outlined,
          children: [
            _InfoRow('Statut',          etudiant.statut),
            _InfoRow('1ère inscription', etudiant.datePremierInscription ?? '—'),
          ],
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final EtudiantModel etudiant;
  const _Header({required this.etudiant});

  @override
  Widget build(BuildContext context) {
    final statusColor = etudiant.statut == 'Actif'
        ? AppTheme.success
        : etudiant.statut == 'Suspendu'
            ? AppTheme.warning
            : etudiant.statut == 'Diplômé'
                ? AppTheme.info
                : AppTheme.error;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Text(
              etudiant.fullName.isNotEmpty
                  ? etudiant.fullName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Text(etudiant.fullName,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          Text(etudiant.email,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8))),
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor, width: 1),
            ),
            child: Text(etudiant.statut,
                style: TextStyle(color: statusColor, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _SectionCard(
      {required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: AppTheme.primary, size: 18),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
            ]),
            const Divider(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
