import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/extensions/context_extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/app_profile.dart';
import '../providers/auth_provider.dart';

final adminUsersListProvider = FutureProvider.autoDispose<List<AppProfile>>((ref) async {
  final repo = ref.watch(authRepositoryProvider);
  return await repo.getAllProfiles();
});

class AdminUsersScreen extends ConsumerWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(adminUsersListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: usersAsync.when(
        data: (users) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final user = users[index];
            final amIAdmin = ref.read(authProvider).user?.id == user.id;

            return ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: context.colorScheme.outlineVariant.withValues(alpha: 0.5)),
              ),
              tileColor: context.colorScheme.surfaceContainer,
              leading: CircleAvatar(
                backgroundColor: user.isAdmin ? AppColors.accent.withValues(alpha: 0.2) : context.colorScheme.primaryContainer,
                child: Icon(
                  user.isAdmin ? Icons.admin_panel_settings_rounded : Icons.person_rounded,
                  color: user.isAdmin ? AppColors.accent : context.colorScheme.primary,
                ),
              ),
              title: Text(user.email, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                user.isAdmin ? 'Administrador' : 'Usuario Mortal',
                style: TextStyle(color: user.isAdmin ? AppColors.accent : context.colorScheme.onSurfaceVariant),
              ),
              trailing: amIAdmin
                  ? const Text('(Tú)', style: TextStyle(color: Colors.grey))
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: user.isAdmin,
                          activeTrackColor: AppColors.accent,
                          onChanged: (val) async {
                            try {
                              await ref.read(authRepositoryProvider).updateRole(user.id, val ? 'admin' : 'user');
                              ref.invalidate(adminUsersListProvider);
                              if (context.mounted) context.showSnackBar('Rol actualizado');
                            } catch (e) {
                              if (context.mounted) context.showSnackBar('Error: $e', isError: true);
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                          onPressed: () => _confirmDelete(context, ref, user),
                        ),
                      ],
                    ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, AppProfile user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar usuario?'),
        content: Text('Esta acción eliminará el perfil de ${user.email}. Esta acción es irreversible (solo para el perfil de la app).'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCELAR'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(authRepositoryProvider).deleteUser(user.id);
        ref.invalidate(adminUsersListProvider);
        if (context.mounted) context.showSnackBar('Usuario eliminado');
      } catch (e) {
        if (context.mounted) context.showSnackBar('Error al eliminar: $e', isError: true);
      }
    }
  }
}

