import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/extensions/context_extensions.dart';
import '../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLogin = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty) return;

    try {
      if (_isLogin) {
        await ref.read(authProvider.notifier).signIn(email, pass);
        if (mounted) context.showSnackBar('¡Bienvenido de vuelta!');
      } else {
        await ref.read(authProvider.notifier).signUp(email, pass);
        if (mounted) context.showSnackBar('Cuenta creada exitosamente');
      }
    } catch (e) {
      if (mounted) context.showSnackBar('Error: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: authState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : (authState.user != null)
              ? _buildUserDashboard(context, authState)
              : _buildAuthForm(context, authState),
    );
  }

  Widget _buildUserDashboard(BuildContext context, AuthStateData state) {
    final profile = state.profile;
    final isAdmin = profile?.isAdmin ?? false;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: const Icon(Icons.person_rounded, size: 50, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            profile?.email ?? state.user!.email ?? 'Usuario',
            style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isAdmin ? AppColors.adminGold.withValues(alpha: 0.2) : context.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isAdmin ? '👑 ADMINISTRADOR' : '👤 USUARIO',
              style: context.textTheme.labelMedium?.copyWith(
                color: isAdmin ? AppColors.adminGold : context.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 48),
          if (isAdmin)
            ListTile(
              leading: Icon(Icons.admin_panel_settings_rounded, color: AppColors.adminGold),
              title: const Text('Gestión de Usuarios'),
              trailing: const Icon(Icons.chevron_right_rounded),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tileColor: context.colorScheme.surfaceContainer,
              onTap: () => context.push('/admin_users'),
            ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => ref.read(authProvider.notifier).signOut(),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Cerrar Sesión'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                foregroundColor: context.colorScheme.error,
                side: BorderSide(color: context.colorScheme.error.withValues(alpha: 0.5)),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAuthForm(BuildContext context, AuthStateData state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          Icon(Icons.local_pharmacy_rounded, size: 80, color: AppColors.primary),
          const SizedBox(height: 24),
          Text(
            _isLogin ? 'Bienvenido a FarmaMap' : 'Crea tu cuenta',
            style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Correo electrónico',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passCtrl,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: state.isLoading ? null : _submit,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(_isLogin ? 'INICIAR SESIÓN' : 'REGISTRARSE'),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => setState(() => _isLogin = !_isLogin),
            child: Text(
              _isLogin
                  ? '¿No tienes cuenta? Registrate aquí'
                  : '¿Ya tienes cuenta? Inicia sesión',
            ),
          )
        ],
      ),
    );
  }
}
