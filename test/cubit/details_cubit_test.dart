import 'package:fetosense_device_flutter/core/utils/preferences.dart';
import 'package:fetosense_device_flutter/data/models/test_model.dart';
import 'package:fetosense_device_flutter/presentation/details/details_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/scheduler.dart';

class MockPreferenceHelper extends Mock implements PreferenceHelper {}

class TestVSync implements TickerProvider {
  const TestVSync();
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}

void main() {
  late DetailsCubit detailsCubit;
  late PreferenceHelper mockPrefs;

  setUp(() {
    mockPrefs = MockPreferenceHelper();
    GetIt.I.registerSingleton<PreferenceHelper>(mockPrefs);
  });

  tearDown(() {
    GetIt.I.reset();
  });

  group('DetailsCubit', () {
    final tests = Test.withData(
      bpmEntries: List.generate(200, (_) => 140),
      bpmEntries2: [],
      gAge: 32,
      lengthOfTest: 200,
      movementEntries: [],
      autoFetalMovement: [],
      live: false,
      createdOn: DateTime.now(), baseLineEntries: [], tocoEntries: [],
    );

    // test('initializes with given test data', () {
    //   detailsCubit = DetailsCubit(tests);
    //   expect(detailsCubit.state.test, tests);
    // });

    testWidgets('onDragStart updates mTouchStart', (tester) async {
      detailsCubit = DetailsCubit(tests);
      detailsCubit.animationController = AnimationController(
        vsync: const TestVSync(),
        duration: const Duration(milliseconds: 300),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return GestureDetector(
                onPanStart: (details) {
                  detailsCubit.onDragStart(context, details);
                },
                child: Container(width: 300, height: 300, color: Colors.blue),
              );
            },
          ),
        ),
      );

      final gesture = await tester.startGesture(const Offset(100, 100));
      await tester.pump();

      expect(detailsCubit.mTouchStart, isNonZero);
      await gesture.up();
    });

    test('updateCallback updates test interpretation', () {
      detailsCubit = DetailsCubit(tests);
      detailsCubit.animationController = AnimationController(
        vsync: const TestVSync(),
        duration: const Duration(milliseconds: 300),
      );

      detailsCubit.updateCallback('Normal', 'All good', true);

      expect(detailsCubit.state.radioValue, 'Normal');
      expect(detailsCubit.state.test.interpretationExtraComments, 'All good');
    });

    test('handleZoomChange toggles gridPreMin', () {
      detailsCubit = DetailsCubit(tests);
      detailsCubit.animationController = AnimationController(
        vsync: const TestVSync(),
        duration: const Duration(milliseconds: 300),
      );

      final original = detailsCubit.state.gridPreMin;
      detailsCubit.handleZoomChange();

      expect(detailsCubit.state.gridPreMin, isNot(original));
    });
  });
}
