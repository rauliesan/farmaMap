import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_profile.dart';

class SupabaseAuthDatasource {
  final SupabaseClient _client = Supabase.instance.client;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
  
  User? get currentUser => _client.auth.currentUser;

  Future<AuthResponse> signInEmail(String email, String password) async {
    return await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUpEmail(String email, String password) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<AppProfile?> getProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;
      return AppProfile.fromJson(response);
    } catch (e) {
      return null; // Handle securely, might happen during RLS misconfig
    }
  }

  Future<List<AppProfile>> getAllProfiles() async {
    final response = await _client
        .from('profiles')
        .select()
        .order('created_at', ascending: false);

    return (response as List).map((e) => AppProfile.fromJson(e)).toList();
  }

  Future<void> updateRole(String userId, String newRole) async {
    await _client
        .from('profiles')
        .update({'role': newRole})
        .eq('id', userId);
  }

  Future<void> deleteUser(String userId) async {
    // Al usar RPC llamamos a la función de Postgres que acabamos de crear
    // que tiene permisos para borrar en auth.users
    await _client.rpc('delete_user_by_admin', params: {
      'target_user_id': userId,
    });
  }
}


