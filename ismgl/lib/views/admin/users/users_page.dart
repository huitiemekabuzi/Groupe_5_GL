import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ismgl/app/routes/app_routes.dart';
import 'package:ismgl/app/themes/app_theme.dart';
import 'package:ismgl/core/services/api_service.dart';
import 'package:ismgl/core/utils/helpers.dart';
import 'package:ismgl/data/models/user_model.dart';
import 'package:ismgl/views/shared/widgets/custom_app_bar.dart';
import 'package:ismgl/views/shared/widgets/empty_state.dart';
import 'package:ismgl/views/shared/widgets/loading_widget.dart';
import 'package:ismgl/views/shared/widgets/role_badge.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final ApiService _api = Get.find<ApiService>();

  List<UserModel> _users       = [];
  bool   _isLoading            = true;
  int    _currentPage          = 1;
  int    _totalPages           = 1;
  int    _total                = 0;
  String _search               = '';
  String? _filterRole;
  bool _isCreating = false;
  int? _actionUserId;
  String? _actionName;

  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _load();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
        if (_currentPage < _totalPages && !_isLoading) {
          _currentPage++;
          _load(append: true);
        }
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _load({bool append = false, bool reset = false}) async {
    if (reset) {
      _currentPage = 1;
      _users = [];
    }

    setState(() => _isLoading = true);

    int? roleId;
    if (_filterRole != null) {
      roleId = switch (_filterRole) {
        'Administrateur' => 1,
        'Caissier' => 2,
        'Gestionnaire' => 3,
        'Etudiant' => 4,
        'Comptable' => 5,
        _ => null,
      };
    }

    final result = await _api.get('/users', params: {
      'page':      _currentPage,
      'page_size': 20,
      if (_search.isNotEmpty) 'search': _search,
      // Certains backends filtrent par id_role plutôt que nom_role.
      if (roleId != null) 'id_role': roleId,
      if (roleId == null && _filterRole != null) 'role': _filterRole,
    });

    if (result['success'] == true) {
      final data       = result['data'];
      final pagination = data['pagination'];
      final items = (data['items'] as List).map((u) => UserModel.fromJson(u)).toList();

      setState(() {
        if (append) {
          _users.addAll(items);
        } else {
          _users = items;
        }
        _totalPages = pagination['total_pages'];
        _total      = pagination['total_items'];
      });
    }

    setState(() => _isLoading = false);
  }

  Future<void> _toggleActive(UserModel user) async {
    if (_actionUserId == user.id) return;
    setState(() {
      _actionUserId = user.id;
      _actionName = 'toggle';
    });
    final result = await _api.patch('/users/${user.id}/toggle');
    if (result['success'] == true) {
      AppHelpers.showSuccess('Statut modifié avec succès');
      await _load(reset: true);
    } else {
      AppHelpers.showError(result['message'] ?? 'Erreur');
    }
    if (mounted) {
      setState(() {
        _actionUserId = null;
        _actionName = null;
      });
    }
  }

  Future<void> _unlock(UserModel user) async {
    if (_actionUserId == user.id) return;
    setState(() {
      _actionUserId = user.id;
      _actionName = 'unlock';
    });
    final result = await _api.patch('/users/${user.id}/unlock');
    if (result['success'] == true) {
      AppHelpers.showSuccess('Compte déverrouillé');
      await _load(reset: true);
    }
    if (mounted) {
      setState(() {
        _actionUserId = null;
        _actionName = null;
      });
    }
  }

  Future<void> _delete(UserModel user) async {
    final confirm = await AppHelpers.showConfirmDialog(
      title:       'Supprimer l\'utilisateur',
      message:     'Supprimer ${user.fullName} ? Cette action est irréversible.',
      confirmText: 'Supprimer',
      confirmColor: AppTheme.error,
    );

    if (confirm) {
      setState(() {
        _actionUserId = user.id;
        _actionName = 'delete';
      });
      final result = await _api.delete('/users/${user.id}');
      if (result['success'] == true) {
        AppHelpers.showSuccess('Utilisateur supprimé');
        await _load(reset: true);
      } else {
        AppHelpers.showError(_friendlyDeleteError(result['message']));
      }
      if (mounted) {
        setState(() {
          _actionUserId = null;
          _actionName = null;
        });
      }
    }
  }

  String _friendlyDeleteError(dynamic rawMessage) {
    final msg = (rawMessage ?? '').toString();
    final lower = msg.toLowerCase();
    if (lower.contains('foreign key') ||
        lower.contains('cannot delete or update a parent row') ||
        lower.contains('inscriptions_ibfk')) {
      return 'Suppression impossible: cet utilisateur est lie a des donnees (inscriptions/paiements). '
          'Desactivez le compte ou supprimez d abord les enregistrements dependants.';
    }
    return msg.isEmpty ? 'Erreur lors de la suppression' : msg;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Utilisateurs ($_total)',
        showBack: true,
        showNotification: false,
        showProfile: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isCreating
            ? null
            : () async {
                setState(() => _isCreating = true);
                try {
                  await Get.toNamed(AppRoutes.adminUserForm);
                  await _load(reset: true);
                } finally {
                  if (mounted) setState(() => _isCreating = false);
                }
              },
        label: _isCreating
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Text('Nouvel utilisateur'),
        icon: _isCreating ? null : const Icon(Icons.person_add_rounded),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading && _users.isEmpty
                ? const ShimmerList()
                : _users.isEmpty
                    ? EmptyState(
                        message: 'Aucun utilisateur trouvé',
                        icon: Icons.people_outline,
                        actionLabel: 'Actualiser',
                        onAction: () => _load(reset: true),
                      )
                    : RefreshIndicator(
                        onRefresh: () => _load(reset: true),
                        child: ListView.separated(
                          controller: _scrollCtrl,
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                          itemCount: _users.length + (_isLoading ? 1 : 0),
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, i) {
                            if (i >= _users.length) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            return _buildUserCard(_users[i]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        controller: _searchCtrl,
        decoration: InputDecoration(
          hintText: 'Rechercher un utilisateur...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _search.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _search = '');
                    _load(reset: true);
                  },
                )
              : null,
        ),
        onChanged: (v) {
          setState(() => _search = v);
          if (v.length >= 3 || v.isEmpty) _load(reset: true);
        },
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: user.compteBloque
                  ? AppTheme.error.withValues(alpha: 0.2)
                  : AppTheme.primary.withValues(alpha: 0.1),
              child: Text(
                user.initials,
                style: TextStyle(
                  color: user.compteBloque ? AppTheme.error : AppTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    user.fullName,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
                RoleBadge(role: user.nomRole),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.email, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                Text(user.matricule, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              ],
            ),
            isThreeLine: true,
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Statut
                Row(
                  children: [
                    Icon(
                      user.estActif ? Icons.check_circle : Icons.cancel,
                      size: 14,
                      color: user.estActif ? AppTheme.success : AppTheme.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      user.estActif ? 'Actif' : 'Inactif',
                      style: TextStyle(
                        fontSize: 12,
                        color: user.estActif ? AppTheme.success : AppTheme.error,
                      ),
                    ),
                    if (user.compteBloque) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.lock, size: 14, color: AppTheme.error),
                      const Text(' Bloqué', style: TextStyle(fontSize: 12, color: AppTheme.error)),
                    ],
                  ],
                ),
                // Actions
                Wrap(
                  spacing: 4,
                  runSpacing: 0,
                  children: [
                    if (user.compteBloque)
                      IconButton(
                        icon: _actionUserId == user.id && _actionName == 'unlock'
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.lock_open, color: AppTheme.warning, size: 20),
                        tooltip: 'Déverrouiller',
                        onPressed: _actionUserId == user.id ? null : () => _unlock(user),
                      ),
                    IconButton(
                      icon: _actionUserId == user.id && _actionName == 'toggle'
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              user.estActif ? Icons.toggle_on : Icons.toggle_off,
                              color: user.estActif ? AppTheme.success : Colors.grey,
                              size: 20,
                            ),
                      tooltip: user.estActif ? 'Désactiver' : 'Activer',
                      onPressed: _actionUserId == user.id ? null : () => _toggleActive(user),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: AppTheme.primary, size: 20),
                      tooltip: 'Modifier',
                      onPressed: _actionUserId == user.id
                          ? null
                          : () => Get.toNamed(AppRoutes.adminUserForm, arguments: user)
                              ?.then((_) => _load(reset: true)),
                    ),
                    IconButton(
                      icon: _actionUserId == user.id && _actionName == 'delete'
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.delete_outline, color: AppTheme.error, size: 20),
                      tooltip: 'Supprimer',
                      onPressed: _actionUserId == user.id ? null : () => _delete(user),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filtrer par rôle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: ['Tous', 'Administrateur', 'Caissier', 'Gestionnaire', 'Etudiant', 'Comptable']
                  .map((r) => FilterChip(
                        label: Text(r),
                        selected: (r == 'Tous' && _filterRole == null) || _filterRole == r,
                        onSelected: (_) {
                          setState(() => _filterRole = r == 'Tous' ? null : r);
                          Get.back();
                          _load(reset: true);
                        },
                        selectedColor: AppTheme.primary.withValues(alpha: 0.2),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}