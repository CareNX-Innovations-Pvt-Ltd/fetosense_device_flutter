import 'package:fetosense_device_flutter/core/network/appwrite_config.dart';
import 'package:fetosense_device_flutter/presentation/mother_details/mother_details_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';

class MockClient extends Mock implements Client {}
class MockDatabases extends Mock implements Databases {}

void main() {
  late MotherDetailsCubit cubit;
  late MockClient mockClient;
  late MockDatabases mockDatabases;

  setUp(() {
    GetIt.I.allowReassignment = true;

    mockClient = MockClient();
    mockDatabases = MockDatabases();

    GetIt.I.registerSingleton<AppwriteService>(AppwriteService());

    cubit = MotherDetailsCubit();
  });

  test('emits loading then success when data exists', () async {
    final doc1 = Document(data: {'field': 'value1'}, $id: 'id1', $collectionId: '', $databaseId: '', $createdAt: '', $updatedAt: '', $permissions: []);
    final doc2 = Document(data: {'field': 'value2'}, $id: 'id2', $collectionId: '', $databaseId: '', $createdAt: '', $updatedAt: '', $permissions: []);

    when(() => mockDatabases.listDocuments(
      databaseId: any(named: 'databaseId'),
      collectionId: any(named: 'collectionId'),
      queries: any(named: 'queries'),
    )).thenAnswer((_) async => DocumentList(total: 2, documents: [doc1, doc2]));

    when(() => Databases(mockClient)).thenReturn(mockDatabases);

    final states = <MotherDetailsState>[];
    cubit.stream.listen(states.add);

    await cubit.fetchTests("Alice");

    expect(states.length, 2);
    expect(states[0], isA<MotherDetailsLoading>());
    expect(states[1], isA<MotherDetailsSuccess>());
    final successState = states[1] as MotherDetailsSuccess;
    expect(successState.test.length, 2);
    expect(successState.test[0].id, 'id1');
  });

  test('emits loading then failure when no data exists', () async {
    when(() => mockDatabases.listDocuments(
      databaseId: any(named: 'databaseId'),
      collectionId: any(named: 'collectionId'),
      queries: any(named: 'queries'),
    )).thenAnswer((_) async => DocumentList(total: 0, documents: []));

    when(() => Databases(mockClient)).thenReturn(mockDatabases);

    final states = <MotherDetailsState>[];
    cubit.stream.listen(states.add);

    await cubit.fetchTests("Alice");

    expect(states.length, 2);
    expect(states[0], isA<MotherDetailsLoading>());
    expect(states[1], isA<MotherDetailsFailure>());
    final failureState = states[1] as MotherDetailsFailure;
    expect(failureState.failure, "No data");
  });

  test('emits failure on exception', () async {
    when(() => mockDatabases.listDocuments(
      databaseId: any(named: 'databaseId'),
      collectionId: any(named: 'collectionId'),
      queries: any(named: 'queries'),
    )).thenThrow(Exception('Test exception'));

    when(() => Databases(mockClient)).thenReturn(mockDatabases);

    final states = <MotherDetailsState>[];
    cubit.stream.listen(states.add);

    await cubit.fetchTests("Alice");

    expect(states.length, 2);
    expect(states[0], isA<MotherDetailsLoading>());
    expect(states[1], isA<MotherDetailsFailure>());
    final failureState = states[1] as MotherDetailsFailure;
    expect(failureState.failure.contains('Test exception'), true);
  });
}
