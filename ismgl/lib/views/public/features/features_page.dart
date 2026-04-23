import 'package:flutter/material.dart';
class FeaturesPage extends StatelessWidget {
  const FeaturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Étudiants', 'Création, modification, recherche et dossiers.'),
      ('Inscriptions', 'Par filière, niveau, année académique et statut.'),
      ('Paiements', 'Encaissement, situation et reçus.'),
      ('Rapports', 'Tableaux de bord et étudiants endettés (selon rôle).'),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Fonctionnalités')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, index) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: Text(items[i].$1),
              subtitle: Text(items[i].$2),
            ),
          );
        },
      ),
    );
  }
}
