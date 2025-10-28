import 'package:bloc_test/bloc_test.dart';
import 'package:fetosense_device_flutter/core/constants/app_constants.dart';
import 'package:fetosense_device_flutter/core/constants/app_routes.dart';
import 'package:fetosense_device_flutter/core/utils/preferences.dart';
import 'package:fetosense_device_flutter/data/models/mother_model.dart';
import 'package:fetosense_device_flutter/data/models/test_model.dart';
import 'package:fetosense_device_flutter/presentation/register_mother/register_mother_cubit.dart';
import 'package:fetosense_device_flutter/presentation/register_mother/register_mother_view.dart';
import 'package:fetosense_device_flutter/presentation/widgets/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

// --- Mocks ---
class MockRegisterMotherCubit extends MockCubit<RegisterMotherState>
    implements RegisterMotherCubit {}

class MockGoRouter extends Mock implements GoRouter {}

class MockPreferenceHelper extends Mock implements PreferenceHelper {}

class MockMother extends Mock implements Mother {}

// --- Test Data ---
// FIX: The `Test` model does not have a `withData` constructor. Use the default constructor.
final mockTest = Test.withData(
  motherName: 'Jane Doe',
  patientId: 'P123',
  deviceId: 'D001',
  deviceName: 'DeviceX',
  gAge: 38,
  createdOn: DateTime(2025, 7, 10, 14, 30), bpmEntries: [], bpmEntries2: [], baseLineEntries: [], movementEntries: [], autoFetalMovement: [], tocoEntries: [],
);
final mockMother = MockMother();
final mockDoctors = [
  {'id': 'doc_1', 'name': 'Dr. First'},
  {'id': 'doc_2', 'name': 'Dr. Second'},
];

// Helper to register fallbacks for complex types used in mocks
void _registerFallbacks() {
  registerFallbackValue(mockTest);
  registerFallbackValue({'test': mockTest}); // For GoRouter `extra`
  registerFallbackValue(
    {
      'test': mockTest,
      'route': AppConstants.registeredMother,
      'mother': mockMother,
    },
  );
}

