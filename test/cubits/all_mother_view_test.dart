import 'package:bloc_test/bloc_test.dart';
import 'package:fetosense_device_flutter/core/constants/app_routes.dart';
import 'package:fetosense_device_flutter/data/models/mother_model.dart';
import 'package:fetosense_device_flutter/presentation/all_mothers/all_mothers_cubit.dart';
import 'package:fetosense_device_flutter/presentation/all_mothers/all_mothers_view.dart';
import 'package:fetosense_device_flutter/presentation/widgets/animated_counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';

class MockAllMothersCubit extends MockCubit<AllMothersState> implements AllMothersCubit {}
class MockGoRouter extends Mock implements GoRouter {}

void main() {
  group('AllMothersView', () {
    late MockAllMothersCubit mockAllMothersCubit;
    late MockGoRouter mockGoRouter;

    setUp(() {
      mockAllMothersCubit = MockAllMothersCubit();
      mockGoRouter = MockGoRouter();
    });

    testWidgets('displays CircularProgressIndicator when state is AllMothersLoading', (tester) async {
      when(() => mockAllMothersCubit.state).thenReturn(AllMothersLoading());
      when(() => mockAllMothersCubit.getMothersList()).thenReturn(Future.value());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AllMothersCubit>(
            create: (_) => mockAllMothersCubit,
            child: const AllMothersView(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays error message when state is AllMothersFailure', (tester) async {
      const errorMessage = 'Failed to load mothers';
      when(() => mockAllMothersCubit.state).thenReturn(const AllMothersFailure(errorMessage));
      when(() => mockAllMothersCubit.getMothersList()).thenReturn(Future.value());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AllMothersCubit>(
            create: (_) => mockAllMothersCubit,
            child: const AllMothersView(),
          ),
        ),
      );

      expect(find.text('Error: $errorMessage'), findsOneWidget);
    });

    testWidgets('displays "No mothers found." when state is AllMothersSuccess and mothers list is empty', (tester) async {
      when(() => mockAllMothersCubit.state).thenReturn(const AllMothersSuccess([]));
      when(() => mockAllMothersCubit.getMothersList()).thenReturn(Future.value());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AllMothersCubit>(
            create: (_) => mockAllMothersCubit,
            child: const AllMothersView(),
          ),
        ),
      );

      expect(find.text('No mothers found.'), findsOneWidget);
    });

    testWidgets('displays mothers data when state is AllMothersSuccess and mothers list is not empty', (tester) async {
      final mothers = [
        Mother(),
        Mother(),
      ];
      when(() => mockAllMothersCubit.state).thenReturn(AllMothersSuccess( mothers));
      when(() => mockAllMothersCubit.getMothersList()).thenReturn(Future.value());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AllMothersCubit>(
            create: (_) => mockAllMothersCubit,
            child: const AllMothersView(),
          ),
        ),
      );

      expect(find.text('Mother A'), findsOneWidget);
      expect(find.text('25'), findsOneWidget);
      expect(find.text('10 weeks'), findsOneWidget); // Assuming Utilities.getGestationalAgeWeeks formats like this
      expect(find.text('Mother B'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
      expect(find.text('20 weeks'), findsOneWidget); // Assuming Utilities.getGestationalAgeWeeks formats like this
      expect(find.text('Total'), findsOneWidget);
      expect(find.text('Registered Mothers'), findsOneWidget);
      expect(find.text('Tests Performed'), findsOneWidget);
      expect(find.byType(AnimatedCount), findsNWidgets(2));
    });

    testWidgets('calls filterMothers when search text changes', (tester) async {
      when(() => mockAllMothersCubit.state).thenReturn(const AllMothersSuccess( []));
      when(() => mockAllMothersCubit.getMothersList()).thenReturn(Future.value());
      when(() => mockAllMothersCubit.filterMothers(any())).thenReturn(null); // Mock the filterMothers method

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AllMothersCubit>(
            create: (_) => mockAllMothersCubit,
            child: const AllMothersView(),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'test');
      verify(() => mockAllMothersCubit.filterMothers('test')).called(1);
    });

    testWidgets('navigates to mother details when a mother is tapped', (tester) async {
      final mothers = [
        Mother(),
      ];
      when(() => mockAllMothersCubit.state).thenReturn(AllMothersSuccess(mothers));
      when(() => mockAllMothersCubit.getMothersList()).thenReturn(Future.value());
      when(() => mockGoRouter.push(any(), extra: any(named: 'extra'))).thenReturn(Future.value()); // Mock the push method

      await tester.pumpWidget(
        MaterialApp(
            home: MockGoRouterProvider(router: mockGoRouter, child:  BlocProvider<AllMothersCubit>(
              create: (_) => mockAllMothersCubit,
              child: const AllMothersView(),
            ),)
        ),
      );

      await tester.tap(find.text('Mother A'));
      verify(() => mockGoRouter.push(AppRoutes.motherDetails, extra: mothers[0])).called(1);
    });

    testWidgets('calls context.pop() when back button is pressed', (tester) async {
      when(() => mockAllMothersCubit.state).thenReturn(AllMothersLoading());
      when(() => mockAllMothersCubit.getMothersList()).thenReturn(Future.value());
      when(() => mockGoRouter.pop()).thenReturn(null); // Mock the pop method

      await tester.pumpWidget(
        MaterialApp(
            home: MockGoRouterProvider(router: mockGoRouter, child:  BlocProvider<AllMothersCubit>(
              create: (_) => mockAllMothersCubit,
              child: const AllMothersView(),
            ),)
        ),
      );

      await tester.tap(find.byIcon(Icons.arrow_back));
      verify(() => mockGoRouter.pop()).called(1);

    });

    testWidgets('autofocus is set correctly', (tester) async {
      when(() => mockAllMothersCubit.state).thenReturn(AllMothersLoading());
      when(() => mockAllMothersCubit.getMothersList()).thenReturn(Future.value());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AllMothersCubit>(
            create: (_) => mockAllMothersCubit,
            child: const AllMothersView(autoFocus: true),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.autofocus, isTrue);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AllMothersCubit>(
            create: (_) => mockAllMothersCubit,
            child: const AllMothersView(autoFocus: false),
          ),
        ),
      );

      final textField2 = tester.widget<TextField>(find.byType(TextField));
      expect(textField2.autofocus, isFalse);
    });

  });
}

// Helper widget to provide GoRouter for testing
class MockGoRouterProvider extends InheritedWidget {
  const MockGoRouterProvider({super.key, required this.router, required super.child});

  final GoRouter router;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;

  static GoRouter of(BuildContext context) {
    final MockGoRouterProvider? result = context.dependOnInheritedWidgetOfExactType<MockGoRouterProvider>();
    assert(result != null, 'No MockGoRouterProvider found in context');
    return result!.router;
  }
}

// Extend BuildContext to provide goRouter extension
extension MockBuildContextGoRouter on BuildContext {
  GoRouter get goRouter => MockGoRouterProvider.of(this);
}
