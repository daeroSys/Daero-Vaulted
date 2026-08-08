import 'package:drift/drift.dart';
import '../../domain/repositories/user_repository.dart';
import '../../database/daos/user_dao.dart';
import '../../database/app_database.dart';

import '../../domain/repositories/sync_repository.dart';
import '../../domain/entities/enums.dart';

class UserRepositoryImpl implements UserRepository {
  final UserDao _userDao;
  final SyncRepository _syncRepository;

  UserRepositoryImpl(this._userDao, this._syncRepository);

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
    
    await _syncRepository.queueMutation(
      'users',
      id,
      SyncOperation.create,
      SyncPriority.high,
      {
        'id': id,
        'email': email,
        'display_name': displayName,
        'photo_url': photoUrl,
        'subscription_tier': null,
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
        'deleted_at': null,
      },
    );
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
      
      await _syncRepository.queueMutation(
        'users',
        id,
        SyncOperation.update,
        SyncPriority.normal,
        {
          'id': id,
          'email': existing.email,
          'display_name': displayName ?? existing.displayName,
          'photo_url': photoUrl ?? existing.photoUrl,
          'subscription_tier': existing.subscriptionTier,
          'created_at': existing.createdAt.toIso8601String(),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
          'deleted_at': existing.deletedAt?.toIso8601String(),
        },
      );
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
      
      await _syncRepository.queueMutation(
        'users',
        id,
        SyncOperation.update,
        SyncPriority.normal,
        {
          'id': id,
          'email': existing.email,
          'display_name': existing.displayName,
          'photo_url': existing.photoUrl,
          'subscription_tier': tier,
          'created_at': existing.createdAt.toIso8601String(),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
          'deleted_at': existing.deletedAt?.toIso8601String(),
        },
      );
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    await _userDao.deleteUser(id);
  }
}
