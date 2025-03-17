import 'package:fetosense_device_flutter/core/bluetooth_service_helper.dart';
import 'package:fetosense_device_flutter/core/color_manager.dart';
import 'package:fetosense_device_flutter/core/dependency_injection.dart';
import 'package:fetosense_device_flutter/presentation/doppler_connection/bluetoothlocal_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class DopplerConnectionView extends StatefulWidget {
  const DopplerConnectionView({super.key});

  @override
  State<DopplerConnectionView> createState() => _DopplerConnectionViewState();
}

class _DopplerConnectionViewState extends State<DopplerConnectionView> {
  final bool _isLoading = false;

  final BluetoothSerialService _bluetoothService = ServiceLocator.bluetoothServiceHelper;

  //List<BluetoothDevice> _pairedDevices = [];
  late BluetoothDevice _device;

  void _initializeBluetooth() async {
    // Enable Bluetooth
    bool bluetoothEnabled = await _bluetoothService.enableBluetooth();
    if (!bluetoothEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bluetooth could not be enabled')));
      return;
    }
    debugPrint("_initializeBluetooth--->> $bluetoothEnabled");

    List<BluetoothDevice> devices = await _bluetoothService.getPairedDevices();
    debugPrint("device--->> ${devices.toList()}");
    for (var device in devices) {
      debugPrint("device--->> ${device.name}");
      if((device.name?.toUpperCase().contains("EFM"))??false){
        setState(() {
          _device = device;
        });
        _connectToDevice(device);
      }
    }
    //print("devices--->> ${_pairedDevices[0].name}");
    //_connectToDevice(_pairedDevices[0]);
  }

  // Method to connect to a specific device
  void _connectToDevice(BluetoothDevice device) async {
    bool success = await _bluetoothService.connect(device);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connected to ${device.name}'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to connect to ${device.name}'),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // ServiceLocator.myAudioTrack.prepareAudioTrack();
    _initializeBluetooth();
  }

  @override
  void dispose() {
    // ServiceLocator.myAudioTrack.stopPlayer();
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 30),
                      width: 800,
                      height: 400,
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
                                      ElevatedButton(
                                        onPressed: () {
                                          // _bluetoothService.dispose();
                                          _initializeBluetooth();
                                        },
                                        style: const ButtonStyle(
                                          backgroundColor:
                                              WidgetStatePropertyAll<Color>(
                                            ColorManager.primaryButtonColor,
                                          ),
                                        ),
                                        child: const Text(
                                          'RETRY',
                                          style: TextStyle(
                                              color: ColorManager.white),
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
