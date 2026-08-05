import '../../domain/repositories/authentication_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthenticationRepositoryImpl implements AuthenticationRepository {
  final SupabaseClient _supabase;

  AuthenticationRepositoryImpl(this._supabase);

  @override
  Future<bool> isAuthenticated() async {
    return _supabase.auth.currentSession != null;
  }

  @override
  Future<String?> getCurrentUserId() async {
    return _supabase.auth.currentUser?.id;
  }

  @override
  Future<void> signInWithGoogle() async {
    throw UnimplementedError('Google sign in will be implemented in Phase 2');
  }

  @override
  Future<void> signInWithApple() async {
    throw UnimplementedError('Apple sign in will be implemented in Phase 2');
  }

  @override
  Future<void> signInWithEmail(String email, String password) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
