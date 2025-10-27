import 'package:bloc_test/bloc_test.dart';
import 'package:fetosense_device_flutter/data/models/mother_model.dart';
import 'package:fetosense_device_flutter/data/models/test_model.dart';
import 'package:fetosense_device_flutter/presentation/mother_details/mother_details_cubit.dart';
import 'package:fetosense_device_flutter/presentation/mother_details/mother_details_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



class MockMotherDetailsCubit extends MockCubit<MotherDetailsState>
    implements MotherDetailsCubit {}

void main() {
  late MockMotherDetailsCubit mockCubit;

  setUp(() {
    mockCubit = MockMotherDetailsCubit();
  });

  Mother sampleMother = Mother();

  Test sampleTest = Test.withData(
    motherName: 'Jane Doe',
    patientId: 'P123',
    deviceId: 'D001',
    deviceName: 'DeviceX',
    gAge: 38,
    createdOn: DateTime(2025, 7, 10, 14, 30), bpmEntries: [], bpmEntries2: [], baseLineEntries: [], movementEntries: [], autoFetalMovement: [], tocoEntries: [],
  );

  testWidgets('renders loading state', (WidgetTester tester) async {
    when(() => mockCubit.state).thenReturn(MotherDetailsLoading());
    when(() => mockCubit.fetchTests(any())).thenAnswer((_) async {});

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<MotherDetailsCubit>.value(
          value: mockCubit,
          child: MotherDetailsPage(mother: sampleMother),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders failure state', (WidgetTester tester) async {
    when(() => mockCubit.state)
        .thenReturn(const MotherDetailsFailure("Failed to fetch"));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<MotherDetailsCubit>.value(
          value: mockCubit,
          child: MotherDetailsPage(mother: sampleMother),
        ),
      ),
    );

    expect(find.text('Failed to fetch'), findsOneWidget);
  });

  testWidgets('renders success state with test list', (WidgetTester tester) async {
    when(() => mockCubit.state)
        .thenReturn(MotherDetailsSuccess([sampleTest]));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<MotherDetailsCubit>.value(
          value: mockCubit,
          child: MotherDetailsPage(mother: sampleMother),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Jane Doe'), findsOneWidget);
    expect(find.text('Patient ID: P123'), findsOneWidget);
    expect(find.text('Test #1'), findsOneWidget);
    expect(find.textContaining('Gestational Age: 38 weeks'), findsOneWidget);
    expect(find.textContaining('Device: DeviceX'), findsOneWidget);
    expect(find.textContaining('Date: 10 Jul 25'), findsOneWidget); // date format may vary
  });
}
