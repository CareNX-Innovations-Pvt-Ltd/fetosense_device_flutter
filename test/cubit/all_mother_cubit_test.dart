import 'package:bloc_test/bloc_test.dart';
import 'package:fetosense_device_flutter/core/constants/app_constants.dart';
import 'package:fetosense_device_flutter/core/network/appwrite_config.dart';
import 'package:fetosense_device_flutter/core/utils/preferences.dart';
import 'package:fetosense_device_flutter/data/models/mother_model.dart';
import 'package:fetosense_device_flutter/presentation/all_mothers/all_mothers_cubit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

class MockDatabases extends Mock implements Databases {}
class MockAppwriteService extends Mock implements AppwriteService {}
class MockPreferenceHelper extends Mock implements PreferenceHelper {}
class MockClient extends Mock implements Client {}

class FakeDocument extends Fake implements models.Document {}
class FakeDocumentList extends Fake implements models.DocumentList {}

void main() {
  late MockDatabases mockDatabases;
  late MockAppwriteService mockAppwriteService;
  late MockPreferenceHelper mockPrefs;
  late MockClient mockClient;
  final getIt = GetIt.instance;

  setUpAll(() {
    registerFallbackValue(FakeDocument());
    registerFallbackValue(FakeDocumentList());
  });

  setUp(() {
    mockDatabases = MockDatabases();
    mockAppwriteService = MockAppwriteService();
    mockPrefs = MockPreferenceHelper();
    mockClient = MockClient();
    if (getIt.isRegistered<Databases>()) {
      getIt.unregister<Databases>();
    }
    getIt.registerSingleton<Databases>(mockDatabases);
    if (getIt.isRegistered<PreferenceHelper>()) {
      getIt.unregister<PreferenceHelper>();
    }
    if (getIt.isRegistered<AppwriteService>()) {
      getIt.unregister<AppwriteService>();
    }

    getIt.registerSingleton<PreferenceHelper>(mockPrefs);
    getIt.registerSingleton<AppwriteService>(mockAppwriteService);

    when(() => mockAppwriteService.client).thenReturn(mockClient);
  });

  group('AllMothersCubit', () {
    final mockMotherJson = {
      "name": "Alice",
      "contact": "1234567890",
      "organizationName": "TestOrg",
      // add other required fields
    };

    final mockMother = Mother.fromJson(mockMotherJson);

    blocTest<AllMothersCubit, AllMothersState>(
      'emits [Loading, Success] when mothers are fetched',
      build: () {
        when(() => mockPrefs.getUser()).thenReturn(
          Mother.fromJson({"organizationName": "TestOrg"}), // or a UserModel if used
        );

        when(() => mockDatabases.listDocuments(
          databaseId: AppConstants.appwriteDatabaseId,
          collectionId: AppConstants.userCollectionId,
          queries: any(named: 'queries'),
        )).thenAnswer((_) async => models.DocumentList(
          documents: [
            models.Document(
              $id: '1',
              data: mockMotherJson,
              $collectionId: '',
              $databaseId: '',
              $createdAt: '',
              $updatedAt: '',
              $permissions: [],
            )
          ],
          total: 1,
        ));

        return AllMothersCubit();
      },
      act: (cubit) => cubit.getMothersList(),
      expect: () => [
        AllMothersLoading(),
        AllMothersSuccess([mockMother]),
      ],
    );

    blocTest<AllMothersCubit, AllMothersState>(
      'emits [Loading, Failure] when list is empty',
      build: () {
        when(() => mockPrefs.getUser()).thenReturn(
          Mother.fromJson({"organizationName": "TestOrg"}),
        );

        when(() => mockDatabases.listDocuments(
          databaseId: any(named: 'databaseId'),
          collectionId: any(named: 'collectionId'),
          queries: any(named: 'queries'),
        )).thenAnswer((_) async => models.DocumentList(documents: [], total: 0));

        return AllMothersCubit();
      },
      act: (cubit) => cubit.getMothersList(),
      expect: () => [
        AllMothersLoading(),
        const AllMothersFailure("No Data"),
      ],
    );

    blocTest<AllMothersCubit, AllMothersState>(
      'emits [Loading, Failure] when an exception occurs',
      build: () {
        when(() => mockPrefs.getUser()).thenReturn(
          Mother.fromJson({"organizationName": "TestOrg"}),
        );

        when(() => mockDatabases.listDocuments(
          databaseId: any(named: 'databaseId'),
          collectionId: any(named: 'collectionId'),
          queries: any(named: 'queries'),
        )).thenThrow(Exception("API error"));

        return AllMothersCubit();
      },
      act: (cubit) => cubit.getMothersList(),
      expect: () => [
        AllMothersLoading(),
        isA<AllMothersFailure>(),
      ],
    );

    blocTest<AllMothersCubit, AllMothersState>(
      'emits filtered list of mothers',
      build: () {
        final cubit = AllMothersCubit();
        cubit.allMothers = [mockMother];
        return cubit;
      },
      act: (cubit) => cubit.filterMothers("alice"),
      expect: () => [
        AllMothersSuccess([mockMother]),
      ],
    );

    blocTest<AllMothersCubit, AllMothersState>(
      'emits empty list if no mother matches filter',
      build: () {
        final cubit = AllMothersCubit();
        cubit.allMothers = [mockMother];
        return cubit;
      },
      act: (cubit) => cubit.filterMothers("xyz"),
      expect: () => [
        const AllMothersSuccess([]),
      ],
    );
  });
}
