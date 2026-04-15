import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_profile.dart';

abstract class AuthRepository {
  Stream<AuthState> get authStateChanges;
  User? get currentUser;
  
  Future<void> signInEmail(String email, String password);
  Future<void> signUpEmail(String email, String password);
  Future<void> signOut();
  
  Future<AppProfile?> getProfile(String userId);
  Future<List<AppProfile>> getAllProfiles();
  Future<void> updateRole(String userId, String newRole);
}
