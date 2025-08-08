import 'package:bloc_test/bloc_test.dart';
import 'package:fetosense_device_flutter/core/constants/app_constants.dart';
import 'package:fetosense_device_flutter/core/network/appwrite_config.dart';
import 'package:fetosense_device_flutter/core/utils/preferences.dart';
import 'package:fetosense_device_flutter/data/models/user_model.dart';
import 'package:fetosense_device_flutter/presentation/login/login_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

import 'package:appwrite/models.dart' as models;
import 'package:appwrite/appwrite.dart';

// 🔧 Mocks
class MockDatabases extends Mock implements Databases {}

class MockAppwriteService extends Mock implements AppwriteService {}

class MockPreferenceHelper extends Mock implements PreferenceHelper {}

class MockClient extends Mock implements Client {}

class FakeUserModel extends Fake implements UserModel {}

void main() {
  late MockDatabases mockDatabases;
  late MockPreferenceHelper mockPrefs;
  late MockAppwriteService mockAppwriteService;
  late MockClient mockClient;

  final getIt = GetIt.instance;

  setUpAll(() {
    registerFallbackValue(FakeUserModel());
  });

  setUp(() {
    mockDatabases = MockDatabases();
    mockPrefs = MockPreferenceHelper();
    mockAppwriteService = MockAppwriteService();
    mockClient = MockClient();

    // Clean previous GetIt registrations
    if (getIt.isRegistered<PreferenceHelper>()) getIt.unregister<PreferenceHelper>();
    if (getIt.isRegistered<AppwriteService>()) getIt.unregister<AppwriteService>();

    getIt.registerSingleton<PreferenceHelper>(mockPrefs);
    getIt.registerSingleton<AppwriteService>(mockAppwriteService);

    when(() => mockAppwriteService.client).thenReturn(mockClient);
  });

  group('LoginCubit', () {
    const email = 'test@example.com';
    const password = 'password';

    blocTest<LoginCubit, LoginState>(
      'emits [LoginLoading, LoginSuccess] when user is found in primary collection',
      build: () {
        when(() => mockDatabases.listDocuments(
          databaseId: AppConstants.appwriteDatabaseId,
          collectionId: AppConstants.userCollectionId,
          queries: any(named: 'queries'),
        )).thenAnswer(
              (_) async => models.DocumentList(documents: [
            models.Document(
              $id: '123',
              $collectionId: AppConstants.userCollectionId,
              $databaseId: AppConstants.appwriteDatabaseId,
              $createdAt: '2024-01-01T00:00:00.000Z',
              $updatedAt: '2024-01-01T00:00:00.000Z',
              $permissions: [],
              data: {
                'email': email,
                'type': 'doctor',
                'name': 'Test User',
              },
            )
          ], total: 1),
        );

        when(() => mockPrefs.saveUser(any())).thenAnswer((_) async => {});
        when(() => mockPrefs.setAutoLogin(true)).thenReturn(null);

        return LoginCubit(db: mockDatabases);
      },
      act: (cubit) => cubit.login(email, password),
      expect: () => [
        LoginLoading(),
        isA<LoginSuccess>(),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'emits [LoginLoading, LoginFailure] when user is not found anywhere',
      build: () {
        when(() => mockDatabases.listDocuments(
          databaseId: AppConstants.appwriteDatabaseId,
          collectionId: AppConstants.userCollectionId,
          queries: any(named: 'queries'),
        )).thenAnswer(
              (_) async => models.DocumentList(documents: [], total: 0),
        );

        when(() => mockDatabases.listDocuments(
          databaseId: AppConstants.appwriteDatabaseId,
          collectionId: AppConstants.deviceCollectionId,
          queries: any(named: 'queries'),
        )).thenAnswer(
              (_) async => models.DocumentList(documents: [], total: 0),
        );

        return LoginCubit(db: mockDatabases);
      },
      act: (cubit) => cubit.login(email, password),
      expect: () => [
        LoginLoading(),
        const LoginFailure("User not found in any collection"),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'emits [LoginLoading, LoginSuccess] when user is found in device collection',
      build: () {
        when(() => mockDatabases.listDocuments(
          databaseId: AppConstants.appwriteDatabaseId,
          collectionId: AppConstants.userCollectionId,
          queries: any(named: 'queries'),
        )).thenAnswer(
              (_) async => models.DocumentList(documents: [], total: 0),
        );

        when(() => mockDatabases.listDocuments(
          databaseId: AppConstants.appwriteDatabaseId,
          collectionId: AppConstants.deviceCollectionId,
          queries: any(named: 'queries'),
        )).thenAnswer(
              (_) async => models.DocumentList(documents: [
            models.Document(
              $id: 'device123',
              $collectionId: AppConstants.deviceCollectionId,
              $databaseId: AppConstants.appwriteDatabaseId,
              $createdAt: '2024-01-01T00:00:00.000Z',
              $updatedAt: '2024-01-01T00:00:00.000Z',
              $permissions: [],
              data: {
                'deviceCode': 'test',
                'hospitalName': 'Test Hospital',
                'name': 'Device User',
              },
            )
          ], total: 1),
        );

        when(() => mockDatabases.createDocument(
          databaseId: any(named: 'databaseId'),
          collectionId: any(named: 'collectionId'),
          documentId: any(named: 'documentId'),
          data: any(named: 'data'),
        )).thenAnswer((_) async => models.Document(
          $id: 'new-user-id',
          $collectionId: AppConstants.userCollectionId,
          $databaseId: AppConstants.appwriteDatabaseId,
          $createdAt: '2024-01-01T00:00:00.000Z',
          $updatedAt: '2024-01-01T00:00:00.000Z',
          $permissions: [],
          data: {},
        ));

        when(() => mockPrefs.saveUser(any())).thenAnswer((_) async => {});
        when(() => mockPrefs.setAutoLogin(true)).thenReturn(null);

        return LoginCubit(db: mockDatabases);
      },
      act: (cubit) => cubit.login(email, password),
      expect: () => [
        LoginLoading(),
        isA<LoginSuccess>(),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'emits [LoginLoading, LoginFailure] on exception',
      build: () {
        when(() => mockDatabases.listDocuments(
          databaseId: any(named: 'databaseId'),
          collectionId: any(named: 'collectionId'),
          queries: any(named: 'queries'),
        )).thenThrow(Exception("Some error"));

        return LoginCubit(db: mockDatabases);
      },
      act: (cubit) => cubit.login(email, password),
      expect: () => [
        LoginLoading(),
        isA<LoginFailure>(),
      ],
    );
  });
}
