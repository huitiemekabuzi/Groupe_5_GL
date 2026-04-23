import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ismgl/app/themes/app_theme.dart';
import 'package:ismgl/controllers/etudiant_controller.dart';
import 'package:ismgl/core/utils/helpers.dart';
import 'package:ismgl/data/models/etudiant_model.dart';
import 'package:ismgl/views/shared/widgets/custom_app_bar.dart';
import 'package:ismgl/views/shared/widgets/empty_state.dart';
import 'package:ismgl/views/shared/widgets/loading_widget.dart';
import 'package:ismgl/views/shared/widgets/status_chip.dart';

class EtudiantsPage extends GetView<EtudiantController> {
  const EtudiantsPage({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('🏗️ Building EtudiantsPage');
    
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Obx(
          () => CustomAppBar(
            title: 'Étudiants (${controller.totalItems.value})',
            showBack: true,
            showNotification: false,
            showProfile: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list_rounded),
                onPressed: _showFilter,
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: Obx(() {
              debugPrint('🔄 Rebuilding list. isLoading: ${controller.isLoading.value}');
              debugPrint('   Data count: ${controller.etudiants.length}');
              
              if (controller.isLoading.value && controller.etudiants.isEmpty) {
                return const Center(
                  child: LoadingWidget(message: 'Chargement des étudiants...'),
                );
              }

              if (controller.etudiants.isEmpty) {
                return const Center(
                  child: EmptyState(
                    message: 'Aucun étudiant trouvé',
                    icon: Icons.school_outlined,
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.loadEtudiants(reset: true),
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
                      debugPrint('📥 Infinite scroll triggered');
                      controller.loadMore();
                    }
                    return true;
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.etudiants.length + (controller.isLoading.value ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, index) {
                      if (index >= controller.etudiants.length) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return _buildCard(controller.etudiants[index]);
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Obx(() => TextField(
        decoration: InputDecoration(
          hintText: 'Rechercher un étudiant...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller.search.value.isNotEmpty
              ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  controller.search.value = '';
                  controller.loadEtudiants(reset: true);
                },
              )
              : null,
        ),
        onChanged: (v) {
          debugPrint('🔍 Search input changed: $v');
          controller.onSearch(v);
        },
      )),
    );
  }

  Widget _buildFilterChips() {
    return Obx(() {
      if (controller.filterStatut.value == null && controller.filterSexe.value == null) {
        return const SizedBox(height: 8);
      }
      
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Row(
          children: [
            if (controller.filterStatut.value != null)
              Chip(
                label: Text(controller.filterStatut.value!),
                onDeleted: () {
                  debugPrint('❌ Removing statut filter');
                  controller.setFilterStatut(null);
                },
                backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
              ),
            if (controller.filterSexe.value != null) ...[
              const SizedBox(width: 8),
              Chip(
                label: Text(controller.filterSexe.value == 'M' ? 'Masculin' : 'Féminin'),
                onDeleted: () {
                  debugPrint('❌ Removing sexe filter');
                  controller.setFilterSexe(null);
                },
                backgroundColor: AppTheme.secondary.withValues(alpha: 0.1),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildCard(EtudiantModel e) {
    debugPrint('   📋 Building card for: ${e.fullName}');
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
          radius: 26,
          child: Text(
            AppHelpers.getInitials(e.fullName),
            style: const TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                e.fullName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            StatusChip(status: e.statut, type: 'etudiant'),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              e.numeroEtudiant,
              style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
            Text(
              e.email,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
            Text(
              '${e.sexe == 'M' ? '♂ Masculin' : '♀ Féminin'} • ${AppHelpers.formatDate(e.dateNaissance)}',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (v) {
            debugPrint('🔄 Updating statut to: $v');
            controller.updateStatut(e, v);
          },
          itemBuilder: (_) => ['Actif', 'Suspendu', 'Diplômé', 'Abandonné']
              .where((s) => s != e.statut)
              .map((s) => PopupMenuItem<String>(value: s, child: Text(s)))
              .toList(),
        ),
      ),
    );
  }

  void _showFilter() {
    debugPrint('📋 Opening filter modal');
    
    showModalBottomSheet(
      context: Get.context!,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filtres', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('Statut', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['Actif', 'Suspendu', 'Diplômé', 'Abandonné'].map((s) => Obx(
                () => FilterChip(
                  label: Text(s),
                  selected: controller.filterStatut.value == s,
                  onSelected: (_) {
                    debugPrint('✅ Filter by statut: $s');
                    controller.setFilterStatut(controller.filterStatut.value == s ? null : s);
                    Get.back();
                  },
                ),
              )).toList(),
            ),
            const SizedBox(height: 12),
            const Text('Sexe', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                {'label': 'Masculin', 'value': 'M'},
                {'label': 'Féminin', 'value': 'F'},
              ].map((item) => Obx(
                () => FilterChip(
                  label: Text(item['label']!),
                  selected: controller.filterSexe.value == item['value'],
                  onSelected: (_) {
                    debugPrint('✅ Filter by sexe: ${item['value']}');
                    controller.setFilterSexe(
                      controller.filterSexe.value == item['value'] ? null : item['value'],
                    );
                    Get.back();
                  },
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

extension on EtudiantModel {
  String get fullName => '$prenom $nom'.trim();
}
