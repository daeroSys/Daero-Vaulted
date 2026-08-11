import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:vaulted/database/app_database.dart';
import 'package:vaulted/database/daos/user_dao.dart';
import 'package:vaulted/data/repositories/user_repository_impl.dart';
import 'package:vaulted/domain/repositories/sync_repository.dart';
import 'package:vaulted/domain/entities/enums.dart';

class FakeSyncRepository implements SyncRepository {
  @override
  Future<void> queueMutation(
    String entityType,
    String entityId,
    SyncOperation operation,
    SyncPriority priority,
    Map<String, dynamic> payload,
  ) async {}

  @override
  Future<List<dynamic>> getPendingMutations() async => [];

  @override
  Stream<List<dynamic>> watchPendingMutations() => const Stream.empty();

  @override
  Future<void> markMutationStatus(String id, SyncStatus status) async {}
}

void main() {
  late AppDatabase database;
  late UserDao userDao;
  late UserRepositoryImpl userRepository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    userDao = database.userDao;
    userRepository = UserRepositoryImpl(userDao, FakeSyncRepository());
  });

  tearDown(() async {
    await database.close();
  });

  test('can create a user and retrieve it', () async {
    await userRepository.createUser(
      'test-id-1',
      'test@example.com',
      'Test User',
      'https://example.com/photo.png',
    );

    final user = await userDao.getUserById('test-id-1');
    expect(user, isNotNull);
    expect(user!.email, 'test@example.com');
    expect(user.displayName, 'Test User');
  });

  test('can update a user profile', () async {
    await userRepository.createUser(
      'test-id-2',
      'test2@example.com',
      'Initial Name',
      null,
    );

    await userRepository.updateUserProfile(
      'test-id-2',
      displayName: 'Updated Name',
    );

    final updatedUser = await userDao.getUserById('test-id-2');
    expect(updatedUser!.displayName, 'Updated Name');
    expect(updatedUser.email, 'test2@example.com'); // should not change
  });
}
