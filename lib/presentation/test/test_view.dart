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
import 'package:fetosense_device_flutter/data/models/mother_model.dart';
import 'package:fetosense_device_flutter/data/models/my_fhr_data.dart';
import 'package:fetosense_device_flutter/data/models/test_model.dart';
import 'package:fetosense_device_flutter/presentation/graph/graph_painter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

/// A stateful widget that manages and displays the fetal heart rate (FHR) test interface.
///
/// `TestView` handles the lifecycle of a test, including starting, running, and ending the test.
/// It streams real-time FHR, movement, and TOCO data, visualizes it using a custom graph,
/// and provides controls for test duration, zoom, and alerts. The class also manages saving
/// test data to the backend and updating related mother and organization records.
///
/// Example usage:
/// ```dart
/// Navigator.push(context, MaterialPageRoute(
///   builder: (_) => TestView(test: test, previousRoute: route, mother: mother),
/// ));
/// ```

class TestView extends StatefulWidget {
  final Test? test;
  final String? previousRoute;
  final Mother? mother;

  const TestView({super.key, this.test, this.previousRoute, this.mother});

  @override
  State<TestView> createState() => TestViewState();
}

class TestViewState extends State<TestView> {
  Test? test;
  Interpretations2? interpretations;
  Interpretations2? interpretations2;
  String? radioValue;
  String? route;
  AppwriteService client = ServiceLocator.appwriteService;
  Mother? mother;
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
  late int remainingSeconds;
  Timer? _updateTimer;
  DateTime? _lastCheckTime;
  int _lastBpmCount = 0;
  MyFhrData? _latestFhrData;


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

  Future<void> incrementMotherTestCount(String motherName) async {
    final databases = Databases(client.client);

    try {
      // Step 1: Search for the mother by name
      final result = await databases.listDocuments(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.userCollectionId,
        queries: [
          Query.equal('name', motherName),
          Query.equal('type', 'mother'),
        ],
      );

      if (result.documents.isEmpty) {
        debugPrint('Mother not found');
        return;
      }

      final doc = result.documents.first;
      final currentCount = doc.data['noOfTests'] ?? 0;

      // Step 2: Update the test count
      await databases.updateDocument(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.userCollectionId,
        documentId: doc.$id,
        data: {
          'noOfTests': currentCount + 1,
        },
      );

      debugPrint('Mother\'s test count updated.');
    } catch (e) {
      debugPrint('Error updating test count: $e');
    }
  }

  void _updateTest() async {
    Databases databases = Databases(client.client);
    test!.lengthOfTest = getActualDurationInSeconds();
    await databases.updateDocument(
      databaseId: AppConstants.appwriteDatabaseId,
      collectionId: AppConstants.testsCollectionId,
      documentId: test!.documentId!,
      data: test!.toJson(),
    );
  }

