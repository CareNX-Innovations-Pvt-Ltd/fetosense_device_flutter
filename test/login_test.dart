import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:fetosense_device_flutter/core/constants/app_constants.dart';
import 'package:fetosense_device_flutter/core/network/dependency_injection.dart';
import 'package:fetosense_device_flutter/core/utils/preferences.dart';
import 'package:fetosense_device_flutter/data/models/user_model.dart';
import 'package:fetosense_device_flutter/presentation/login/login_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_test.mocks.dart';

class MockPathProviderPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async => './test_dir';

  @override
  Future<String?> getTemporaryPath() async => './test_temp';
}

@GenerateMocks([Databases, PreferenceHelper])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  ServiceLocator.setupLocator();
  ServiceLocator.sharedPrefsHelper;
  PreferenceHelper.init();
  PathProviderPlatform.instance = MockPathProviderPlatform();
  group('LoginCubit Tests', () {
    late LoginCubit loginCubit;
    late Databases mockDatabases;
    late PreferenceHelper mockPrefs;

    setUp(() {
      mockDatabases = MockDatabases();
      mockPrefs = MockPreferenceHelper();
      loginCubit = LoginCubit();
    });

    tearDown(() {
      loginCubit.close();
    });

    test('successful login with primary user', () async {
      // Arrange
      const testEmail = 'test@example.com';
      const testPassword = 'password123';
      final mockUserData = {
        'email': testEmail,
        'type': 'primary',
        'name': 'Test User'
      };
      final mockDocumentList = DocumentList(
        total: 1,
        documents: [
          Document(
            $id: 'test-id',
            $collectionId: AppConstants.userCollectionId,
            $databaseId: AppConstants.appwriteDatabaseId,
            data: mockUserData,
            $createdAt: '',
            $updatedAt: '',
            $permissions: [],
          )
        ],
      );

      when(mockDatabases.listDocuments(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.userCollectionId,
        queries: [Query.equal('email', testEmail)],
      )).thenAnswer((_) async => mockDocumentList);

      when(mockPrefs.saveUser(UserModel())).thenAnswer((_) async {});
      when(mockPrefs.setAutoLogin(true)).thenReturn(null);

      // Act
      await loginCubit.login(testEmail, testPassword);

      // Assert
      expect(loginCubit.state, isA<LoginSuccess>());
      verify(mockPrefs.saveUser(UserModel())).called(1);
      verify(mockPrefs.setAutoLogin(true)).called(1);
    });

    test('login failure with non-existent user', () async {
      // Arrange
      const testEmail = 'nonexistent@example.com';
      const testPassword = 'password123';
      final mockEmptyList = DocumentList(
        total: 0,
        documents: [],
      );

      when(mockDatabases.listDocuments(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.userCollectionId,
        queries: any,
      )).thenAnswer((_) async => mockEmptyList);

      // Act
      await loginCubit.login(testEmail, testPassword);

      // Assert
      expect(loginCubit.state, isA<LoginFailure>());
      expect((loginCubit.state as LoginFailure).error,
          contains('User not found in any collection'));
    });

    test('login throws exception', () async {
      // Arrange
      const testEmail = 'test@example.com';
      const testPassword = 'password123';

      when(mockDatabases.listDocuments(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.userCollectionId,
        queries: any,
      )).thenThrow(Exception('Network error'));

      // Act
      await loginCubit.login(testEmail, testPassword);

      // Assert
      expect(loginCubit.state, isA<LoginFailure>());
      expect((loginCubit.state as LoginFailure).error,
          contains('Login failed: Exception'));
    });
  });
}