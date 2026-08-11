import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vaulted/domain/repositories/authentication_repository.dart';
import 'package:vaulted/core/config/env.dart';

class SupabaseAuthRepository implements AuthenticationRepository {
  final SupabaseClient _supabase;

  SupabaseAuthRepository(this._supabase);

  @override
  Future<bool> isAuthenticated() async {
    final session = _supabase.auth.currentSession;
    return session != null;
  }

  @override
  Future<String?> getCurrentUserId() async {
    return _supabase.auth.currentUser?.id;
  }

  @override
  Future<void> signInWithGoogle() async {
    final webClientId = Env.googleWebClientId;
    final iosClientId = Env.googleIosClientId;

    if (webClientId.isEmpty) {
      throw Exception('Missing GOOGLE_WEB_CLIENT_ID in .env');
    }

    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: iosClientId.isEmpty ? null : iosClientId,
      serverClientId: webClientId,
    );

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      // User canceled the sign-in flow
      return;
    }

    final googleAuth = await googleUser.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;

    if (accessToken == null) {
      throw 'No Access Token found.';
    }
    if (idToken == null) {
      throw 'No ID Token found.';
    }

    await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  @override
  Future<void> signInWithApple() async {
    // Apple sign-in can be implemented using sign_in_with_apple package
    // and passing the rawNonce and idToken to Supabase.
    // For now, this is a placeholder until Apple Developer account is ready.
    throw UnimplementedError('Apple Sign-In is pending Apple Developer setup');
  }

  @override
  Future<void> signInWithEmail(String email, String password) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signUpWithEmail(String email, String password) async {
    await _supabase.auth.signUp(email: email, password: password);
  }

  @override
  Future<void> signOut() async {
    await _supabase.auth.signOut();

    try {
      final webClientId = Env.googleWebClientId;
      final iosClientId = Env.googleIosClientId;
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: iosClientId.isEmpty ? null : iosClientId,
        serverClientId: webClientId.isEmpty ? null : webClientId,
      );
      await googleSignIn.signOut();
    } catch (_) {
      // Ignore if google sign out fails
    }
  }
}
