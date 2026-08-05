abstract class AuthenticationRepository {
  Future<bool> isAuthenticated();
  Future<String?> getCurrentUserId();
  Future<void> signInWithGoogle();
  Future<void> signInWithApple();
  Future<void> signInWithEmail(String email, String password);
  Future<void> signOut();
}
