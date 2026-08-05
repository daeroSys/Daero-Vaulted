

abstract class UserRepository {
  Future<void> createUser(String id, String email, String? displayName, String? photoUrl);
  Future<void> updateUserProfile(String id, {String? displayName, String? photoUrl});
  Future<void> updateSubscriptionTier(String id, String tier);
  Future<void> deleteUser(String id);
}
