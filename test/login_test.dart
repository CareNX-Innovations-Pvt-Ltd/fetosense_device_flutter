import 'package:appwrite/models.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:fetosense_device_flutter/core/constants/app_constants.dart';
import 'package:fetosense_device_flutter/presentation/login/login_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:fetosense_device_flutter/core/utils/preferences.dart';
import 'package:appwrite/appwrite.dart';

import 'login_test.mocks.dart';

final sl = GetIt.instance;

void setupDependencies() {
  // Register PreferenceHelper
  sl.registerLazySingleton<PreferenceHelper>(() => PreferenceHelper());

  // Register other dependencies here
}

@GenerateMocks([Databases, PreferenceHelper])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  late LoginCubit loginCubit;
  late MockDatabases mockDatabases;
  late MockPreferenceHelper mockPreferenceHelper;

  setUp(() {
    mockDatabases = MockDatabases();
    mockPreferenceHelper = MockPreferenceHelper();
    loginCubit = LoginCubit();
  });

  tearDown(() {
    loginCubit.close();
  });

  group('LoginCubit', () {
    blocTest<LoginCubit, LoginState>(
      'emits [LoginLoading, LoginSuccess] when login is successful',
      build: () {
        when(mockDatabases.listDocuments(
          databaseId: AppConstants.appwriteDatabaseId,
          collectionId: AppConstants.userCollectionId,
          queries: anyNamed('queries'),
        )).thenAnswer((_) async => DocumentList(total: 1, documents: [
              Document(
                $id: 'userId',
                data: {'email': 'test@example.com'},
                $collectionId: '',
                $databaseId: '',
                $createdAt: '',
                $updatedAt: '',
                $permissions: [],
              )
            ]));

        when(mockPreferenceHelper.saveUser(any)).thenAnswer((_) async => true);
        when(mockPreferenceHelper.setAutoLogin(true))
            .thenAnswer((_) async => true);

        return loginCubit;
      },
      act: (cubit) => cubit.login('test@example.com', 'password'),
      expect: () => [LoginLoading(), LoginSuccess()],
    );

    blocTest<LoginCubit, LoginState>(
      'emits [LoginLoading, LoginFailure] when login fails due to user not found',
      build: () {
        when(mockDatabases.listDocuments(
          databaseId: AppConstants.appwriteDatabaseId,
          collectionId: AppConstants.userCollectionId,
          queries: anyNamed('queries'),
        )).thenAnswer((_) async => DocumentList(total: 0, documents: []));

        return loginCubit;
      },
      act: (cubit) => cubit.login('unknown@example.com', 'password'),
      expect: () => [
        LoginLoading(),
        const LoginFailure("User not found in any collection"),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'emits [LoginLoading, LoginFailure] when an exception occurs',
      build: () {
        when(mockDatabases.listDocuments(
          databaseId: anyNamed(AppConstants.appwriteDatabaseId),
          collectionId: anyNamed(AppConstants.userCollectionId),
          queries: anyNamed('queries'),
        )).thenThrow(Exception('Database error'));

        return loginCubit;
      },
      act: (cubit) => cubit.login('test@example.com', 'password'),
      expect: () => [
        LoginLoading(),
        const LoginFailure("Login failed: Exception: Database error"),
      ],
    );
  });
}
