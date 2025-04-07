import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:fetosense_device_flutter/core/constants/app_routes.dart';
import 'package:fetosense_device_flutter/core/utils/bluetooth_service_helper.dart';
import 'package:fetosense_device_flutter/core/utils/color_manager.dart';
import 'package:fetosense_device_flutter/core/constants/app_constants.dart';
import 'package:fetosense_device_flutter/core/network/dependency_injection.dart';
import 'package:fetosense_device_flutter/core/network/appwrite_config.dart';
import 'package:fetosense_device_flutter/core/utils/preferences.dart';
import 'package:fetosense_device_flutter/core/utils/utilities.dart';
import 'package:fetosense_device_flutter/data/models/intrepretations2.dart';
import 'package:fetosense_device_flutter/data/models/my_fhr_data.dart';
import 'package:fetosense_device_flutter/data/models/test_model.dart';
import 'package:fetosense_device_flutter/presentation/graph/graph_painter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class TestView extends StatefulWidget {
  final Test? test;
  final String? previousRoute;

  const TestView({super.key, this.test, this.previousRoute});

  @override
  State<TestView> createState() => _TestViewState();
}

class _TestViewState extends State<TestView> {
  Test? test;
  Interpretations2? interpretations;
  Interpretations2? interpretations2;
  String? radioValue;
  String? route;
  AppwriteService client = ServiceLocator.appwriteService;

  // final databaseReference = FirebaseFirestore.instance;
  double mTouchStart = 0;
  int mOffset = 0;
  int gridPreMin = 3;
  String? movements;
  bool isLoadingShare = false;
  bool isLoadingPrint = false;
  Action? action;
  Timer? countdownTimer;
  bool isTestRunning = false;
  DateTime? _startTime;
  DateTime? _endTime;
  final prefs = GetIt.I<PreferenceHelper>();
  bool isAlert = false;
  String selectedValue = '20 min';
  final AudioPlayer _audioPlayer = AudioPlayer();

   late int remainingSeconds ;

  final Map<String, int> timerOptions = {
    '10 min': 600,
    '20 min': 1200,
    '30 min': 1800,
    '40 min': 2400,
    '60 min': 3000,
    'No fixed duration': 0
  };

  bool hasTestStarted = false;

  void startTest() {
    setState(() {
      isTestRunning = true;
      hasTestStarted = true;
      _startTime = DateTime.now();
    });
    startTimer();
  }

