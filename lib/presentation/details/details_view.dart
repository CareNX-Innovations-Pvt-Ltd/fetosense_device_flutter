import 'dart:async';

import 'package:fetosense_device_flutter/core/constants/app_routes.dart';
import 'package:fetosense_device_flutter/core/utils/bluetooth_service_helper.dart';
import 'package:fetosense_device_flutter/core/utils/utilities.dart';
import 'package:fetosense_device_flutter/core/utils/preferences.dart';
import 'package:fetosense_device_flutter/data/models/intrepretations2.dart';
import 'package:fetosense_device_flutter/data/models/test_model.dart';
import 'package:fetosense_device_flutter/presentation/graph/graph_painter.dart';
import 'package:fetosense_device_flutter/presentation/widgets/custom_radio_btn.dart';
import 'package:fetosense_device_flutter/presentation/widgets/fhr_pdf_view_2.dart';
import 'package:fetosense_device_flutter/presentation/widgets/interpretation_dialog.dart';
import 'package:fetosense_device_flutter/presentation/widgets/pdf_base_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdf;
import 'package:permission_handler/permission_handler.dart';

import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_size_text/auto_size_text.dart';

enum PrintStatus {
  PRE_PROCESSING,
  GENERATING_FILE,
  GENERATING_PRINT,
  FILE_READY,
}

enum Action { PRINT, SHARE }

const directoryName = 'fetosense';

class DetailsView extends StatefulWidget {
  Test test;

  DetailsView({super.key, required this.test});

  @override
  DetailsViewState createState() => DetailsViewState();
}

