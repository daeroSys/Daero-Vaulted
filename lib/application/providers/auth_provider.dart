import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vaulted/data/repositories/supabase_auth_repository.dart';
import 'package:vaulted/domain/repositories/authentication_repository.dart';
import 'package:vaulted/data/repositories/user_repository_impl.dart';
import 'package:vaulted/domain/repositories/user_repository.dart';
import 'package:vaulted/services/authentication_service.dart';
import 'package:vaulted/core/providers.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authRepositoryProvider = Provider<AuthenticationRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SupabaseAuthRepository(supabase);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return UserRepositoryImpl(db.userDao);
});

final authServiceProvider = Provider<AuthenticationService>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final userRepo = ref.watch(userRepositoryProvider);
  return AuthenticationService(authRepo, userRepo);
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return supabase.auth.onAuthStateChange;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(
    data: (state) => state.session != null,
    orElse: () => false,
  );
});