  saveTest() async {
    Databases databases = Databases(client.client);
    try {
      Document result = await databases.createDocument(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.testCollectionId,
        documentId: ID.unique(),
        data: test!.toJson(),
      );
      if (result.data.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test saved'),
          ),
        );
        context.pushReplacement(AppRoutes.detailsView, extra: test);
      }
    } catch (e, s) {
      if (kDebugMode) {
        print(e);
        print(s);
      }
    }
  }

  void endTest() {
    countdownTimer?.cancel();

    setState(() {
      isTestRunning = false;
      hasTestStarted = false;
      test!.averageFHR = interpretations?.basalHeartRate;
      _endTime = DateTime.now();
    });

    int actualDuration = getActualDurationInSeconds();
    test!.lengthOfTest = actualDuration;
    test!.printDetails();

    if (route == AppConstants.instantTest) {
      context.pushReplacement(
        AppRoutes.registerMother,
        extra: {'test': test, 'route': route},
      );
    } else {
      saveTest();
    }
  }

  int getActualDurationInSeconds() {
    if (_startTime == null || _endTime == null) return 0;
    return _endTime!.difference(_startTime!).inSeconds;
  }

  void startTimer() {
    test!.live = false;
    test!.testByMother = true;

    countdownTimer?.cancel();
    remainingSeconds = 0;
    _startTime = DateTime.now();

    setState(() {
      isTestRunning = true;
      hasTestStarted = true;
    });

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        remainingSeconds++;
      });

      final selectedDuration = timerOptions[selectedValue] ?? 0;

      // Only auto-end if a fixed duration is selected (non-zero)
      if (selectedDuration > 0 && remainingSeconds >= selectedDuration) {
        endTest();
      }
    });
  }

  void runInterpretations() {
    setState(() {
      interpretations =
          Interpretations2.withData(test!.bpmEntries!, test!.gAge ?? 183);
    });
  }

  String formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  void _handleZoomChange() {
    setState(() {
      gridPreMin = gridPreMin == 1 ? 3 : 1;
    });
  }

  @override
  void initState() {
    super.initState();
    test = widget.test;
    route = widget.previousRoute;
    setState(() {
      selectedValue = prefs.getString(AppConstants.defaultTestDurationKey) ?? '20 min';
      isAlert = prefs.getBool(AppConstants.fhrAlertsKey) ?? false;
    });
  }

  bool _isAlertOnCooldown = false;

  Future<void> alert() async {
    if (!isAlert || test?.bpmEntries?.isEmpty != false || _isAlertOnCooldown) {
      return;
    }

    final int latestBpm = test!.bpmEntries!.last;

    if (latestBpm >= 160 || latestBpm <= 110) {
      _isAlertOnCooldown = true;

      await _audioPlayer.play(AssetSource('audio/marker_beep.wav'));

      // Start cooldown
      Future.delayed(const Duration(seconds: 3), () {
        _isAlertOnCooldown = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _audioPlayer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Utilities().setScreenUtil(
      context,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
    );
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.pop(2),
            icon: const Icon(Icons.keyboard_backspace_rounded),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                iconSize: 35,
                icon: Icon(gridPreMin == 1 ? Icons.zoom_in : Icons.zoom_out),
                onPressed: _handleZoomChange,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                iconSize: 35,
                icon: _isAlertOnCooldown
                ? const Icon(
                        Icons.warning,
                        color: Colors.red,
                      ) : const Icon(Icons.warning_amber_outlined),
                onPressed: _handleZoomChange,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: StreamBuilder<MyFhrData>(
          stream: BluetoothSerialService().dataStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData) {
              return const Center(child: Text("No data available"));
            }

            var data = snapshot.data!;
            if (hasTestStarted) {
              test?.bpmEntries?.add(data.fhr1);
              test?.bpmEntries2?.add(data.fhr2);
              test?.tocoEntries?.add(data.toco);
              alert();
            }
            return Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    width: 700,
                    height: 500,
                    child: GestureDetector(
                      onHorizontalDragStart: (DragStartDetails start) =>
                          _onDragStart(context, start),
                      onHorizontalDragUpdate: (DragUpdateDetails update) =>
                          _onDragUpdate(context, update),
                      child: Container(
                        color: Colors.white,
                        child: CustomPaint(
                          key: Key("length${test!.bpmEntries!.length}"),
                          painter: GraphPainter(
                            test,
                            mOffset,
                            gridPreMin,
                            interpretations,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                    width: 250.sp,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                width: 0.5,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          child: FittedBox(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                const SizedBox(
                                  height: 20,
                                ),
                                const Text(
                                  "Test duration:",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                                DropdownButton<String>(
                                  alignment: Alignment.center,
                                  value: selectedValue,
                                  items: timerOptions.keys.map((String item) {
                                    return DropdownMenuItem<String>(
                                      value: item,
                                      child: Text(
                                        item,
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 16),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    if (!isTestRunning && newValue != null) {
                                      setState(() {
                                        selectedValue = newValue;
                                        remainingSeconds =
                                            timerOptions[newValue]!;
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.arrow_drop_down,
                                      size: 20),
                                  dropdownColor: Colors.white,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                  borderRadius: BorderRadius.circular(8),
                                  underline:
                                      Container(), // Remove default underline
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Column(
                          children: [
                            Text(
                              hasTestStarted && test!.bpmEntries != []
                                  ? '${test!.bpmEntries!.last}'
                                  : '0',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 26,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/heart.PNG',
                                  scale: 30,
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                const Text(
                                  'FHR 1',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                    fontSize: 18,
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              hasTestStarted &&
                                      test!.movementEntries!.isNotEmpty
                                  ? '${test!.movementEntries!.last}'
                                  : '0',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 26,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/movement.PNG',
                                  scale: 20,
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                const Text(
                                  'Movements',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                    fontSize: 18,
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Column(
                          children: [
                            Text(
                              hasTestStarted
                                  ? '${test!.tocoEntries?.last}'
                                  : '0',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 26,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/ic_toco.PNG',
                                  scale: 30,
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                const Text(
                                  'TOCO',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                    fontSize: 18,
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          color: Colors.white,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Row(
                              //   // crossAxisAlignment: CrossAxisAlignment.center,
                              //   mainAxisAlignment: MainAxisAlignment.center,
                              //   children: <Widget>[
                              //     Column(
                              //       children: [
                              //         Row(
                              //           children: [
                              //             IconButton(
                              //               iconSize: 35,
                              //               icon: const Icon(Icons.zoom_in),
                              //               onPressed: () =>
                              //                   _handleZoomChange(increase: true),
                              //             ),
                              //             IconButton(
                              //               iconSize: 35,
                              //               icon: const Icon(Icons.zoom_out),
                              //               onPressed: () =>
                              //                   _handleZoomChange(increase: false),
                              //             ),
                              //           ],
                              //         ),
                              //         // IconButton(
                              //         //   iconSize: 35,
                              //         //   icon: Icon(this.gridPreMin == 1
                              //         //       ? Icons.zoom_in
                              //         //       : Icons.zoom_out),
                              //         //   onPressed: _handleZoomChange,
                              //         // ),
                              //         hasTestStarted
                              //             ? Container(
                              //                 height: 32,
                              //               )
                              //             : Row(
                              //                 children: [
                              //                   const SizedBox(
                              //                     height: 20,
                              //                   ),
                              //                   const Text(
                              //                     "Select test duration: ",
                              //                     style: TextStyle(
                              //                         color: Colors.black,
                              //                         fontSize: 18,
                              //                         fontWeight: FontWeight.bold),
                              //                   ),
                              //                   DropdownButton<String>(
                              //                     value: selectedValue,
                              //                     // hint: const Text("Select"),
                              //                     items: timerOptions.keys
                              //                         .map((String item) {
                              //                       return DropdownMenuItem<String>(
                              //                         value: item,
                              //                         child: Text(
                              //                           item,
                              //                           style: const TextStyle(
                              //                               color: Colors.black,
                              //                               fontSize: 16),
                              //                         ),
                              //                       );
                              //                     }).toList(),
                              //                     onChanged: (String? newValue) {
                              //                       if (!isTestRunning &&
                              //                           newValue != null) {
                              //                         setState(() {
                              //                           selectedValue = newValue;
                              //                           remainingSeconds =
                              //                               timerOptions[newValue]!;
                              //                         });
                              //                       }
                              //                     },
                              //                     icon: const Icon(
                              //                         Icons.arrow_drop_down,
                              //                         size: 20),
                              //                     // Smaller icon
                              //                     dropdownColor: Colors.white,
                              //                     // Dropdown background color
                              //                     style: const TextStyle(
                              //                         color: Colors.black,
                              //                         fontSize: 18,
                              //                         fontWeight: FontWeight.bold),
                              //                     // Text color
                              //                     borderRadius:
                              //                         BorderRadius.circular(8),
                              //                     // Rounded corners
                              //                     underline:
                              //                         Container(), // Remove default underline
                              //                   ),
                              //                 ],
                              //               ),
                              //       ],
                              //     ),
                              //   ],
                              // ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      maximumSize: const Size(250, 50),
                                      backgroundColor: isTestRunning
                                          ? Colors.red
                                          : ColorManager.primaryButtonColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed:
                                        isTestRunning ? endTest : startTest,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          isTestRunning
                                              ? Icons.stop
                                              : Icons.play_arrow,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          isTestRunning
                                              ? formatTime(remainingSeconds)
                                              : 'START',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  _onDragStart(BuildContext context, DragStartDetails start) {
    RenderBox getBox = context.findRenderObject() as RenderBox;
    mTouchStart = getBox.globalToLocal(start.globalPosition).dx;
  }

  _onDragUpdate(BuildContext context, DragUpdateDetails update) {
    RenderBox getBox = context.findRenderObject() as RenderBox;
    var local = getBox.globalToLocal(update.globalPosition);
    double newChange = (mTouchStart - local.dx);
    setState(() {
      mOffset = trap(mOffset + (newChange / (gridPreMin * 5)).truncate());
    });
  }

  int trap(int pos) {
    if (pos < 0) {
      return 0;
    } else if (pos > test!.bpmEntries!.length) {
      pos = test!.bpmEntries!.length - 10;
    }
    return pos;
  }
}
