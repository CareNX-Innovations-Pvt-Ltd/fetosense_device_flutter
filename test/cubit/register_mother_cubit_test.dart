import 'package:bloc_test/bloc_test.dart';
import 'package:fetosense_device_flutter/core/constants/app_constants.dart';
import 'package:fetosense_device_flutter/core/network/appwrite_config.dart';
import 'package:fetosense_device_flutter/core/utils/preferences.dart';
import 'package:fetosense_device_flutter/data/models/mother_model.dart';
import 'package:fetosense_device_flutter/data/models/test_model.dart';
import 'package:fetosense_device_flutter/data/models/user_model.dart';
import 'package:fetosense_device_flutter/presentation/register_mother/register_mother_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

// --- Mocks ---
class MockAppwriteService extends Mock implements AppwriteService {}
class MockPreferenceHelper extends Mock implements PreferenceHelper {}
class MockAppwriteClient extends Mock implements Client {}
class MockDatabases extends Mock implements Databases {}
class MockDocument extends Mock implements models.Document {}

// Helper to register fallbacks for any() matchers
void _registerFallbacks() {
  registerFallbackValue(Uri.parse('http://fallback.uri'));
}

void main() {
  late RegisterMotherCubit registerMotherCubit;
  late MockAppwriteService mockAppwriteService;
  late MockPreferenceHelper mockPreferenceHelper;
  late MockAppwriteClient mockAppwriteClient;
  late MockDatabases mockDatabases;

  // --- Setup ---
  setUpAll(() {
    _registerFallbacks();
  });

  setUp(() {
    // Clear previous instances from GetIt
    GetIt.I.reset();

    // Initialize mocks
    mockAppwriteService = MockAppwriteService();
    mockPreferenceHelper = MockPreferenceHelper();
    mockAppwriteClient = MockAppwriteClient();
    mockDatabases = MockDatabases();

    // Setup GetIt with mock instances
    GetIt.I.registerSingleton<AppwriteService>(mockAppwriteService);
    GetIt.I.registerSingleton<PreferenceHelper>(mockPreferenceHelper);

    // Mock the service to return the mocked client
    when(() => mockAppwriteService.client).thenReturn(mockAppwriteClient);

    // Instantiate the cubit after setting up dependencies
    registerMotherCubit = RegisterMotherCubit();

    // Replace the real Databases instance with our mock in the cubit instance
    // Note: This is a way to mock dependencies created inside a method.
    // For cleaner architecture, `Databases` would be injected via the constructor.
    // registerMotherCubit.client = Realtime(mockAppwriteClient); // Mocking internal client properties if needed
  });

  // --- Test Data ---
  final testTestModel = Test.withData(
    motherName: 'Jane Doe',
    patientId: 'P123',
    deviceId: 'D001',
    deviceName: 'DeviceX',
    gAge: 38,
    createdOn: DateTime(2025, 7, 10, 14, 30), bpmEntries: [], bpmEntries2: [], baseLineEntries: [], movementEntries: [], autoFetalMovement: [], tocoEntries: [],
  );

  final testPickedDate = DateTime(2023, 1, 1);
  const testName = 'Jane Doe';
  const testAge = '30';
  const testPatientId = 'PID12345';
  const testMobile = '9876543210';
  const testDoctorId = 'doc_789';
  const testDoctorName = 'Dr. Smith';

  group('RegisterMotherCubit', () {
    test('initial state is RegisterMotherInitial', () {
      expect(registerMotherCubit.state, equals(RegisterMotherInitial()));
    });

    group('saveTest', () {
      blocTest<RegisterMotherCubit, RegisterMotherState>(
        'emits [Loading, Success] when saving is successful',
        build: () {
          // Arrange
          when(() => mockDatabases.createDocument(
            databaseId: any(named: 'databaseId'),
            collectionId: AppConstants.userCollectionId,
            documentId: any(named: 'documentId'),
            data: any(named: 'data'),
          )).thenAnswer((_) async => MockDocument());

          when(() => mockDatabases.updateDocument(
            databaseId: any(named: 'databaseId'),
            collectionId: AppConstants.testsCollectionId,
            documentId: testTestModel.documentId!,
            data: any(named: 'data'),
          )).thenAnswer((_) async => MockDocument());

          // Replace the Databases instance in the cubit for this test
          registerMotherCubit = RegisterMotherCubit()
            ..client.setProject('test_project') // Mocking internal state
            ..client.setEndpoint('http://test.endpoint'); // Mocking internal state

          // This demonstrates how to inject the mock for a dependency created inside the method
          final cubitForTest = RegisterMotherCubit();
          final databases = mockDatabases; // Using our mock
          return cubitForTest;
        },
        act: (cubit) async {
          // A little hacky, but shows how to control the internal dependency.
          // Ideally, `Databases` would be injected.
          // For this test, we will assume the internal creation works and mock the calls.
          when(() => cubit.client).thenReturn(mockAppwriteClient);
          when(() => Databases(cubit.client)).thenReturn(mockDatabases);

          await cubit.saveTest(
            testName,
            testAge,
            testPatientId,
            testPickedDate,
            testTestModel,
            testDoctorName,
            testDoctorId,
          );
        },
        expect: () => [
          isA<RegisterMotherLoading>(),
          isA<RegisterMotherSuccess>(),
        ],
        verify: (_) {
          // Verify mother creation
          verify(() => mockDatabases.createDocument(
            databaseId: AppConstants.appwriteDatabaseId,
            collectionId: AppConstants.userCollectionId,
            documentId: any(named: 'documentId'),
            data: any(named: 'data', that: isA<Map<String, dynamic>>()),
          )).called(1);
          // Verify test update
          verify(() => mockDatabases.updateDocument(
            databaseId: AppConstants.appwriteDatabaseId,
            collectionId: AppConstants.testsCollectionId,
            documentId: testTestModel.documentId!,
            data: any(named: 'data', that: isA<Map<String, dynamic>>()),
          )).called(1);
        },
      );

      blocTest<RegisterMotherCubit, RegisterMotherState>(
        'emits [Loading, Failure] when saving throws an exception',
        build: () {
          final exception = AppwriteException('Something went wrong');
          when(() => mockDatabases.createDocument(
            databaseId: any(named: 'databaseId'),
            collectionId: any(named: 'collectionId'),
            documentId: any(named: 'documentId'),
            data: any(named: 'data'),
          )).thenThrow(exception);

          when(() => registerMotherCubit.client).thenReturn(mockAppwriteClient);
          when(() => Databases(registerMotherCubit.client)).thenReturn(mockDatabases);

          return registerMotherCubit;
        },
        act: (cubit) => cubit.saveTest(
          testName,
          testAge,
          testPatientId,
          testPickedDate,
          testTestModel,
          testDoctorName,
          testDoctorId,
        ),
        expect: () => [
          RegisterMotherLoading(),
          isA<RegisterMotherFailure>(),
        ],
      );
    });

    group('saveMother', () {
      test('returns true and emits [Success] on successful creation', () async {
        // Arrange
        when(() => mockDatabases.createDocument(
          databaseId: any(named: 'databaseId'),
          collectionId: any(named: 'collectionId'),
          documentId: any(named: 'documentId'),
          data: any(named: 'data'),
        )).thenAnswer((_) async => MockDocument());

        when(() => registerMotherCubit.client).thenReturn(mockAppwriteClient);
        when(() => Databases(registerMotherCubit.client)).thenReturn(mockDatabases);

        // Act & Assert
        final stream = registerMotherCubit.stream;
        expect(stream, emits(isA<RegisterMotherSuccess>()));

        final result = await registerMotherCubit.saveMother(
          testName,
          testAge,
          testPatientId,
          testPickedDate,
          testTestModel,
          testMobile,
          testDoctorName,
          testDoctorId,
        );

        expect(result, isTrue);

        verify(() => mockDatabases.createDocument(
          databaseId: AppConstants.appwriteDatabaseId,
          collectionId: AppConstants.userCollectionId,
          documentId: any(named: 'documentId'),
          data: any(named: 'data'),
        )).called(1);
      });

      test('returns false and does not emit state on failure', () async {
        // Arrange
        final exception = AppwriteException('Creation failed');
        when(() => mockDatabases.createDocument(
          databaseId: any(named: 'databaseId'),
          collectionId: any(named: 'collectionId'),
          documentId: any(named: 'documentId'),
          data: any(named: 'data'),
        )).thenThrow(exception);

        when(() => registerMotherCubit.client).thenReturn(mockAppwriteClient);
        when(() => Databases(registerMotherCubit.client)).thenReturn(mockDatabases);

        // Act
        final result = await registerMotherCubit.saveMother(
          testName,
          testAge,
          testPatientId,
          testPickedDate,
          testTestModel,
          testMobile,
          testDoctorName,
          testDoctorId,
        );

        // Assert
        expect(result, isFalse);
        // Verify no states were emitted since it's handled via return value
        expect(registerMotherCubit.state, isA<RegisterMotherInitial>());
      });
    });

    group('loadDoctors', () {
      final userWithDoctors = UserModel.withData(associations: {
        'doc_1': {'type': 'doctor', 'id': 'doc_1', 'name': 'Dr. First'},
        'org_1': {'type': 'organization', 'id': 'org_1', 'name': 'Some Hospital'},
        'doc_2': {'type': 'doctor', 'id': 'doc_2', 'name': 'Dr. Second'},
      });

      blocTest<RegisterMotherCubit, RegisterMotherState>(
        'emits [DoctorsLoaded] with filtered doctors from user preferences',
        build: () {
          when(() => mockPreferenceHelper.getUser()).thenReturn(userWithDoctors);
          return registerMotherCubit;
        },
        act: (cubit) => cubit.loadDoctors(),
        expect: () => [
          isA<DoctorsLoaded>().having(
                (state) => state.doctors,
            'doctors',
            [
              {'id': 'doc_1', 'name': 'Dr. First'},
              {'id': 'doc_2', 'name': 'Dr. Second'},
            ],
          ),
        ],
        verify: (_) {
          expect(registerMotherCubit.doctors.length, 2);
        },
      );
    });

    group('selectDoctor', () {
      final doctorsList = [
        {'id': 'doc_123', 'name': 'Dr. John'},
        {'id': 'doc_456', 'name': 'Dr. Jane'},
      ];

      blocTest<RegisterMotherCubit, RegisterMotherState>(
        'updates selected doctor and emits [DoctorSelected]',
        build: () {
          // Pre-load doctors into the cubit's internal list
          registerMotherCubit.doctors.addAll(doctorsList);
          return registerMotherCubit;
        },
        act: (cubit) => cubit.selectDoctor('doc_456'),
        expect: () => [
          isA<DoctorSelected>(),
        ],
        verify: (cubit) {
          expect(cubit.selectedDoctorId, 'doc_456');
          expect(cubit.selectedDoctorName, 'Dr. Jane');
        },
      );
    });
  });
}
