import 'package:fetosense_device_flutter/core/utils/bluetooth_service_helper.dart';
import 'package:fetosense_device_flutter/core/utils/preferences.dart';
import 'package:fetosense_device_flutter/presentation/home/home_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';


class MockPreferenceHelper extends Mock implements PreferenceHelper {}

class MockBluetoothSerialService extends Mock implements BluetoothSerialService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockPreferenceHelper mockPrefs;
  late MockBluetoothSerialService mockBluetooth;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});

    mockPrefs = MockPreferenceHelper();
    mockBluetooth = MockBluetoothSerialService();

    // Register mocks
    final getIt = GetIt.instance;
    getIt.reset();

    getIt.registerSingleton<PreferenceHelper>(mockPrefs);
    getIt.registerSingleton<BluetoothSerialService>(mockBluetooth);

    // Stub Future<void> methods to return valid futures
    when(() => mockBluetooth.disconnect()).thenAnswer((_)=> Future.value );
    when(() => mockBluetooth.dispose()).thenAnswer((_) => Future.value);
  });

  testWidgets('HomeView renders properly', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeView()));
    await tester.pumpAndSettle();

    expect(find.byType(HomeView), findsOneWidget);
  });
}