void main() {
  late MockRegisterMotherCubit mockCubit;
  late MockGoRouter mockGoRouter;
  late MockPreferenceHelper mockPreferenceHelper;

  setUpAll(() {
    _registerFallbacks();
    // Setup GetIt for dependency injection before tests run
    mockPreferenceHelper = MockPreferenceHelper();
    if (!GetIt.I.isRegistered<PreferenceHelper>()) {
      GetIt.I.registerSingleton<PreferenceHelper>(mockPreferenceHelper);
    }
  });

  setUp(() {
    // Reset mocks before each test
    mockGoRouter = MockGoRouter();
    mockCubit = MockRegisterMotherCubit();

    // Default stub for doctor loading in initState
    when(() => mockCubit.loadDoctors()).thenAnswer((_) async {});
    // Default stubs for internal cubit state
    when(() => mockCubit.doctors).thenReturn(mockDoctors);
    when(() => mockCubit.selectedDoctorId).thenReturn(null);
    when(() => mockCubit.selectedDoctorName).thenReturn(null);

    // Default stub for router calls
    when(() => mockGoRouter.pushReplacement(any(), extra: any(named: 'extra')))
        .thenAnswer((_) async => {});
    when(() => mockGoRouter.pop()).thenAnswer((_) async {});
  });

  // Helper function to build the widget tree with necessary providers
  Widget createTestableWidget(Widget child) {
    return BlocProvider<RegisterMotherCubit>.value(
      value: mockCubit,
      child: MaterialApp(
        // FIX: The MockGoRouter from go_router_builder is needed to mock routing context
        home: Scaffold(
          body: child,
        )
      ),
    );
  }

  group('RegisterMotherView', () {
    testWidgets('renders required form fields and loads doctors on initState',
            (WidgetTester tester) async {
          when(() => mockPreferenceHelper.getBool(AppConstants.patientIdKey))
              .thenReturn(false);
          when(() => mockCubit.state).thenReturn(RegisterMotherInitial());

          await tester
              .pumpWidget(
              createTestableWidget(RegisterMotherView(test: mockTest)));
          await tester.pump(); // Let builders run

          // Verify form fields
          expect(find.widgetWithText(TextFormField, 'Name'), findsOneWidget);
          expect(find.widgetWithText(TextFormField, 'Age'), findsOneWidget);
          expect(find.byType(DatePickerTextField), findsOneWidget);
          expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
          expect(find.widgetWithText(ElevatedButton, 'Register Mother'),
              findsOneWidget);

          // Verify Patient ID is hidden
          expect(
              find.widgetWithText(TextFormField, 'Patient Id'), findsNothing);

          // Verify initState calls
          verify(() => mockCubit.loadDoctors()).called(1);
          verify(() => mockPreferenceHelper.getBool(AppConstants.patientIdKey))
              .called(1);
        });

    testWidgets('shows Patient ID field when preference is true',
            (WidgetTester tester) async {
          when(() => mockPreferenceHelper.getBool(AppConstants.patientIdKey))
              .thenReturn(true);
          when(() => mockCubit.state).thenReturn(RegisterMotherInitial());

          await tester
              .pumpWidget(
              createTestableWidget(RegisterMotherView(test: mockTest)));
          await tester.pump(); // Re-pump to let the state update reflect

          expect(
              find.widgetWithText(TextFormField, 'Patient Id'), findsOneWidget);
        });

    testWidgets(
        'shows validation errors if required fields are empty on submit',
            (WidgetTester tester) async {
          when(() => mockPreferenceHelper.getBool(AppConstants.patientIdKey))
              .thenReturn(true); // show patient id field to test its validator
          when(() => mockCubit.state).thenReturn(RegisterMotherInitial());

          await tester
              .pumpWidget(
              createTestableWidget(RegisterMotherView(test: mockTest)));
          await tester.pump();

          await tester
              .tap(find.widgetWithText(ElevatedButton, 'Register Mother'));
          await tester.pump(); // Let validation messages appear

          expect(find.text('Name is required'), findsOneWidget);
          expect(find.text('Age is required'), findsOneWidget);
          expect(find.text('Patient ID required'), findsOneWidget);
        });

    testWidgets('shows SnackBar if LMP date is not picked on submit',
            (WidgetTester tester) async {
          when(() => mockPreferenceHelper.getBool(any())).thenReturn(false);
          when(() => mockCubit.state).thenReturn(RegisterMotherInitial());

          await tester
              .pumpWidget(
              createTestableWidget(RegisterMotherView(test: mockTest)));

          // Fill in valid data for other fields
          await tester.enterText(
              find.widgetWithText(TextFormField, 'Name'), 'Jane Doe');
          await tester.enterText(
              find.widgetWithText(TextFormField, 'Age'), '30');

          await tester
              .tap(find.widgetWithText(ElevatedButton, 'Register Mother'));
          await tester.pump(); // To show the SnackBar

          expect(find.text('Please select LMP date'), findsOneWidget);
          // Verify that cubit methods are NOT called
          verifyNever(
                  () =>
                  mockCubit.saveTest(
                      any(),
                      any(),
                      any(),
                      any(),
                      any(),
                      any(),
                      any()));
          verifyNever(() =>
              mockCubit.saveMother(
                  any(),
                  any(),
                  any(),
                  any(),
                  any(),
                  any(),
                  any(),
                  any()));
        });

    testWidgets(
        'calls saveTest when previousRoute is instantTest and form is valid',
            (WidgetTester tester) async {
          // Arrange
          when(() => mockPreferenceHelper.getBool(any())).thenReturn(false);
          when(() => mockCubit.state).thenReturn(RegisterMotherInitial());
          when(() => mockCubit.selectedDoctorId).thenReturn('doc_1');
          when(() => mockCubit.selectedDoctorName).thenReturn('Dr. First');
          when(() =>
              mockCubit.saveTest(
                  any(),
                  any(),
                  any(),
                  any(),
                  any(),
                  any(),
                  any()))
              .thenAnswer((_) async {});

          await tester.pumpWidget(createTestableWidget(RegisterMotherView(
            test: mockTest,
            previousRoute: AppConstants.instantTest,
          )));

          // Act
          await tester.enterText(
              find.widgetWithText(TextFormField, 'Name'), 'Jane Doe');
          await tester.enterText(
              find.widgetWithText(TextFormField, 'Age'), '30');
          // Simulate date selection
          final datePicker =
          tester.widget<DatePickerTextField>(find.byType(DatePickerTextField));
          datePicker.onDateSelected?.call(DateTime(2023, 10, 10));

          await tester
              .tap(find.widgetWithText(ElevatedButton, 'Register Mother'));
          await tester.pump();

          // Assert
          verify(() =>
              mockCubit.saveTest(
                'Jane Doe',
                '30',
                '',
                // Patient ID controller is empty
                any(that: isA<DateTime>()),
                mockTest,
                'Dr. First',
                'doc_1',
              )).called(1);
        });

    testWidgets(
        'calls saveMother when previousRoute is NOT instantTest and form is valid',
            (WidgetTester tester) async {
          // Arrange
          when(() => mockPreferenceHelper.getBool(any())).thenReturn(false);
          when(() => mockCubit.state).thenReturn(RegisterMotherInitial());
          when(() => mockCubit.selectedDoctorId).thenReturn('doc_1');
          when(() => mockCubit.selectedDoctorName).thenReturn('Dr. First');
          when(() =>
              mockCubit.saveMother(
                  any(),
                  any(),
                  any(),
                  any(),
                  any(),
                  any(),
                  any(),
                  any())).thenAnswer((_) async {});

          await tester.pumpWidget(createTestableWidget(RegisterMotherView(
            test: mockTest,
            previousRoute: AppConstants.registeredMother, // Different route
          )));

          // Act
          await tester.enterText(
              find.widgetWithText(TextFormField, 'Name'), 'Jane Doe');
          await tester.enterText(
              find.widgetWithText(TextFormField, 'Age'), '30');
          // Simulate date selection
          final datePicker =
          tester.widget<DatePickerTextField>(find.byType(DatePickerTextField));
          datePicker.onDateSelected?.call(DateTime(2023, 10, 10));

          await tester
              .tap(find.widgetWithText(ElevatedButton, 'Register Mother'));
          await tester.pump();

          // Assert
          verify(() =>
              mockCubit.saveMother(
                'Jane Doe',
                '30',
                '',
                any(that: isA<DateTime>()),
                mockTest,
                '',
                // Phone number controller is commented out in the view
                'Dr. First',
                'doc_1',
              )).called(1);
        });

    testWidgets(
        'navigates to detailsView on RegisterMotherSuccess with instantTest route',
            (WidgetTester tester) async {
          // Arrange
          // FIX: The RegisterMotherSuccess state requires named parameters `test` and `mother`.
          final successState =
          RegisterMotherSuccess(mockTest, mockMother);

          // Set up the BlocListener to listen for the state change
          whenListen(mockCubit, Stream.fromIterable([successState]),
              initialState: RegisterMotherInitial());

          // Act
          await tester.pumpWidget(createTestableWidget(RegisterMotherView(
            test: mockTest,
            previousRoute: AppConstants.instantTest,
          )));
          await tester.pump(); // Let listener process the state

          // Assert
          verify(() =>
              mockGoRouter.pushReplacement(AppRoutes.detailsView,
                  extra: {'test': mockTest})).called(1);
        });

    testWidgets(
        'navigates to dopplerConnectionView on RegisterMotherSuccess with other routes',
            (WidgetTester tester) async {
          // Arrange
          // FIX: The RegisterMotherSuccess state requires named parameters `test` and `mother`.
          final successState =
          RegisterMotherSuccess(mockTest, mockMother);

          // Set up the BlocListener to listen for the state change
          whenListen(mockCubit, Stream.fromIterable([successState]),
              initialState: RegisterMotherInitial());

          // Act
          await tester.pumpWidget(createTestableWidget(RegisterMotherView(
            test: mockTest,
            previousRoute: AppConstants.registeredMother,
          )));
          await tester.pump();

          // Assert
          verify(() =>
              mockGoRouter.pushReplacement(
                AppRoutes.dopplerConnectionView,
                extra: {
                  'test': mockTest,
                  'route': AppConstants.registeredMother,
                  'mother': mockMother
                },
              )).called(1);
        });

    testWidgets('calls selectDoctor when a doctor is selected from dropdown',
            (WidgetTester tester) async {
          when(() => mockCubit.state).thenReturn(RegisterMotherInitial());

          await tester
              .pumpWidget(
              createTestableWidget(RegisterMotherView(test: mockTest)));
          await tester.pumpAndSettle(); // Wait for dropdown to be ready

          await tester.tap(find.byType(DropdownButtonFormField<String>));
          await tester.pumpAndSettle(); // Wait for items to appear

          await tester.tap(find
              .text('Dr. Second')
              .last);
          await tester.pumpAndSettle();

          verify(() => mockCubit.selectDoctor('doc_2')).called(1);
        });

    testWidgets('pops view when back button is pressed',
            (WidgetTester tester) async {
          when(() => mockCubit.state).thenReturn(RegisterMotherInitial());

          await tester
              .pumpWidget(
              createTestableWidget(RegisterMotherView(test: mockTest)));
          await tester.pumpAndSettle();

          await tester.tap(find.byIcon(Icons.arrow_back));
          await tester.pumpAndSettle();

          verify(() => mockGoRouter.pop()).called(1);
        });

    testWidgets('does not render doctor dropdown if doctors list is empty',
            (WidgetTester tester) async {
          when(() => mockCubit.doctors).thenReturn([]); // Empty list
          when(() => mockCubit.state).thenReturn(RegisterMotherInitial());

          await tester
              .pumpWidget(
              createTestableWidget(RegisterMotherView(test: mockTest)));
          await tester.pump();

          expect(find.byType(DropdownButtonFormField<String>), findsNothing);
          expect(find.byType(SizedBox),
              findsWidgets); // The placeholder is a SizedBox
        });
  });
}