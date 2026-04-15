import 'package:supabase_flutter/supabase_flutter.dart';
import '../datasources/supabase_auth_datasource.dart';
import '../models/app_profile.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseAuthDatasource _datasource;

  AuthRepositoryImpl(this._datasource);

  @override
  Stream<AuthState> get authStateChanges => _datasource.authStateChanges;

  @override
  User? get currentUser => _datasource.currentUser;

  @override
  Future<void> signInEmail(String email, String password) async {
    await _datasource.signInEmail(email, password);
  }

  @override
  Future<void> signUpEmail(String email, String password) async {
    await _datasource.signUpEmail(email, password);
  }

  @override
  Future<void> signOut() async {
    await _datasource.signOut();
  }

  @override
  Future<AppProfile?> getProfile(String userId) {
    return _datasource.getProfile(userId);
  }

  @override
  Future<List<AppProfile>> getAllProfiles() {
    return _datasource.getAllProfiles();
  }

  @override
  Future<void> updateRole(String userId, String newRole) {
    return _datasource.updateRole(userId, newRole);
  }

  @override
  Future<void> deleteUser(String userId) {
    return _datasource.deleteUser(userId);
  }
}