class DetailsViewState extends State<DetailsView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Test? test;
  Interpretations2? interpretations;
  Interpretations2? interpretations2;

  PrintStatus printStatus = PrintStatus.PRE_PROCESSING;
  int gridPreMin = 3;
  double mTouchStart = 0;
  int mOffset = 0;
  bool isLoadingShare = false;
  bool isLoadingPrint = false;

  late pdf.Document pdfDoc;
  Action? action;

  String? radioValue;

  late Map<Permission, PermissionStatus> permissions;

  List<pdf.Image>? images;

  List<String>? paths;

  String? movements;
  final prefs = GetIt.I<PreferenceHelper>();

  static const printChannel = MethodChannel('com.carenx.fetosense/print');

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animationController.repeat(reverse: true);
    super.initState();
    test = widget.test;
    if (test!.lengthOfTest! > 180 && test!.lengthOfTest! < 3600) {
      interpretations =
          Interpretations2.withData(test!.bpmEntries!, test!.gAge!);
    } else {
      interpretations = Interpretations2();
    }
    if ((test!.bpmEntries?.length ?? 0) > 180 &&
        (test!.bpmEntries?.length ?? 0) < 3600) {
      interpretations2 =
          Interpretations2.withData(test!.bpmEntries!, test!.gAge!);
    } else {
      interpretations = Interpretations2();
    }
    radioValue = test!.interpretationType;
    int movements =
        test!.movementEntries!.length + test!.autoFetalMovement!.length;
    this.movements = movements < 10 ? "0$movements" : '$movements';

    if (test!.live!) {
      int timDiff = DateTime.now().millisecondsSinceEpoch -
          test!.createdOn!.millisecondsSinceEpoch;
      timDiff = (timDiff / 1000).truncate();
    }
    BluetoothSerialService().dispose();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Utilities().setScreenUtil(context,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              decoration: const BoxDecoration(
                border:
                    Border(bottom: BorderSide(width: 0.5, color: Colors.grey)),
              ),
              child: ListTile(
                leading: IconButton(
                  iconSize: 35,
                  icon: const Icon(Icons.arrow_back,
                      size: 30, color: Colors.teal),
                  onPressed: () => context.pushReplacement(AppRoutes.home),
                ),
                subtitle: Text(
                  DateFormat('dd MMM yy - hh:mm a').format(test!.createdOn!),
                  style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      color: Colors.black87),
                ),
                title: Text(
                  "${test!.motherName}",
                  style: const TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 14,
                      color: Colors.black87),
                ),
                trailing: CircleAvatar(
                  radius: 44.w,
                  backgroundColor: Colors.teal,
                  child: Center(
                    child: Text.rich(
                      TextSpan(
                        text: '${(test!.lengthOfTest! / 60).truncate()}',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontSize: 32.sp,
                            height: 1),
                        children: [
                          TextSpan(
                            text: "\nmin",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                              fontSize: 18.sp,
                            ),
                          )
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: !test!.live!
                  ? CustomRadioBtn(
                      buttonColor: Theme.of(context).canvasColor,
                      buttonLables: const [
                        "Normal",
                        "Abnormal",
                        "Atypical",
                      ],
                      buttonValues: const [
                        "Normal",
                        "Abnormal",
                        "Atypical",
                      ],
                      enableAll: test!.interpretationType == null ||
                          test!.interpretationType!.trim().isEmpty,
                      defaultValue: radioValue,
                      radioButtonValue: (value) => _handleRadioClick(value),
                      selectedColor: Colors.blue,
                    )
                  : Container(
                      color: Colors.tealAccent,
                      padding: const EdgeInsets.all(10),
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          FadeTransition(
                            opacity: _animationController,
                            child: const Icon(
                              Icons.circle,
                              size: 18,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(
                            width: 7,
                          ),
                          const Text(
                            "Live test. Updates every 30 seconds.",
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 18,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
            ),
            Expanded(
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
                        width: MediaQuery.of(context).size.width,
                        child: CustomPaint(
                          painter: GraphPainter(
                              test!, mOffset, gridPreMin, interpretations),
                        ),
                      ),
                    ),
                  ),
                  if (kIsWeb)
                    Container(
                      width: 0.25.sw,
                      height: 0.8.sh,
                      padding: EdgeInsets.only(top: 8.h),
                      decoration: const BoxDecoration(
                        border: Border(
                            left: BorderSide(width: 2, color: Colors.black)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Container(
                            height: 0.30.sh,
                            width: 0.24.sw,
                            decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      width: 0.5, color: Colors.teal)),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.all(8.w),
                                  alignment: Alignment.center,
                                  child: Row(
                                    children: [
                                      AutoSizeText.rich(
                                        const TextSpan(
                                            text: "BASAL HR",
                                            children: [
                                              TextSpan(
                                                text: "\nACCELERATION",
                                              ),
                                              TextSpan(
                                                text: "\nDECELERATION",
                                              ),
                                              TextSpan(
                                                text: "\nSHORT TERM VARI  ",
                                              ),
                                              TextSpan(
                                                text: "\nLONG TERM VARI ",
                                              ),
                                            ]),
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            //color: Colors.white.withOpacity(0.6),
                                            fontWeight: FontWeight.w500),
                                      ),
                                      AutoSizeText.rich(
                                        TextSpan(
                                            text:
                                                ": ${(interpretations?.basalHeartRate ?? "--")}",
                                            children: [
                                              TextSpan(
                                                text:
                                                    "\n: ${(interpretations?.getnAccelerationsStr() ?? "--")}",
                                              ),
                                              TextSpan(
                                                text:
                                                    "\n: ${(interpretations?.getnDecelerationsStr() ?? "--")}",
                                              ),
                                              TextSpan(
                                                text:
                                                    "\n: ${(interpretations?.getShortTermVariationBpmStr() ?? "--")}/${(interpretations?.getShortTermVariationMilliStr() ?? "--")}",
                                              ),
                                              TextSpan(
                                                text:
                                                    "\n: ${(interpretations?.getLongTermVariationStr() ?? "--")}",
                                              ),
                                            ]),
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            //color: Colors.white,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .tertiaryContainer,
                                  padding: EdgeInsets.symmetric(vertical: 4.h),
                                  alignment: Alignment.center,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "FHR 1",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            //color: Colors.white54,
                                            fontSize: 22.sp,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 0.30.sh,
                            width: 0.24.sw,
                            decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      width: 0.5, color: Colors.grey)),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.all(8.w),
                                  alignment: Alignment.center,
                                  child: Row(
                                    children: [
                                      AutoSizeText.rich(
                                        const TextSpan(
                                            text: "BASAL HR",
                                            children: [
                                              TextSpan(
                                                text: "\nACCELERATION",
                                              ),
                                              TextSpan(
                                                text: "\nDECELERATION",
                                              ),
                                              TextSpan(
                                                text: "\nSHORT TERM VARI  ",
                                              ),
                                              TextSpan(
                                                text: "\nLONG TERM VARI ",
                                              ),
                                            ]),
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            //color: Colors.white.withOpacity(0.6),
                                            fontWeight: FontWeight.w500),
                                      ),
                                      AutoSizeText.rich(
                                        TextSpan(
                                          text:
                                              ": ${(interpretations2?.basalHeartRate ?? "--")}",
                                          children: [
                                            TextSpan(
                                              text:
                                                  "\n: ${(interpretations2?.getnAccelerationsStr() ?? "--")}",
                                            ),
                                            TextSpan(
                                              text:
                                                  "\n: ${(interpretations2?.getnDecelerationsStr() ?? "--")}",
                                            ),
                                            TextSpan(
                                              text:
                                                  "\n: ${(interpretations2?.getShortTermVariationBpmStr() ?? "--")}/${(interpretations2?.getShortTermVariationMilliStr() ?? "--")}",
                                            ),
                                            TextSpan(
                                              text:
                                                  "\n: ${(interpretations2?.getLongTermVariationStr() ?? "--")}",
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            //color: Colors.white,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .tertiaryContainer,
                                  padding: EdgeInsets.symmetric(vertical: 4.h),
                                  alignment: Alignment.center,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "FHR 2",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            //color: Colors.tealAccent,
                                            fontSize: 22.sp,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 0.15.sh,
                            width: 0.24.sw,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 0.5,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.all(8.w),
                                  alignment: Alignment.center,
                                  child: Row(
                                    children: [
                                      AutoSizeText.rich(
                                        TextSpan(text: "", children: [
                                          const TextSpan(
                                            text: "DURATION",
                                          ),
                                          TextSpan(
                                              text: "\nMOVEMENTS",
                                              style: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w500)),
                                          TextSpan(
                                              text: "\nSHORT TERM VARI  ",
                                              style: TextStyle(
                                                  fontSize: 16.sp,
                                                  color: Colors.white
                                                      .withOpacity(0),
                                                  fontWeight: FontWeight.w500)),
                                        ]),
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            //color: Colors.white.withOpacity(0.6),
                                            fontWeight: FontWeight.w500),
                                      ),
                                      AutoSizeText.rich(
                                        TextSpan(text: "", children: [
                                          TextSpan(
                                            text:
                                                ": ${(widget.test.bpmEntries!.length ~/ 60)} m",
                                          ),
                                          TextSpan(
                                            text:
                                                "\n: ${(widget.test.movementEntries?.length)}/${(widget.test.autoFetalMovement?.length)}",
                                          ),
                                          const TextSpan(
                                            text: "\n ",
                                          ),
                                        ]),
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            //color: Colors.white,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: const BoxDecoration(
                            border: Border(
                                bottom:
                                    BorderSide(width: 0.5, color: Colors.grey)),
                          ),
                          child: SizedBox(
                            height: 54.h,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  interpretations!.getBasalHeartRateStr(),
                                  style: TextStyle(
                                      fontSize: 22.sp,
                                      color: Colors.black87,
                                      height: 1,
                                      fontWeight: FontWeight.w500),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  "BASAL HR",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    color: Colors.black87,
                                    fontSize: 8.sp,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                width: 0.5,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          child: SizedBox(
                            height: 54.h,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  interpretations!.getnAccelerationsStr(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 22.sp,
                                      color: Colors.black87,
                                      height: 1,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  "ACCELERATION",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    color: Colors.black87,
                                    fontSize: 8.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                width: 0.5,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          child: SizedBox(
                            height: 54.h,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  interpretations!.getnDecelerationsStr(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 22.sp,
                                      color: Colors.black87,
                                      height: 1,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  "DECELERATION",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    color: Colors.black87,
                                    fontSize: 8.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      width: 0.5, color: Colors.grey)),
                            ),
                            child: SizedBox(
                              height: 54.h,
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Text(
                                      '$movements',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 22.sp,
                                          color: Colors.black87,
                                          height: 1,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      "MOVEMENTS",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        color: Colors.black87,
                                        fontSize: 8.sp,
                                      ),
                                    ),
                                  ]),
                            )),
                        Container(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      width: 0.5, color: Colors.grey)),
                            ),
                            child: SizedBox(
                              height: 54.h,
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Text(
                                      interpretations!
                                          .getShortTermVariationBpmStr(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 22.sp,
                                          color: Colors.black87,
                                          height: 1,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      "SHORT TERM VARI",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        color: Colors.black87,
                                        fontSize: 8.sp,
                                      ),
                                    ),
                                  ]),
                            )),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: const BoxDecoration(
                            border: Border(
                                bottom:
                                    BorderSide(width: 0.5, color: Colors.grey)),
                          ),
                          child: SizedBox(
                            height: 54.h,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  interpretations!.getLongTermVariationStr(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 22.sp,
                                      color: Colors.black87,
                                      height: 1,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  "LONG TERM VARI",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    color: Colors.black87,
                                    fontSize: 8.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    IconButton(
                      iconSize: 35,
                      icon: Icon(
                          gridPreMin == 1 ? Icons.zoom_in : Icons.zoom_out),
                      onPressed: _handleZoomChange,
                    ),
                    !isLoadingShare
                        ? IconButton(
                            iconSize: 35,
                            icon: const Icon(Icons.share),
                            onPressed: () {
                              if (!isLoadingPrint) {
                                setState(() {
                                  isLoadingShare = true;
                                  action = Action.SHARE;
                                });
                                _print();
                              }
                            },
                          )
                        : IconButton(
                            iconSize: 35,
                            icon: const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.black),
                            ),
                            onPressed: () {},
                          ),
                    !isLoadingPrint
                        ? IconButton(
                            iconSize: 35,
                            icon: const Icon(Icons.print),
                            onPressed: () {
                              if (!isLoadingShare) {
                                setState(() {
                                  isLoadingPrint = true;
                                  action = Action.PRINT;
                                });
                                _print();
                              }
                            },
                          )
                        : IconButton(
                            iconSize: 35,
                            icon: const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.black),
                            ),
                            onPressed: () {},
                          ),
                    IconButton(
                      iconSize: 35,
                      icon: const Icon(Icons.settings),
                      onPressed: () {
                        // Navigator.push(context,
                        //     MaterialPageRoute(builder: (_) => SettingsView()));
                      },
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  void showInterpretationDialog(String value) {
    showDialog(
      context: context,
      builder: (context) {
        return InterpretationDialog(
            test: test,
            value: test!.interpretationType ?? value,
            callback: updateCallback);
      },
      barrierDismissible: false,
    );
  }

  void _handleRadioClick(String value) {
    showInterpretationDialog(value);
  }

  void updateCallback(String value, String comments, bool update) {
    if (update) {
      Map data = <String, String>{};
      data["interpretationType"] = value;
      data["interpretationExtraComments"] = comments;

      setState(() {
        test!.interpretationType = value;
        test!.interpretationExtraComments = comments;
        radioValue = value;
      });
    } else {
      setState(() {
        radioValue = null;
      });
    }
  }

  void _handleZoomChange() {
    setState(() {
      gridPreMin = gridPreMin == 1 ? 3 : 1;
    });
  }

  _onDragStart(BuildContext context, DragStartDetails start) {
    RenderBox getBox = context.findRenderObject() as RenderBox;
    mTouchStart = getBox.globalToLocal(start.globalPosition).dx;
    //print(mTouchStart.dx.toString() + "|" + mTouchStart.dy.toString());
  }

  _onDragUpdate(BuildContext context, DragUpdateDetails update) {
    //print(update.globalPosition.toString());
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

  Future<void> printAndroid() async {
    var scale = prefs.getInt('scale');
    var comments = prefs.getBool('comments');
    var interpretations = prefs.getBool('interpretations');
    var highlight = prefs.getBool('highlight');
    try {
      final String? result = await printChannel
          .invokeMethod(action == Action.PRINT ? 'printTest' : "shareTest", {
        "test": test!.toJson(),
        "scale": '$scale',
        "comments": comments,
        "interpretations": interpretations,
        "highlight": highlight
      });
      print("result : '$result'.");
      setState(() {
        isLoadingPrint = false;
        isLoadingShare = false;
      });
    } on PlatformException catch (e) {
      print("print : '${e.message}'.");
    }
  }

  Future<void> _print() async {
    switch (printStatus) {
      case PrintStatus.PRE_PROCESSING:
        pdfDoc = await _generatePdf(PdfPageFormat.a4.landscape, widget.test);

        if (action == Action.PRINT) {
          await Printing.layoutPdf(
              format: PdfPageFormat.a4.landscape,
              onLayout: (PdfPageFormat format) async => pdfDoc.save());
          setState(() {
            isLoadingPrint = false;
          });
        } else {
          await Printing.sharePdf(
              bytes: await pdfDoc.save(), filename: 'Test.pdf');
          setState(() {
            isLoadingShare = false;
          });

          //Navigator.of(context).pop();
        }

        break;
      case PrintStatus.GENERATING_FILE:
        break;
      case PrintStatus.GENERATING_PRINT:
        pdfDoc.addPage(pdf.MultiPage(
            pageFormat: PdfPageFormat.a4,
            build: (pdf.Context context) => <pdf.Widget>[pdf.Text("hello")]));
        setState(() {
          printStatus = PrintStatus.FILE_READY;
        });
        break;
      case PrintStatus.FILE_READY:
        // TODO: Handle this case.
        break;
    }
    setState(() {
      printStatus = PrintStatus.PRE_PROCESSING;
    });
  }

  Future<pdf.Document> _generatePdf(PdfPageFormat format, Test test) async {
    final pdf1 = pdf.Document();
    int index = 1;
    Interpretations2 interpretations = test.autoInterpretations != null
        ? Interpretations2.fromMap(test)
        : Interpretations2.withData(test.bpmEntries!, test.gAge ?? 32);
    Interpretations2? interpretations2 = (test.bpmEntries2 ?? []).isNotEmpty
        ? Interpretations2.withData(test.bpmEntries2!, test.gAge ?? 32)
        : null;
    FhrPdfView2 fhrPdfView = FhrPdfView2(test.lengthOfTest!);
    final paths = await fhrPdfView.getNSTGraph(test, interpretations);
    for (int i = 0; i < paths!.length; i++) {
      final mImage = paths[i];
      pdf1.addPage(
        pdf.Page(
          pageFormat: format,
          margin: pdf.EdgeInsets.zero,
          build: (context) {
            return PfdBasePage(
              data: test,
              interpretation: interpretations,
              interpretation2: interpretations2,
              index: index + i,
              total: paths.length,
              body: pdf.Image(pdf.MemoryImage(mImage.bytes)),
            );
          },
        ),
      );
    }
    return pdf1;
  }
}