  saveTest() async {
    test!.doctorName = mother!.doctorName;
    test!.doctorId = mother!.doctorId;
    Databases databases = Databases(client.client);
    try {
      Document result = await databases.updateDocument(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.testsCollectionId,
        documentId: test!.documentId!,
        data: test!.toJson(),
      );
      if (result.data.isNotEmpty) {
        incrementMotherTestCount(test!.motherName!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test saved'),
          ),
        );
        await databases.updateDocument(
          databaseId: AppConstants.appwriteDatabaseId,
          collectionId: AppConstants.userCollectionId,
          documentId: mother!.documentId!,
          data: {
            'organizationId': test!.organizationId,
            'organizationName': test!.organizationName,
          },
        );
        context.pushReplacement(AppRoutes.detailsView, extra: {'test': test});
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
    _updateTimer?.cancel();
    setState(() {
      test!.live = false;
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

  void startTimer() async {
    remainingSeconds = 0;
    countdownTimer?.cancel();
    _startTime = DateTime.now();

    setState(() {
      isTestRunning = true;
      hasTestStarted = true;
    });

    test = await saveInitialTest();

    _lastCheckTime = null;
    _lastBpmCount = 0;

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (hasTestStarted && isTestRunning && _latestFhrData != null) {
        test?.bpmEntries.add(_latestFhrData!.fhr1);
        test?.bpmEntries2.add(_latestFhrData!.fhr2);
        test?.tocoEntries.add(_latestFhrData!.toco);

        if (_lastCheckTime == null) {
          _lastCheckTime = DateTime.now();
          _lastBpmCount = test!.bpmEntries.length;
        } else {
          final elapsed =
              DateTime.now().difference(_lastCheckTime!).inSeconds;
          if (elapsed >= 1) {
            final samplesAdded =
                test!.bpmEntries.length - _lastBpmCount;
            debugPrint("Samples per second: $samplesAdded");
            _lastCheckTime = DateTime.now();
            _lastBpmCount = test!.bpmEntries.length;
          }
        }

        if (timer.tick % 30 == 0) {
          _updateTest();
        }

        final selectedDuration = timerOptions[selectedValue] ?? 0;
        if (selectedDuration > 0 && timer.tick >= selectedDuration) {
          endTest();
          timer.cancel();
          return;
        }
      }

      setState(() {
        remainingSeconds++;
      });
    });
  }

  Future<Test> saveInitialTest() async {
    Databases databases = Databases(client.client);
    test!.live = true;
    test!.createdOn = DateTime.now();
    final result = await databases.createDocument(
      databaseId: AppConstants.appwriteDatabaseId,
      collectionId: AppConstants.testsCollectionId,
      documentId: ID.unique(),
      data: test!.toJson(),
    );

    test!.documentId = result.$id;
    addOrgDetails();
    return test!;
  }

  addOrgDetails() async {
    Databases databases = Databases(client.client);
    final result = await databases.listDocuments(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.deviceCollectionId,
        queries: [
          Query.equal('deviceName', test!.deviceName),
        ]);
    if (result.total > 0) {
      final doc = result.documents.first;
      setState(() {
        test!.organizationId = doc.data['organizationId'];
        test!.organizationName = doc.data['hospitalName'];
      });
    } else {
      debugPrint('No result found..');
    }
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
    mother = widget.mother;
    setState(() {
      selectedValue =
          prefs.getString(AppConstants.defaultTestDurationKey) ?? '20 min';
      isAlert = prefs.getBool(AppConstants.fhrAlertsKey) ?? false;
    });
  }

  bool _isAlertOnCooldown = false;

  Future<void> alert() async {
    if (!isAlert || test?.bpmEntries.isEmpty != false || _isAlertOnCooldown) {
      return;
    }

    final int latestBpm = test!.bpmEntries.last;

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
    _updateTimer?.cancel();
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
              child:
                 _isAlertOnCooldown
                    ? const Icon(
                        Icons.warning,
                        color: Colors.red,
                      )
                    : const Icon(Icons.warning_amber_outlined),
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
            _latestFhrData = data;
            if(hasTestStarted){
              alert();
            }
            return Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onHorizontalDragStart: (DragStartDetails start) =>
                          _onDragStart(context, start),
                      onHorizontalDragUpdate: (DragUpdateDetails update) =>
                          _onDragUpdate(context, update),
                      child: Container(
                        color: Colors.white,
                        child: CustomPaint(
                          key: Key("length${test!.bpmEntries.length}"),
                          painter: GraphPainter(
                            test,
                            mOffset,
                            gridPreMin,
                            interpretations,
                            false
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    width: 250.w,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
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
                                 Text(
                                  "Test duration:",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 26.sp,
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
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 26.sp),
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
                          height: 25,
                        ),
                        Column(
                          children: [
                            Text(
                              hasTestStarted && test!.bpmEntries.isNotEmpty
                                  ? '${test!.bpmEntries.last}'
                                  : '${_latestFhrData?.fhr1 ?? 0}',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 46.sp,
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
                          height: 25,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              hasTestStarted &&
                                      test!.movementEntries.isNotEmpty
                                  ? '${test!.movementEntries.last}'
                                  : '0',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 46.sp,
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
                          height: 25,
                        ),
                        Column(
                          children: [
                            Text(
                              hasTestStarted && test!.tocoEntries.isNotEmpty
                                  ? '${test!.tocoEntries.last}'
                                  : '0',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 46.sp,
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      maximumSize: Size(200.w, 80.h),
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
    } else if (pos > test!.bpmEntries.length) {
      pos = test!.bpmEntries.length - 10;
    }
    return pos;
  }
}
