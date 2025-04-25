import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:fetosense_device_flutter/core/utils/bluetooth_service_helper.dart';
import 'package:fetosense_device_flutter/core/utils/preferences.dart';
import 'package:fetosense_device_flutter/data/models/intrepretations2.dart';
import 'package:fetosense_device_flutter/data/models/test_model.dart';
import 'package:fetosense_device_flutter/presentation/details/details_state.dart';
import 'package:fetosense_device_flutter/presentation/widgets/fhr_pdf_view_2.dart';
import 'package:fetosense_device_flutter/presentation/widgets/interpretation_dialog.dart';
import 'package:fetosense_device_flutter/presentation/widgets/pdf_base_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdf;
import 'package:printing/printing.dart';

class DetailsCubit extends Cubit<DetailsState> {
  final PreferenceHelper prefs = GetIt.I<PreferenceHelper>();
  static const MethodChannel printChannel = MethodChannel('com.carenx.fetosense/print');
  late AnimationController animationController;
  double mTouchStart = 0;
  late pdf.Document pdfDoc;

  DetailsCubit(Test test) : super(DetailsState(test: test)) {
    _initialize(test);
  }

  void _initialize(Test test) {
    BluetoothSerialService().dispose();

    Interpretations2? interpretations;
    Interpretations2? interpretations2;

    if (test.lengthOfTest! > 180 && test.lengthOfTest! < 3600) {
      interpretations = Interpretations2.withData(test.bpmEntries, test.gAge!);
    } else {
      interpretations = Interpretations2();
    }

    if ((test.bpmEntries.length) > 180 && (test.bpmEntries.length) < 3600) {
      interpretations2 = Interpretations2.withData(test.bpmEntries, test.gAge!);
    } else {
      interpretations = Interpretations2();
    }

    int movements = test.movementEntries.length + test.autoFetalMovement.length;
    String movementsStr = movements < 10 ? "0$movements" : '$movements';

    if (test.live!) {
      int timDiff = DateTime.now().millisecondsSinceEpoch - test.createdOn.millisecondsSinceEpoch;
      timDiff = (timDiff / 1000).truncate();
    }

    emit(state.copyWith(
      test: test,
      interpretations: interpretations,
      interpretations2: interpretations2,
      radioValue: test.interpretationType,
      movements: movementsStr,
    ));
  }

  void setAnimationController(AnimationController controller) {
    animationController = controller;
  }

  void handleRadioClick(String value, BuildContext context, Test? test) {
    showInterpretationDialog(value, context, test);
  }

  void showInterpretationDialog(String value, BuildContext context, Test? test) {
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

  void updateCallback(String value, String comments, bool update) {
    if (update) {
      Map<String, String> data = {};
      data["interpretationType"] = value;
      data["interpretationExtraComments"] = comments;

      final updatedTest = state.test;
      updatedTest.interpretationType = value;
      updatedTest.interpretationExtraComments = comments;

      emit(state.copyWith(
        test: updatedTest,
        radioValue: value,
      ));
    } else {
      emit(state.copyWith(
        radioValue: null,
      ));
    }
  }

  void handleZoomChange() {
    emit(state.copyWith(
      gridPreMin: state.gridPreMin == 1 ? 3 : 1,
    ));
  }

  void onDragStart(BuildContext context, DragStartDetails start) {
    RenderBox getBox = context.findRenderObject() as RenderBox;
    mTouchStart = getBox.globalToLocal(start.globalPosition).dx;
  }

  void onDragUpdate(BuildContext context, DragUpdateDetails update) {
    RenderBox getBox = context.findRenderObject() as RenderBox;
    var local = getBox.globalToLocal(update.globalPosition);
    double newChange = (mTouchStart - local.dx);

    int newOffset = trap(state.mOffset + (newChange / (state.gridPreMin * 5)).truncate());
    emit(state.copyWith(mOffset: newOffset));
  }

  int trap(int pos) {
    if (pos < 0) {
      return 0;
    } else if (pos > state.test.bpmEntries.length) {
      pos = state.test.bpmEntries.length - 10;
    }
    return pos;
  }

  Future<void> startPrintProcess(PrintAction actionType) async {
    if (actionType == PrintAction.print) {
      emit(state.copyWith(isLoadingPrint: true, action: actionType));
    } else {
      emit(state.copyWith(isLoadingShare: true, action: actionType));
    }

    await print();
  }

  Future<void> printAndroid() async {
    var scale = prefs.getInt('scale');
    var comments = prefs.getBool('comments');
    var interpretations = prefs.getBool('interpretations');
    var highlight = prefs.getBool('highlight');

    try {
      final String? result = await printChannel.invokeMethod(
          state.action == PrintAction.print ? 'printTest' : "shareTest",
          {
            "test": state.test.toJson(),
            "scale": '$scale',
            "comments": comments,
            "interpretations": interpretations,
            "highlight": highlight
          }
      );
      debugPrint("result : '$result'.");
      emit(state.copyWith(isLoadingPrint: false, isLoadingShare: false));
    } on PlatformException catch (e) {
      debugPrint("print : '${e.message}'.");
      emit(state.copyWith(isLoadingPrint: false, isLoadingShare: false));
    }
  }

  Future<void> print() async {
    switch (state.printStatus) {
      case PrintStatus.preProcessing:
        pdfDoc = await generatePdf(PdfPageFormat.a4.landscape, state.test);

        if (state.action == PrintAction.print) {
          await Printing.layoutPdf(
              format: PdfPageFormat.a4.landscape,
              onLayout: (PdfPageFormat format) async => pdfDoc.save()
          );
          emit(state.copyWith(isLoadingPrint: false));
        } else {
          await Printing.sharePdf(bytes: await pdfDoc.save(), filename: 'Test.pdf');
          emit(state.copyWith(isLoadingShare: false));
        }
        break;
      case PrintStatus.generateFile:
        break;
      case PrintStatus.generatingPrint:
        pdfDoc.addPage(
          pdf.MultiPage(
            pageFormat: PdfPageFormat.a4,
            build: (pdf.Context context) => <pdf.Widget>[
              pdf.Text("hello"),
            ],
          ),
        );
        emit(state.copyWith(printStatus: PrintStatus.fileReady));
        break;
      case PrintStatus.fileReady:
        break;
    }
    emit(state.copyWith(printStatus: PrintStatus.preProcessing));
  }

  Future<pdf.Document> generatePdf(PdfPageFormat format, Test test) async {
    final pdf1 = pdf.Document();
    int index = 1;

    Interpretations2 interpretations = test.autoInterpretations != null
        ? Interpretations2.fromMap(test)
        : Interpretations2.withData(test.bpmEntries, test.gAge ?? 32);

    Interpretations2? interpretations2 = (test.bpmEntries2).isNotEmpty
        ? Interpretations2.withData(test.bpmEntries2, test.gAge ?? 32)
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

  @override
  Future<void> close() {
    animationController.dispose();
    return super.close();
  }
}