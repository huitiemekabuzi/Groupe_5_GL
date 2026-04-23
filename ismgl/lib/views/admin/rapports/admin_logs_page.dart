import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ismgl/app/themes/app_theme.dart';
import 'package:ismgl/controllers/rapport_controller.dart';

class AdminLogsPage extends StatefulWidget {
  const AdminLogsPage({super.key});

  @override
  State<AdminLogsPage> createState() => _AdminLogsPageState();
}

class _AdminLogsPageState extends State<AdminLogsPage> {
  final RapportController _ctrl = Get.find<RapportController>();
  String? _selectedModule;

  final _modules = [
    'Tous les modules',
    'Utilisateurs',
    'Etudiants',
    'Inscriptions',
    'Paiements',
    'Configuration',
    'Rapports',
  ];

  @override
  void initState() {
    super.initState();
    _ctrl.loadLogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Logs d\'activité'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filtre module
          Container(
            color: AppTheme.primary,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DropdownButtonFormField<String>(
              initialValue: _selectedModule,
              dropdownColor: AppTheme.cardLight,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.15),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.filter_list, color: Colors.white),
              ),
              hint: const Text('Filtrer par module',
                  style: TextStyle(color: Colors.white70)),
              items: _modules
                  .map((m) => DropdownMenuItem(
                        value: m == 'Tous les modules' ? null : m,
                        child: Text(m),
                      ))
                  .toList(),
              onChanged: (val) {
                setState(() => _selectedModule = val);
                _ctrl.loadLogs(module: val);
              },
            ),
          ),
          Expanded(
            child: Obx(() {
              if (_ctrl.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              final logs = _ctrl.logsItems;
              if (logs.isEmpty) {
                return const Center(
                    child: Text('Aucun log disponible',
                        style: TextStyle(color: AppTheme.textSecondary)));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: logs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _LogTile(log: logs[i]),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  final Map<String, dynamic> log;
  const _LogTile({required this.log});

  Color get _moduleColor {
    switch (log['module'] as String? ?? '') {
      case 'Paiements':    return AppTheme.success;
      case 'Inscriptions': return AppTheme.secondary;
      case 'Etudiants':    return AppTheme.info;
      case 'Utilisateurs': return AppTheme.warning;
      default:             return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final module = log['module'] as String? ?? '—';
    final action = log['action'] as String? ?? '—';
    final user   = log['utilisateur'] as String? ?? 'Système';
    final date   = log['date_action'] as String? ?? '';
    final desc   = log['description'] as String? ?? '';

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: _moduleColor.withValues(alpha: 0.3)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _moduleColor.withValues(alpha: 0.1),
          child: Icon(Icons.history, color: _moduleColor, size: 20),
        ),
        title: Text(action,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(desc, style: const TextStyle(fontSize: 12), maxLines: 2),
            const SizedBox(height: 2),
            Row(children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _moduleColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(module,
                    style: TextStyle(
                        fontSize: 10,
                        color: _moduleColor,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Text('• $user', style: const TextStyle(fontSize: 11)),
            ]),
          ],
        ),
        trailing: Text(date,
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        isThreeLine: true,
      ),
    );
  }
}
