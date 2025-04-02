import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:fetosense_device_flutter/core/app_routes.dart';
import 'package:fetosense_device_flutter/core/bluetooth_service_helper.dart';
import 'package:fetosense_device_flutter/core/color_manager.dart';
import 'package:fetosense_device_flutter/core/constants/app_constants.dart';
import 'package:fetosense_device_flutter/core/dependency_injection.dart';
import 'package:fetosense_device_flutter/core/network/appwrite_config.dart';
import 'package:fetosense_device_flutter/data/models/fetosense_model.dart';
import 'package:fetosense_device_flutter/data/models/intrepretations2.dart';
import 'package:fetosense_device_flutter/data/models/my_fhr_data.dart';
import 'package:fetosense_device_flutter/data/models/test_model.dart';
import 'package:fetosense_device_flutter/presentation/graph/graph_painter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
  FetosenseTest? fetosenseTest;
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
  String selectedValue = '20 min';
  int remainingSeconds = 1200;
  Timer? countdownTimer;
  bool isTestRunning = false;
  DateTime? _startTime;
  DateTime? _endTime;

  final Map<String, int> timerOptions = {
    '10 min': 600,
    '20 min': 1200,
    '30 min': 1800,
    '40 min': 2400,
    '60 min': 3000,
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
        databaseId: '67ece4a7002a0a732dfd',
        collectionId: '67ece4b2000ee3f96faa',
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
      remainingSeconds = timerOptions[selectedValue]!;
      _endTime = DateTime.now();
    });
    int actualDuration = getActualDurationInSeconds();
    test!.lengthOfTest = actualDuration;
    test!.printDetails();
    if (route == AppConstants.instantTest) {
      context.pushReplacement(AppRoutes.registerMother,
          extra: {'test': test, 'route': route});
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
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        setState(() => remainingSeconds--);
      } else {
        timer.cancel();
        setState(() {
          isTestRunning = false;
          hasTestStarted = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Test complete"),
          ),
        );
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

  @override
  void initState() {
    super.initState();
    test = widget.test;
    route = widget.previousRoute;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.keyboard_backspace_rounded),
          ),
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
            }
            return Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    width: 650,
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
                    width: 300,
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              const Text(
                                "Select test duration: ",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              DropdownButton<String>(
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
                                icon:
                                    const Icon(Icons.arrow_drop_down, size: 20),
                                dropdownColor: Colors.white,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                                borderRadius: BorderRadius.circular(8),
                                underline:
                                    Container(), // Remove default underline
                              ),
                              const Icon(
                                Icons.edit,
                                color: ColorManager.primaryButtonColor,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
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
                            Column(
                              children: [
                                Text(
                                  hasTestStarted && test!.bpmEntries2 != []
                                      ? '${test!.bpmEntries2!.last}'
                                      : '0',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 26,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Image.asset(
                                      'assets/heart.PNG',
                                      scale: 30,
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    const Text(
                                      'FHR 2',
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
                          ],
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
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
                                      maximumSize: const Size(300, 50),
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

  // void updateCallback(String value, String comments, bool update) {
  //   if (update) {
  //     Map data = new Map<String, String>();
  //     data["interpretationType"] = value;
  //     data["interpretationExtraComments"] = comments;
  //     databaseReference
  //         .collection("tests")
  //         .doc(widget.test?.deviceId)
  //         .update(data as Map<Object, Object?>);
  //     setState(() {
  //       test!.interpretationType = value;
  //       test!.interpretationExtraComments = comments;
  //       radioValue = value;
  //     });
  //   } else {
  //     setState(() {
  //       radioValue = null;
  //     });
  //   }
  // }

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
