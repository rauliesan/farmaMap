import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/supabase_auth_datasource.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/models/app_profile.dart';

final authDatasourceProvider = Provider<SupabaseAuthDatasource>((ref) {
  return SupabaseAuthDatasource();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authDatasourceProvider));
});

class AuthStateData {
  final User? user;
  final AppProfile? profile;
  final bool isLoading;

  AuthStateData({this.user, this.profile, this.isLoading = false});

  AuthStateData copyWith({
    User? user,
    AppProfile? profile,
    bool? isLoading,
    bool clearUser = false,
  }) {
    return AuthStateData(
      user: clearUser ? null : (user ?? this.user),
      profile: clearUser ? null : (profile ?? this.profile),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthStateData> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthStateData(isLoading: true)) {
    _init();
  }

  void _init() {
    _repository.authStateChanges.listen((data) async {
      final user = data.session?.user;
      if (user == null) {
        if (mounted) state = state.copyWith(clearUser: true, isLoading: false);
      } else {
        // Fetch profile to get role
        final profile = await _repository.getProfile(user.id);
        if (mounted) state = state.copyWith(user: user, profile: profile, isLoading: false);
      }
    });

    // Check initial
    final initialUser = _repository.currentUser;
    if (initialUser != null) {
      _repository.getProfile(initialUser.id).then((profile) {
        if (mounted) state = AuthStateData(user: initialUser, profile: profile, isLoading: false);
      });
    } else {
      if (mounted) state = AuthStateData(user: null, profile: null, isLoading: false);
    }
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.signInEmail(email, password);
    } finally {
      if (mounted) state = state.copyWith(isLoading: false);
    }
  }

  Future<void> signUp(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.signUpEmail(email, password);
    } finally {
      if (mounted) state = state.copyWith(isLoading: false);
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.signOut();
    } finally {
      if (mounted) state = state.copyWith(isLoading: false);
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthStateData>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).profile?.isAdmin ?? false;
});
