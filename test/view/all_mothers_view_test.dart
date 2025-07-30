import 'package:bloc_test/bloc_test.dart';
import 'package:fetosense_device_flutter/data/models/mother_model.dart';
import 'package:fetosense_device_flutter/presentation/all_mothers/all_mothers_cubit.dart';
import 'package:fetosense_device_flutter/presentation/all_mothers/all_mothers_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MockAllMothersCubit extends MockCubit<AllMothersState>
    implements AllMothersCubit {}

void main() {
  late MockAllMothersCubit mockCubit;
  final mockMother = Mother()
    ..name = "Test Mother"
    ..age = 28
    ..lmp = DateTime.now().subtract(const Duration(days: 100))
    ..noOfTests = 3;

  setUp(() {
    mockCubit = MockAllMothersCubit();

    // 🛠️ Fix: mock this method to return a Future
    when(() => mockCubit.getMothersList()).thenAnswer((_) async {});
  });
  Widget createTestWidget() {
    return ScreenUtilInit(
      designSize: const Size(1440, 1024), // Match your app's base design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) {
        return MediaQuery(
          data: const MediaQueryData(size: Size(1440, 1024)),
          child: MaterialApp(
            home: BlocProvider<AllMothersCubit>.value(
              value: mockCubit,
              child: const AllMothersView(),
            ),
          ),
        );
      },
    );
  }

  testWidgets('displays loading indicator when state is AllMothersLoading',
          (WidgetTester tester) async {
        when(() => mockCubit.state).thenReturn(AllMothersLoading());

        await tester.pumpWidget(createTestWidget());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

  testWidgets('displays error message on AllMothersFailure',
          (WidgetTester tester) async {
        when(() => mockCubit.state).thenReturn(
          const AllMothersFailure("Something went wrong"),
        );

        await tester.pumpWidget(createTestWidget());

        expect(find.textContaining("Something went wrong"), findsOneWidget);
      });

  testWidgets('displays mother list on AllMothersSuccess',
          (WidgetTester tester) async {
        when(() => mockCubit.state).thenReturn(AllMothersSuccess([mockMother]));

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle(); // to settle animations

        expect(find.text('Registered Mothers'), findsOneWidget);
        expect(find.text('Test Mother'), findsOneWidget);
        expect(find.text('28'), findsOneWidget);
        expect(find.textContaining('Tests Performed'), findsOneWidget);
      });

  testWidgets('displays no mother message when list is empty',
          (WidgetTester tester) async {
        when(() => mockCubit.state).thenReturn(const AllMothersSuccess([]));

        await tester.pumpWidget(createTestWidget());

        expect(find.text('No mothers found.'), findsOneWidget);
      });
}
