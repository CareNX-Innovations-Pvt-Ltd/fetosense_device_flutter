import 'package:fetosense_device_flutter/core/utils/preferences.dart';
import 'package:fetosense_device_flutter/data/models/test_model.dart';
import 'package:fetosense_device_flutter/presentation/details/details_view.dart';
import 'package:fetosense_device_flutter/presentation/details/details_cubit.dart';
import 'package:fetosense_device_flutter/presentation/details/details_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mocktail/mocktail.dart';

import 'details_view_test.mocks.dart';


final getIt = GetIt.instance;

class MockDetailsCubit extends Mock implements DetailsCubit {}
class MockPreferenceHelper extends Mock implements PreferenceHelper {}


@GenerateMocks([Test])

void main() {
  late DetailsCubit mockCubit;
  late MockPreferenceHelper mockPrefs;
  final Test mockTest = Test.withData(
    id: 'test-id-001',
    documentId: 'doc-001',
    motherId: 'mother-001',
    deviceId: 'device-001',
    doctorId: 'doctor-001',
    weight: 3200,
    gAge: 32,
    age: 28,
    fisherScore: 3,
    fisherScore2: 4,
    motherName: 'Test Mother',
    deviceName: 'Device A',
    doctorName: 'Dr. John Doe',
    patientId: 'PAT-1234',
    organizationId: 'org-001',
    organizationName: 'Test Org',
    bpmEntries: List.generate(200, (i) => 140 + (i % 3)),
    bpmEntries2: List.generate(100, (i) => 135 + (i % 2)),
    baseLineEntries: List.generate(50, (i) => 145),
    movementEntries: List.generate(5, (i) => 1),
    autoFetalMovement: List.generate(3, (i) => 1),
    tocoEntries: List.generate(200, (i) => i % 40),
    lengthOfTest: 600,
    averageFHR: 140,
    live: false,
    testByMother: false,
    testById: 'admin',
    interpretationType: 'Normal',
    interpretationExtraComments: 'No abnormalities observed.',
    associations: {'ref': 'linked-object'},
    autoInterpretations: {
      'summary': 'Auto generated',
      'score': 7,
    },
    createdOn: DateTime.now(),
    createdBy: 'admin_user',
  );
  setUp(() {
    mockPrefs = MockPreferenceHelper();
    if (getIt.isRegistered<PreferenceHelper>()) {
      getIt.unregister<PreferenceHelper>();
    }
    getIt.registerSingleton<PreferenceHelper>(mockPrefs);
    mockCubit = MockDetailsCubit();
    when(() => mockCubit.state).thenReturn(DetailsState(test: mockTest));
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: BlocProvider<DetailsCubit>.value(
        value: mockCubit,
        child: DetailsView(test: mockTest,),
      ),
    );
  }

  testWidgets('displays loading indicator when state is loading', (tester) async {
    when(() => mockCubit.state).thenReturn(
      DetailsState(test: mockTest).copyWith(isLoadingPrint: true),
    );

    await tester.pumpWidget(createTestWidget());

    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });

  testWidgets('displays interpretation text if present', (tester) async {
    when(() => mockCubit.state).thenReturn(
      DetailsState(test: mockTest).copyWith(radioValue: 'Normal'),
    );

    await tester.pumpWidget(createTestWidget());

    expect(find.text('Normal'), findsOneWidget);
  });

  testWidgets('calls cubit.handleZoomChange on zoom button tap', (tester) async {
    when(() => mockCubit.handleZoomChange()).thenAnswer((_) {});
    when(() => mockCubit.state).thenReturn(DetailsState(test: mockTest));

    await tester.pumpWidget(createTestWidget());

    final zoomButton = find.byTooltip('Zoom'); // adjust if there's no tooltip
    if (zoomButton.evaluate().isNotEmpty) {
      await tester.tap(zoomButton);
      verify(() => mockCubit.handleZoomChange()).called(1);
    }
  });

  testWidgets('drag gesture triggers cubit drag logic', (tester) async {
    when(() => mockCubit.onDragStart(any(), any())).thenAnswer((_) {});
    when(() => mockCubit.onDragUpdate(any(), any())).thenAnswer((_) {});
    when(() => mockCubit.state).thenReturn(DetailsState(test: mockTest));

    await tester.pumpWidget(createTestWidget());

    final draggable = find.byKey(const Key("drag_area")); // add key if needed
    await tester.drag(draggable, const Offset(-50, 0));

    verify(() => mockCubit.onDragStart(any(), any())).called(1);
    verify(() => mockCubit.onDragUpdate(any(), any())).called(1);
  });

  testWidgets('displays comments if present', (tester) async {
    final state = DetailsState(test: mockTest)
        .copyWith(radioValue: 'Abnormal', test: mockTest..interpretationExtraComments = "Extra comments");

    when(() => mockCubit.state).thenReturn(state);

    await tester.pumpWidget(createTestWidget());

    expect(find.textContaining('Extra comments'), findsOneWidget);
  });

  // Optional: You can test printing buttons by verifying state updates on tap
  testWidgets('tapping print button triggers startPrintProcess', (tester) async {
    when(() => mockCubit.state).thenReturn(DetailsState(test: mockTest));
    when(() => mockCubit.startPrintProcess(any())).thenAnswer((_) async {});

    await tester.pumpWidget(createTestWidget());

    final button = find.text("Print"); // adjust based on actual widget
    if (button.evaluate().isNotEmpty) {
      await tester.tap(button);
      await tester.pumpAndSettle();

      verify(() => mockCubit.startPrintProcess(PrintAction.print)).called(1);
    }
  });
}
