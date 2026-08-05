import 'package:drift/drift.dart';
import '../../domain/repositories/user_repository.dart';
import '../../database/daos/user_dao.dart';
import '../../database/app_database.dart';

class UserRepositoryImpl implements UserRepository {
  final UserDao _userDao;

  UserRepositoryImpl(this._userDao);

  @override
  Future<void> createUser(String id, String email, String? displayName, String? photoUrl) async {
    await _userDao.insertUser(UsersCompanion(
      id: Value(id),
      email: Value(email),
      displayName: Value(displayName),
      photoUrl: Value(photoUrl),
      createdAt: Value(DateTime.now().toUtc()),
      updatedAt: Value(DateTime.now().toUtc()),
    ));
  }

  @override
  Future<void> updateUserProfile(String id, {String? displayName, String? photoUrl}) async {
    final existing = await _userDao.getUserById(id);
    if (existing != null) {
      await _userDao.updateUser(existing.copyWith(
        displayName: Value(displayName ?? existing.displayName),
        photoUrl: Value(photoUrl ?? existing.photoUrl),
        updatedAt: DateTime.now().toUtc(),
      ).toCompanion(true));
    }
  }

  @override
  Future<void> updateSubscriptionTier(String id, String tier) async {
    final existing = await _userDao.getUserById(id);
    if (existing != null) {
      await _userDao.updateUser(existing.copyWith(
        subscriptionTier: Value(tier),
        updatedAt: DateTime.now().toUtc(),
      ).toCompanion(true));
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    await _userDao.deleteUser(id);
  }
}
