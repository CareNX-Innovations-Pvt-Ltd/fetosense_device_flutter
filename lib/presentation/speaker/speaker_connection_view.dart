/*
import 'package:fetosense_device_flutter/core/color_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import '../../core/bluetooth_service_helper.dart';

class SpeakerConnectionView extends StatefulWidget {
  const SpeakerConnectionView({super.key});

  @override
  State<SpeakerConnectionView> createState() => _SpeakerConnectionViewState();
}

class _SpeakerConnectionViewState extends State<SpeakerConnectionView> {
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;

  // bool _isConnected = false;
  // BluetoothConnection? _connection;
  //
  // List<BluetoothDevice> _devicesList = [];
  // bool _isDiscovering = false;
  //
  // BluetoothDevice? _selectedDevice;

  void bt() async {
    List<BluetoothDevice> devices =
        await BluetoothService().getClassicBluetoothDevices();
    for (var device in devices) {
      print("Classic Bluetooth Device: ${device.name} - ${device.address}");
    }

    await BluetoothService().connectToSpeaker("Mivi");
  }

  @override
  void initState() {
    super.initState();

    bt();
  }

  // Future<void> _checkBluetoothPermission() async {
  //   bool? isEnabled = await _bluetooth.isEnabled;
  //
  //   if (isEnabled == false) {
  //     await _bluetooth.requestEnable();
  //   }
  //
  //   await _getBondedDevices();
  // }
  //
  // Future<void> _getBondedDevices() async {
  //   List<BluetoothDevice> devices = [];
  //
  //   try {
  //     devices = await _bluetooth.getBondedDevices();
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print("Error getting bonded devices: $e");
  //     }
  //   }
  //
  //   setState(() {
  //     _devicesList = devices;
  //   });
  // }
  //
  // void _startDiscovery() {
  //   setState(() {
  //     _isDiscovering = true;
  //   });
  //
  //   _bluetooth.startDiscovery().listen((result) {
  //     debugPrint("devices discovered ${result.device.name}");
  //     debugPrint("devices discovered ${result.device.type}");
  //     debugPrint("devices discovered ${result.device.type.underlyingValue}");
  //     debugPrint("devices discovered ${result.device.type.stringValue}");
  //     final device = result.device;
  //     if (device.name != null) {
  //       setState(() {
  //         if (!_devicesList.contains(device)) {
  //           _devicesList.add(device);
  //         }
  //       });
  //     }
  //   }).onDone(() {
  //     setState(() {
  //       _isDiscovering = false;
  //     });
  //   });
  // }
  //
  // Future<void> _connectToDevice(BluetoothDevice device) async {
  //   // Disconnect if already connected
  //   if (_connection != null) {
  //     await _connection!.close();
  //     setState(() {
  //       _isConnected = false;
  //       _connection = null;
  //     });
  //   }
  //
  //   try {
  //     BluetoothConnection connection =
  //         await BluetoothConnection.toAddress(device.address);
  //     setState(() {
  //       _connection = connection;
  //       _isConnected = true;
  //       _selectedDevice = device;
  //     });
  //     _connection!.input!.listen((Uint8List data) {
  //       if (kDebugMode) {
  //         print('Data incoming: ${String.fromCharCodes(data)}');
  //       }
  //     }).onDone(() {
  //       setState(() {
  //         _isConnected = false;
  //       });
  //     });
  //     if(mounted){
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Connected to ${device.name}'),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('Error connecting to device: $e');
  //     }
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Failed to connect to ${device.name}'),
  //         ),
  //       );
  //     }
  //   }
  // }
  //
  // void _sendDataToSpeaker(String data) {
  //   if (_connection != null && _isConnected) {
  //     try {
  //       _connection!.output.add(Uint8List.fromList(data.codeUnits));
  //       _connection!.output.allSent.then((_) {
  //         if (kDebugMode) {
  //           print('Data sent: $data');
  //         }
  //       });
  //     } catch (e) {
  //       if (kDebugMode) {
  //         print('Error sending data: $e');
  //       }
  //     }
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Not connected to any device'),
  //       ),
  //     );
  //   }
  // }
  //
  // // Disconnect from device
  // void _disconnect() async {
  //   if (_connection != null) {
  //     await _connection!.close();
  //     setState(() {
  //       _isConnected = false;
  //       _connection = null;
  //     });
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Disconnected from device'),
  //         ),
  //       );
  //     }
  //   }
  // }
  //
  // @override
  // void dispose() {
  //   if (_connection != null) {
  //     _connection!.dispose();
  //   }
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Connecting speaker ',
                      style: TextStyle(
                        fontSize: 22,
                      ),
                    ),
                    SizedBox(
                      width: 12,
                    ),
                    CircularProgressIndicator(),
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.7,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: ColorManager.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            height: 300,
                            child: Image.asset('assets/ic_speaker.png'),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Row(
                              //   children: [
                              //     Text(
                              //       'Status: ${_selectedDevice?.name}',
                              //       style: const TextStyle(
                              //         fontSize: 22,
                              //       ),
                              //     ),
                              //   ],
                              // ),
                              const Row(
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        '1. Turn on the speaker.',
                                        style: TextStyle(
                                          fontSize: 22,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        '2. Check for the blue light',
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
                                    onPressed: () {},
                                    child: const Text('RETRY'),
                                  ),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  ElevatedButton(
                                    onPressed: () {},
                                    style: const ButtonStyle(
                                      backgroundColor:
                                          WidgetStatePropertyAll<Color>(
                                        ColorManager.primaryButtonColor,
                                      ),
                                    ),
                                    child: const Text(
                                      'SKIP',
                                      style:
                                          TextStyle(color: ColorManager.white),
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
  }

// Widget temp() {
//   return SafeArea(
//     child: Scaffold(
//       body: Column(
//         children: [
//           // Connection status
//           Container(
//             padding: const EdgeInsets.all(16),
//             color: _isConnected ? Colors.green.shade100 : Colors.red.shade100,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   _isConnected
//                       ? 'Connected to ${_selectedDevice?.name}'
//                       : 'Not connected',
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 if (_isConnected)
//                   ElevatedButton(
//                     onPressed: _disconnect,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.red,
//                     ),
//                     child: const Text('Disconnect'),
//                   ),
//               ],
//             ),
//           ),
//
//           Expanded(
//             child: ListView.builder(
//               itemCount: _devicesList.length,
//               itemBuilder: (context, index) {
//                 final device = _devicesList[index];
//                 final isSelected = _selectedDevice?.address == device.address;
//                 return ListTile(
//                   title: Text(device.name ?? 'Unknown Device'),
//                   subtitle: Text(device.address),
//                   trailing: isSelected
//                       ? const Icon(Icons.bluetooth_connected, color: Colors.blue)
//                       : const Icon(Icons.bluetooth),
//                   selected: isSelected,
//                   onTap: _isConnected ? null : () => _connectToDevice(device),
//                 );
//               },
//             ),
//           ),
//
//           // Controls
//           if (_isConnected)
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 children: [
//                   const Text('Speaker Controls',
//                       style: TextStyle(fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 8),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       ElevatedButton(
//                         onPressed: () => _sendDataToSpeaker('PLAY'),
//                         child: const Icon(Icons.play_arrow),
//                       ),
//                       ElevatedButton(
//                         onPressed: () => _sendDataToSpeaker('PAUSE'),
//                         child: const Icon(Icons.pause),
//                       ),
//                       ElevatedButton(
//                         onPressed: () => _sendDataToSpeaker('VOL_UP'),
//                         child: const Icon(Icons.volume_up),
//                       ),
//                       ElevatedButton(
//                         onPressed: () => _sendDataToSpeaker('VOL_DOWN'),
//                         child: const Icon(Icons.volume_down),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     ),
//   );
// }
}
*/
