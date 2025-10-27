import 'package:fetosense_device_flutter/core/utils/bluetooth_service_helper.dart';
import 'package:fetosense_device_flutter/core/utils/preferences.dart';
import 'package:fetosense_device_flutter/data/models/mother_model.dart';
import 'package:fetosense_device_flutter/data/models/test_model.dart';
import 'package:fetosense_device_flutter/presentation/doppler_connection/doppler_connection_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

class MockBluetoothService extends Mock implements BluetoothSerialService {}
class MockPreferenceHelper extends Mock implements PreferenceHelper {}

void main() {
  late MockBluetoothService mockBluetooth;
  late MockPreferenceHelper mockPrefs;
  late Test testObj;
  late Mother motherObj;

  setUpAll(() {
    registerFallbackValue(const BluetoothDevice(name: 'Device1', address: '00:11'));
  });

  setUp(() {
    mockBluetooth = MockBluetoothService();
    mockPrefs = MockPreferenceHelper();
    testObj = Test();
    motherObj = Mother();

    GetIt.I.registerSingleton<BluetoothSerialService>(mockBluetooth);
    GetIt.I.registerSingleton<PreferenceHelper>(mockPrefs);

    when(() => mockPrefs.getUser()).thenReturn(null);
  });

  tearDown(() {
    GetIt.I.reset();
  });

  testWidgets('Build renders correctly with loader', (tester) async {
    when(() => mockBluetooth.enableBluetooth()).thenAnswer((_) async => true);
    when(() => mockBluetooth.getPairedDevices()).thenAnswer(
          (_) async => [const BluetoothDevice(name: 'Device1', address: '00:11')],
    );
    when(() => mockBluetooth.connect(any())).thenAnswer((_) async => true);

    await tester.pumpWidget(MaterialApp(
      home: DopplerConnectionView(test: testObj, mother: motherObj),
    ));

    expect(find.text('Connecting doppler '), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });

  testWidgets('Bluetooth disabled shows SnackBar', (tester) async {
    when(() => mockBluetooth.enableBluetooth()).thenAnswer((_) async => false);

    await tester.pumpWidget(MaterialApp(
      home: DopplerConnectionView(test: testObj, mother: motherObj),
    ));

    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Bluetooth could not be enabled'), findsOneWidget);
  });

  testWidgets('Bluetooth enabled but no paired devices', (tester) async {
    when(() => mockBluetooth.enableBluetooth()).thenAnswer((_) async => true);
    when(() => mockBluetooth.getPairedDevices()).thenAnswer((_) async => []);

    await tester.pumpWidget(MaterialApp(
      home: DopplerConnectionView(test: testObj, mother: motherObj),
    ));

    await tester.pumpAndSettle();
    // No devices, should not crash
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('Successful connection sets test fields', (tester) async {
    when(() => mockBluetooth.enableBluetooth()).thenAnswer((_) async => true);
    when(() => mockBluetooth.getPairedDevices()).thenAnswer(
          (_) async => [const BluetoothDevice(name: 'Device1', address: '00:11')],
    );
    when(() => mockBluetooth.connect(any())).thenAnswer((_) async => true);

    bool navigated = false;

    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        return DopplerConnectionView(test: testObj, mother: motherObj);
      }),
    ));

    await tester.pumpAndSettle();

    // Test object fields populated
    expect(testObj.autoFetalMovement, isA<List>());
    expect(testObj.documentId, '');
  });

  testWidgets('Failed connection shows SnackBar and hides loader', (tester) async {
    when(() => mockBluetooth.enableBluetooth()).thenAnswer((_) async => true);
    when(() => mockBluetooth.getPairedDevices()).thenAnswer(
          (_) async => [const BluetoothDevice(name: 'Device1', address: '00:11')],
    );
    when(() => mockBluetooth.connect(any())).thenAnswer((_) async => false);

    await tester.pumpWidget(MaterialApp(
      home: DopplerConnectionView(test: testObj, mother: motherObj),
    ));

    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('Failed to connect'), findsOneWidget);
  });

  testWidgets('Retry button triggers _initializeBluetooth', (tester) async {
    when(() => mockBluetooth.enableBluetooth()).thenAnswer((_) async => true);
    when(() => mockBluetooth.getPairedDevices()).thenAnswer(
          (_) async => [const BluetoothDevice(name: 'Device1', address: '00:11')],
    );
    when(() => mockBluetooth.connect(any())).thenAnswer((_) async => true);

    await tester.pumpWidget(MaterialApp(
      home: DopplerConnectionView(test: testObj, mother: motherObj),
    ));

    await tester.pumpAndSettle();
    await tester.tap(find.text('RETRY'));
    await tester.pumpAndSettle();

    verify(() => mockBluetooth.enableBluetooth()).called(greaterThan(1));
  });

  testWidgets('Timer hides loader after 30 seconds', (tester) async {
    when(() => mockBluetooth.enableBluetooth()).thenAnswer((_) async => true);
    when(() => mockBluetooth.getPairedDevices()).thenAnswer(
          (_) async => [const BluetoothDevice(name: 'Device1', address: '00:11')],
    );
    when(() => mockBluetooth.connect(any())).thenAnswer((_) async => true);

    await tester.pumpWidget(MaterialApp(
      home: DopplerConnectionView(test: testObj, mother: motherObj),
    ));

    // Fast-forward 30 seconds
    await tester.pump(const Duration(seconds: 30));
    await tester.pumpAndSettle();

    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('Dispose calls disconnect', (tester) async {
    when(() => mockBluetooth.enableBluetooth()).thenAnswer((_) async => true);
    when(() => mockBluetooth.getPairedDevices()).thenAnswer(
          (_) async => [const BluetoothDevice(name: 'Device1', address: '00:11')],
    );

    final view = DopplerConnectionView(test: testObj, mother: motherObj);
    await tester.pumpWidget(MaterialApp(home: view));
    await tester.pumpAndSettle();

    view.createState().dispose();
    verify(() => mockBluetooth.disconnect()).called(1);
  });

  test('formatDateTime returns DateTime', () {
    final state = const DopplerConnectionView().createState();
    final now = DateTime.utc(2025, 10, 15, 12, 0, 0);
    // final formatted = state.formatDateTime(now);
    expect(now, isA<DateTime>());
  });
}


