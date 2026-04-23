import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ismgl/app/routes/app_routes.dart';
import 'package:ismgl/app/themes/app_theme.dart';
import 'package:ismgl/controllers/auth_controller.dart';
import 'package:ismgl/core/services/storage_service.dart';
import 'package:ismgl/core/services/api_service.dart';
import 'package:ismgl/core/utils/helpers.dart';
import 'package:ismgl/views/shared/widgets/custom_app_bar.dart';
import 'package:ismgl/views/shared/widgets/loading_widget.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final ApiService    _api     = Get.find<ApiService>();
  final StorageService _storage = Get.find<StorageService>();
  final AuthController _auth   = Get.find<AuthController>();

  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final result = await _api.get('/dashboard');
      if (!mounted) return;
      if (result['success'] == true) {
        setState(() => _dashboardData = result['data']);
      } else {
        AppHelpers.showError(
          result['message']?.toString() ?? 'Erreur chargement dashboard',
        );
      }
    } catch (e) {
      if (!mounted) return;
      AppHelpers.showError('Erreur chargement dashboard');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  double _asDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Dashboard Admin',
        showBack: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              final confirm = await AppHelpers.showConfirmDialog(
                title:       'Déconnexion',
                message:     'Voulez-vous vous déconnecter ?',
                confirmText: 'Déconnecter',
                confirmColor: AppTheme.error,
              );
              if (confirm) _auth.logout();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Chargement...')
          : RefreshIndicator(
              onRefresh: _loadDashboard,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeCard(),
                    const SizedBox(height: 20),
                    _buildStatsGrid(),
                    const SizedBox(height: 20),
                    _buildQuickActions(),
                    const SizedBox(height: 20),
                    _buildChartSection(),
                    const SizedBox(height: 20),
                    _buildRecentPayments(),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildWelcomeCard() {
    final stats = _dashboardData?['statistiques'] ?? {};
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 360;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    AppHelpers.getInitials(_storage.userFullName),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bonjour, ${_storage.getUserPrenom()} !',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      _storage.userFullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: compact ? 16 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _storage.getUserRole() ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${stats['paiements_aujourdhui'] ?? 0}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    'paiements\naujourd\'hui',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: compact ? 10 : 11,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsGrid() {
    final stats = _dashboardData?['statistiques'] ?? {};
    final fin   = _dashboardData?['financier'] ?? {};

    final items = [
      _StatItem('Étudiants Actifs', '${stats['total_etudiants_actifs'] ?? 0}',
          Icons.people_alt_rounded, AppTheme.primary),
      _StatItem('Inscriptions', '${stats['total_inscriptions'] ?? 0}',
          Icons.how_to_reg_rounded, AppTheme.success),
      _StatItem('Taux Recouvrement', '${fin['taux_recouvrement'] ?? 0}%',
          Icons.trending_up_rounded, AppTheme.warning),
      _StatItem('Impayés', '${_dashboardData?['etudiants_impayes_count'] ?? 0}',
          Icons.warning_amber_rounded, AppTheme.error),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 900 ? 4 : (width >= 600 ? 3 : 2);
        final cardAspectRatio = width < 360 ? 1.15 : 1.28;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: cardAspectRatio,
          ),
          itemCount: items.length,
          itemBuilder: (_, i) => _buildStatCard(items[i]),
        );
      },
    );
  }

  Widget _buildStatCard(_StatItem item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: item.color, size: 22),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item.value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: item.color,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actions Rapides',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _ActionButton('Étudiants', Icons.people_rounded, AppTheme.primary,
                  () => Get.toNamed(AppRoutes.adminEtudiants)),
              const SizedBox(width: 8),
              _ActionButton('Inscriptions', Icons.how_to_reg_rounded, AppTheme.success,
                  () => Get.toNamed(AppRoutes.adminInscriptions)),
              const SizedBox(width: 8),
              _ActionButton('Comptes', Icons.manage_accounts_rounded, AppTheme.info,
                  () => Get.toNamed(AppRoutes.adminUsers)),
              const SizedBox(width: 8),
              _ActionButton('Rapports', Icons.bar_chart_rounded, AppTheme.warning,
                  () => Get.toNamed(AppRoutes.adminRapports)),
              const SizedBox(width: 8),
              _ActionButton('Config', Icons.settings_rounded, AppTheme.info,
                  () => Get.toNamed(AppRoutes.adminConfiguration)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _ActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return SizedBox(
      width: 88,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartSection() {
    final stats = _dashboardData?['statistiques'] ?? {};
    final percu = _asDouble(stats['montant_total_percu']);
    final impaye = _asDouble(stats['montant_total_impaye']);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aperçu Financier',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: percu > 0 ? percu : 1,
                    color: AppTheme.success,
                    title: 'Perçu',
                    radius: 70,
                    titleStyle: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  PieChartSectionData(
                    value: impaye > 0 ? impaye : 0.01,
                    color: AppTheme.error,
                    title: 'Impayé',
                    radius: 70,
                    titleStyle: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
                sectionsSpace: 3,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _LegendItem(
                  'Perçu',
                  AppHelpers.formatMontant(percu),
                  AppTheme.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _LegendItem(
                  'Impayé',
                  AppHelpers.formatMontant(impaye),
                  AppTheme.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _LegendItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            maxLines: 1,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentPayments() {
    final paiements = (_dashboardData?['paiements_recents'] as List?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Paiements Récents',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => Get.toNamed(AppRoutes.caissierPaiements),
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...paiements.take(5).map((p) => _buildPaymentItem(p)),
      ],
    );
  }

  Widget _buildPaymentItem(Map<String, dynamic> p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.payments_rounded, color: AppTheme.success, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p['nom_complet_etudiant'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                Text(
                  p['nom_frais'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppHelpers.formatMontant(
                  double.tryParse(p['montant']?.toString() ?? '0') ?? 0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.success,
                  fontSize: 14,
                ),
              ),
              Text(
                AppHelpers.formatDate(p['date_paiement']),
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 11,
      unselectedFontSize: 10,
      onTap: (i) {
        setState(() => _selectedIndex = i);
        switch (i) {
          case 0: break;
          case 1: Get.toNamed(AppRoutes.adminEtudiants); break;
          case 2: Get.toNamed(AppRoutes.adminInscriptions); break;
          case 3: Get.toNamed(AppRoutes.adminRapports); break;
          case 4: Get.toNamed(AppRoutes.adminConfiguration); break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded),   label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.people_rounded),      label: 'Étudiants'),
        BottomNavigationBarItem(icon: Icon(Icons.how_to_reg_rounded),  label: 'Inscriptions'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded),   label: 'Rapports'),
        BottomNavigationBarItem(icon: Icon(Icons.settings_rounded),    label: 'Config'),
      ],
    );
  }
}

class _StatItem {
  final String   label;
  final String   value;
  final IconData icon;
  final Color    color;

  _StatItem(this.label, this.value, this.icon, this.color);
}