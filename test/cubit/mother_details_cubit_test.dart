import 'package:bloc_test/bloc_test.dart';
import 'package:fetosense_device_flutter/core/constants/app_constants.dart';
import 'package:fetosense_device_flutter/core/network/appwrite_config.dart';
import 'package:fetosense_device_flutter/presentation/mother_details/mother_details_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:get_it/get_it.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;


// Mocks
class MockAppwriteService extends Mock implements AppwriteService {}

class MockDatabases extends Mock implements Databases {}

class MockDocument extends Mock implements models.Document {}

class MockDocumentList extends Mock implements models.DocumentList {}

void main() {
  late MockAppwriteService mockAppwriteService;
  late MockDatabases mockDatabases;
  late MotherDetailsCubit cubit;

  final getIt = GetIt.instance;

  setUp(() {
    mockAppwriteService = MockAppwriteService();
    mockDatabases = MockDatabases();

    getIt.reset();
    getIt.registerSingleton<AppwriteService>(mockAppwriteService);
    when(mockAppwriteService.client).thenReturn(Client());

    cubit = MotherDetailsCubit();
  });

  tearDown(() {
    cubit.close();
  });

  blocTest<MotherDetailsCubit, MotherDetailsState>(
    'emits [Loading, Success] when tests are found',
    build: () {
      final mockDoc = MockDocument();
      when(mockDoc.data).thenReturn({
        'motherName': 'Jane Doe',
        'testId': 'abc123',
        'deviceId': 'device123',
        // add other required fields for Test.fromMap
      });
      when(mockDoc.$id).thenReturn('doc1');

      final mockDocList = MockDocumentList();
      when(mockDocList.total).thenReturn(1);
      when(mockDocList.documents).thenReturn([mockDoc]);

      when(mockAppwriteService.client).thenReturn(Client());
      when(mockDatabases.listDocuments(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.testsCollectionId,
        queries: anyNamed('queries'),
      )).thenAnswer((_) async => mockDocList);

      // Inject the mock database into the cubit method
      getIt.registerSingleton<Databases>(mockDatabases);

      return MotherDetailsCubit();
    },
    act: (cubit) => cubit.fetchTests('Jane Doe'),
    expect: () => [
      isA<MotherDetailsLoading>(),
      isA<MotherDetailsSuccess>(),
    ],
  );

  blocTest<MotherDetailsCubit, MotherDetailsState>(
    'emits [Loading, Failure] when no documents are found',
    build: () {
      final emptyList = MockDocumentList();
      when(emptyList.total).thenReturn(0);
      when(emptyList.documents).thenReturn([]);

      when(mockAppwriteService.client).thenReturn(Client());
      when(mockDatabases.listDocuments(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.testsCollectionId,
        queries: anyNamed('queries'),
      )).thenAnswer((_) async => emptyList);

      getIt.registerSingleton<Databases>(mockDatabases);

      return MotherDetailsCubit();
    },
    act: (cubit) => cubit.fetchTests('Unknown'),
    expect: () => [
      isA<MotherDetailsLoading>(),
      isA<MotherDetailsFailure>().having((e) => e, 'message', contains('No data')),
    ],
  );

  blocTest<MotherDetailsCubit, MotherDetailsState>(
    'emits [Loading, Failure] when an exception occurs',
    build: () {
      when(mockAppwriteService.client).thenReturn(Client());
      when(mockDatabases.listDocuments(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.testsCollectionId,
        queries: anyNamed('queries'),
      )).thenThrow(Exception('Fetch failed'));

      getIt.registerSingleton<Databases>(mockDatabases);

      return MotherDetailsCubit();
    },
    act: (cubit) => cubit.fetchTests('Crash Test'),
    expect: () => [
      isA<MotherDetailsLoading>(),
      isA<MotherDetailsFailure>().having((e) => e, 'message', contains('error')),
    ],
  );
}
