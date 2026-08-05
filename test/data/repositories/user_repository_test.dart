import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:vaulted/database/app_database.dart';
import 'package:vaulted/database/daos/user_dao.dart';
import 'package:vaulted/data/repositories/user_repository_impl.dart';

void main() {
  late AppDatabase database;
  late UserDao userDao;
  late UserRepositoryImpl userRepository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    userDao = database.userDao;
    userRepository = UserRepositoryImpl(userDao);
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

    await userRepository.updateUserProfile('test-id-2', displayName: 'Updated Name');
    
    final updatedUser = await userDao.getUserById('test-id-2');
    expect(updatedUser!.displayName, 'Updated Name');
    expect(updatedUser.email, 'test2@example.com'); // should not change
  });
}
