import 'dart:async';

import 'package:fetosense_device_flutter/core/constants/app_routes.dart';
import 'package:fetosense_device_flutter/core/utils/bluetooth_service_helper.dart';
import 'package:fetosense_device_flutter/core/utils/color_manager.dart';
import 'package:fetosense_device_flutter/core/network/dependency_injection.dart';
import 'package:fetosense_device_flutter/data/models/mother_model.dart';
import 'package:fetosense_device_flutter/data/models/test_model.dart';
import 'package:fetosense_device_flutter/presentation/doppler_connection/bluetoothlocal_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// A stateful widget that manages and displays the Doppler device connection flow.
///
/// The `DopplerConnectionView` handles Bluetooth initialization, device scanning,
/// and connection logic for Doppler devices. It provides user feedback during
/// connection attempts, displays instructions, and navigates to the test view
/// upon successful connection. The widget uses a [BluetoothSerialService] for
/// Bluetooth operations and interacts with test and mother models.
///
/// Example usage:
/// ```dart
/// Navigator.push(context, MaterialPageRoute(
///   builder: (_) => DopplerConnectionView(test: test, mother: mother),
/// ));
/// ```

class DopplerConnectionView extends StatefulWidget {
  final String? previousRoute;
  final Test? test;
  final Mother? mother;

  const DopplerConnectionView(
      {super.key, this.previousRoute, this.test, this.mother});

  @override
  State<DopplerConnectionView> createState() => _DopplerConnectionViewState();
}

class _DopplerConnectionViewState extends State<DopplerConnectionView> {
  final bool _isLoading = false;
  Test? test;
  Mother? mother;
  final BluetoothSerialService _bluetoothService =
      ServiceLocator.bluetoothServiceHelper;

  List<BluetoothDevice> _pairedDevices = [];
  bool showLoader = true;
  String? route;

  void _initializeBluetooth() async {
    route = widget.previousRoute;
    bool bluetoothEnabled = await _bluetoothService.enableBluetooth();
    if (!bluetoothEnabled && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bluetooth could not be enabled'),
        ),
      );
      return;
    }

    List<BluetoothDevice> devices = await _bluetoothService.getPairedDevices();
    setState(() {
      _pairedDevices = devices;
    });
    debugPrint("devices--->> ${_pairedDevices[0].name}");
    _connectToDevice(_pairedDevices[0]);
  }

  DateTime formatDateTime(DateTime dateTime) {
    final formattedString = DateFormat("MMMM d, yyyy 'at' hh:mm:ss a 'UTC'XXX")
        .format(dateTime.toUtc().add(const Duration(hours: 5, minutes: 30)));

    return DateFormat("MMMM d, yyyy 'at' hh:mm:ss a 'UTC'XXX")
        .parse(formattedString);
  }

  void _connectToDevice(BluetoothDevice device) async {
    bool success = await _bluetoothService.connect(device);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text('Connected to ${device.name}'),
        ),
      );

      test?.autoFetalMovement = [];
      test?.tocoEntries = [];
      test?.bpmEntries = [];
      test?.movementEntries = [];
      test?.associations = <String, dynamic>{};
      test?.autoFetalMovement = [];
      test?.baseLineEntries = [];
      test?.bpmEntries2 = [];
      test?.mhrEntries = [];
      test?.createdOn = formatDateTime(DateTime.now());
      test?.spo2Entries = [];
      test?.documentId = '';
      test?.motherId = '';
      test?.deviceName = device.name;
      test?.associations = <String, dynamic>{};
      test?.organizationName = '';
      test?.doctorName = '';
      test?.organizationId = '';
      test?.doctorId = '';

      if (mounted) {
        context.push(AppRoutes.testView,
            extra: {'test': test, 'route': route, 'mother': mother});
      }
    } else {
      setState(() {
        showLoader = false;
      });
      debugPrint("Failed to connect to  ${device.name}");
     if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to connect to ${device.name}'),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    test = widget.test;
    mother = widget.mother;
    _initializeBluetooth();
    Timer(const Duration(seconds: 30), () {
      if (mounted) {
        setState(() => showLoader = false);
      }
    });
  }

  @override
  void dispose() {
    _bluetoothService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BluetoothConnectionBloc, BluetoothConnectionStateLocal>(
      builder: (context, state) {
        return SafeArea(
          child: Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Connecting doppler ',
                          style: TextStyle(
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        _isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(),
                              )
                            : Container(),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 30),
                        width: 800,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: ColorManager.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(38.0),
                                  child: SizedBox(
                                    height: 600,
                                    child: Image.asset('assets/ic_probe.png'),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    const Row(
                                      children: [
                                        Column(
                                          children: [
                                            Text(
                                              '1. Turn on the doppler.',
                                              style: TextStyle(
                                                fontSize: 22,
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            Text(
                                              '2. Make sure the battery is charged.',
                                              style: TextStyle(
                                                fontSize: 22,
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        showLoader
                                            ? const CircularProgressIndicator()
                                            : ElevatedButton(
                                                onPressed: () {
                                                  _initializeBluetooth();
                                                },
                                                style: const ButtonStyle(
                                                  backgroundColor:
                                                      WidgetStatePropertyAll<
                                                          Color>(
                                                    ColorManager
                                                        .primaryButtonColor,
                                                  ),
                                                ),
                                                child: const Text(
                                                  'RETRY',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                      ],
                                    )
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
