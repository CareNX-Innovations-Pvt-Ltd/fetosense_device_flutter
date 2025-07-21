import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:fetosense_device_flutter/core/constants/app_constants.dart';
import 'package:fetosense_device_flutter/core/network/appwrite_config.dart';
import 'package:fetosense_device_flutter/core/utils/preferences.dart';
import 'package:fetosense_device_flutter/data/models/mother_model.dart';
import 'package:fetosense_device_flutter/data/models/user_model.dart';
import 'package:fetosense_device_flutter/presentation/all_mothers/all_mothers_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'all_mother_cubit_test.mocks.dart';


@GenerateMocks([AppwriteService, Databases, PreferenceHelper, Client, DocumentList])
void main() {
  group('AllMothersCubit', () {
    late AllMothersCubit allMothersCubit;
    late MockAppwriteService mockAppwriteService;
    late MockDatabases mockDatabases;
    late MockPreferenceHelper mockPreferenceHelper;
    late MockClient mockClient;

    setUp(() {
      mockAppwriteService = MockAppwriteService();
      mockDatabases = MockDatabases();
      mockPreferenceHelper = MockPreferenceHelper();
      mockClient = MockClient();

      GetIt.I.registerSingleton<AppwriteService>(mockAppwriteService);
      GetIt.I.registerSingleton<PreferenceHelper>(mockPreferenceHelper);

      when(mockAppwriteService.client).thenReturn(mockClient);
      when(mockClient.setEndpoint(any)).thenReturn(mockClient);
      when(mockClient.setProject(any)).thenReturn(mockClient);
      when(mockClient.setSelfSigned(status: true)).thenReturn(mockClient);

      allMothersCubit = AllMothersCubit();
    });

    tearDown(() {
      GetIt.I.reset();
    });

    test('initial state is AllMothersInitial', () {
      expect(allMothersCubit.state, AllMothersInitial());
    });

    blocTest<
        AllMothersCubit, AllMothersState>(
      'emits [AllMothersLoading, AllMothersSuccess] when getMothersList is successful and data is available',
      build: () {
        final user = UserModel()..organizationName ='Test Org';
        final motherJson = {'\$id': '1', 'name': 'Test Mother', 'type': 'mother', 'organizationName': 'Test Org'};
        final document = Document(data: motherJson, $collectionId: 'user', $databaseId: 'test', $id: '', $createdAt: '', $updatedAt: '', $permissions: []);
        when(mockPreferenceHelper.getUser()).thenReturn(user);
        when(mockDatabases.listDocuments(
          databaseId: AppConstants.appwriteDatabaseId,
          collectionId: AppConstants.userCollectionId,
          queries: [
            Query.equal('type', 'mother'),
            Query.equal('organizationName', user.organizationName),
          ],
        )).thenAnswer((_) async => DocumentList(total: 1, documents: [document]));
        when(mockAppwriteService.client).thenReturn(mockClient);
        // when(mockClient.config).thenReturn(mockDatabases);

        return allMothersCubit;
      },
      act: (cubit) => cubit.getMothersList(),
      expect: () => [
        AllMothersLoading(),
        AllMothersSuccess([Mother.fromJson({'name': 'Test Mother'})]),
      ],
    );

    blocTest<
        AllMothersCubit, AllMothersState>(
      'emits [AllMothersLoading, AllMothersFailure] when getMothersList is successful but no data is available',
      build: () {
        final user = UserModel()..organizationName = 'Test Org';
        when(mockPreferenceHelper.getUser()).thenReturn(user);
        when(mockDatabases.listDocuments(
          databaseId: AppConstants.appwriteDatabaseId,
          collectionId: AppConstants.userCollectionId,
          queries: [
            Query.equal('type', 'mother'),
            Query.equal('organizationName', user.organizationName),
          ],
        )).thenAnswer((_) async => DocumentList(total: 0, documents: []));
        when(mockAppwriteService.client).thenReturn(mockClient);
        // when(mockClient.databases).thenReturn(mockDatabases);

        return allMothersCubit;
      },
      act: (cubit) => cubit.getMothersList(),
      expect: () => [
        AllMothersLoading(),
        const AllMothersFailure('No Data'),
      ],
    );

    blocTest<
        AllMothersCubit, AllMothersState>(
      'emits [AllMothersLoading, AllMothersFailure] when getMothersList encounters an error',
      build: () {
        final user = UserModel()..organizationName = 'Test Org';
        when(mockPreferenceHelper.getUser()).thenReturn(user);
        when(mockDatabases.listDocuments(
          databaseId: AppConstants.appwriteDatabaseId,
          collectionId: AppConstants.userCollectionId,
          queries: [
            Query.equal('type', 'mother'),
            Query.equal('organizationName', user.organizationName),
          ],
        )).thenThrow(AppwriteException('Test Error'));
        when(mockAppwriteService.client).thenReturn(mockClient);
        // when(mockClient.databases).thenReturn(mockDatabases);

        return allMothersCubit;
      },
      act: (cubit) => cubit.getMothersList(),
      expect: () => [
        AllMothersLoading(),
        const AllMothersFailure('AppwriteException: Test Error'),
      ],
    );

    blocTest<
        AllMothersCubit, AllMothersState>(
      'emits [AllMothersSuccess] with filtered list when filterMothers is called with a query that matches existing mothers',
      build: () {
        final mother1 = Mother()..name = 'Test Mother 1';
        final mother2 = Mother()..name = 'Test Mother 2';
        allMothersCubit.allMothers = [mother1, mother2];
        return allMothersCubit;
      },
      act: (cubit) => cubit.filterMothers('Test'),
      expect: () => [
        AllMothersSuccess([Mother()..name = 'Test Mother 1']),
      ],
    );

    blocTest<
        AllMothersCubit, AllMothersState>(
      'emits [AllMothersSuccess] with empty list when filterMothers is called with a query that does not match any mother',
      build: () {
        final mother1 = Mother()..name = 'Test Mother 1';
        final mother2 = Mother()..name = 'Test Mother 2';
        allMothersCubit.allMothers = [mother1, mother2];
        return allMothersCubit;
      },
      act: (cubit) => cubit.filterMothers('Nonexistent'),
      expect: () => [
        const AllMothersSuccess([]),
      ],
    );

    blocTest<
        AllMothersCubit, AllMothersState>(
      'emits [AllMothersSuccess] with all mothers when filterMothers is called with an empty query',
      build: () {
        final mother1 = Mother()..name = 'Test Mother 1';
        final mother2 = Mother()..name = 'Test Mother 2';
        allMothersCubit.allMothers = [mother1, mother2];
        return allMothersCubit;
      },
      act: (cubit) => cubit.filterMothers(''),
      expect: () => [
        AllMothersSuccess([Mother()..name = 'Test Mother 1', Mother()..name = 'Test Mother 2']),
      ],
    );
  });
}
