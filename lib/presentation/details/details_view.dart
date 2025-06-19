import 'package:auto_size_text/auto_size_text.dart';
import 'package:fetosense_device_flutter/core/constants/app_routes.dart';
import 'package:fetosense_device_flutter/core/utils/utilities.dart';
import 'package:fetosense_device_flutter/data/models/test_model.dart';
import 'package:fetosense_device_flutter/presentation/details/details_cubit.dart';
import 'package:fetosense_device_flutter/presentation/details/details_state.dart';
import 'package:fetosense_device_flutter/presentation/graph/graph_painter.dart';
import 'package:fetosense_device_flutter/presentation/widgets/custom_radio_btn.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// A stateful widget that displays detailed information and analysis for a specific test.
///
/// The `DetailsView` widget presents a comprehensive view of a test, including
/// patient details, test statistics, interactive graph visualization, and controls
/// for interpretation, printing, and sharing. It uses Bloc for state management
/// and supports user interactions such as zooming, dragging, and selecting interpretations.
///
/// Example usage:
/// ```dart
/// Navigator.push(context, MaterialPageRoute(
///   builder: (_) => DetailsView(test: test),
/// ));
/// ```

class DetailsView extends StatefulWidget {
  final Test test;
 final String? fromRoute;

  const DetailsView({super.key, required this.test, this.fromRoute});

  @override
  DetailsViewState createState() => DetailsViewState();
}

class DetailsViewState extends State<DetailsView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late DetailsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animationController.repeat(reverse: true);

    _cubit = DetailsCubit(widget.test);
    _cubit.setAnimationController(_animationController);
  }

  @override
  Widget build(BuildContext context) {
    Utilities().setScreenUtil(context,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height);

    return BlocProvider(
      create: (context) => _cubit,
      child: BlocBuilder<DetailsCubit, DetailsState>(
        builder: (context, state) {
          return PopScope(
            onPopInvokedWithResult: (pop, result) {
              if(widget.fromRoute?.isNotEmpty == true && widget.fromRoute == "motherDetails") {
                context.pop();
              } else {
                context.go(AppRoutes.home);
              }
            },
            child: Scaffold(
              body: SafeArea(
                child: Column(
                  children: <Widget>[
                    _buildHeader(context, state),
                    // _buildRadioButtons(context, state),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildGraphArea(context, state),
                          if (kIsWeb) _buildSidePanel(context, state),
                        ],
                      ),
                    ),
                    _buildBottomStats(context, state),
                    _buildActionBar(context, state),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DetailsState state) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey)),
      ),
      child: ListTile(
        leading: IconButton(
          iconSize: 35,
          icon: const Icon(Icons.arrow_back, size: 30, color: Colors.teal),
          onPressed: () => context.go(AppRoutes.home),
        ),
        subtitle: Stack(
          alignment: Alignment.center,
          children: [
            Row(
            children: [
              Text(
                DateFormat('dd MMM yy - hh:mm a').format(state.test.createdOn),
                style: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 18, color: Colors.black87),
              ),

            ],
          ),
            Align(
              alignment: Alignment.center,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: state.radioValue == 'normal'
                      ? Colors.green.withOpacity(0.4)
                      : Colors.red.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(8.w),
                ),

                child: Text(
                  "${state.radioValue}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
                ),
              ),
            ),
          ]
        ),
        title: Text(
          "${state.test.motherName}",
          style: const TextStyle(
              fontWeight: FontWeight.w300, fontSize: 14, color: Colors.black87),
        ),
        trailing: CircleAvatar(
          radius: 44.w,
          backgroundColor: Colors.teal,
          child: Center(
            child: Text.rich(
              TextSpan(
                text: '${(state.test.lengthOfTest! / 60).truncate()}',
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
    );
  }

  Widget _buildRadioButtons(BuildContext context, DetailsState state) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: CustomRadioBtn(
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
          enableAll: state.test.interpretationType == null ||
              state.test.interpretationType!.trim().isEmpty,
          defaultValue: state.radioValue,
          radioButtonValue: (value) => context
              .read<DetailsCubit>()
              .handleRadioClick(value, context, widget.test),
          selectedColor: Colors.blue,
        ));
  }

  Widget _buildGraphArea(BuildContext context, DetailsState state) {
    return Expanded(
      child: GestureDetector(
        onHorizontalDragStart: (DragStartDetails start) =>
            context.read<DetailsCubit>().onDragStart(context, start),
        onHorizontalDragUpdate: (DragUpdateDetails update) =>
            context.read<DetailsCubit>().onDragUpdate(context, update),
        child: Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width,
          child: CustomPaint(
            painter: GraphPainter(state.test, state.mOffset, state.gridPreMin,
                state.interpretations, true),
          ),
        ),
      ),
    );
  }

  Widget _buildSidePanel(BuildContext context, DetailsState state) {
    return Container(
      width: 0.25.sw,
      height: 0.8.sh,
      padding: EdgeInsets.only(top: 8.h),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(width: 2, color: Colors.black)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          _buildFHR1Panel(context, state),
          _buildFHR2Panel(context, state),
          _buildMovementsPanel(context, state),
        ],
      ),
    );
  }

  Widget _buildFHR1Panel(BuildContext context, DetailsState state) {
    return Container(
      height: 0.30.sh,
      width: 0.24.sw,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(width: 0.5, color: Colors.teal)),
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
                  const TextSpan(text: "BASAL HR", children: [
                    TextSpan(text: "\nACCELERATION"),
                    TextSpan(text: "\nDECELERATION"),
                    TextSpan(text: "\nSHORT TERM VARI "),
                    TextSpan(text: "\nLONG TERM VARI "),
                  ]),
                  textAlign: TextAlign.left,
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
                ),
                AutoSizeText.rich(
                  TextSpan(
                      text:
                          ": ${(state.interpretations?.basalHeartRate ?? "--")}",
                      children: [
                        TextSpan(
                          text:
                              "\n: ${(state.interpretations?.getnAccelerationsStr() ?? "--")}",
                        ),
                        TextSpan(
                          text:
                              "\n: ${(state.interpretations?.getnDecelerationsStr() ?? "--")}",
                        ),
                        TextSpan(
                          text:
                              "\n: ${(state.interpretations?.getShortTermVariationBpmStr() ?? "--")}/${(state.interpretations?.getShortTermVariationMilliStr() ?? "--")}",
                        ),
                        TextSpan(
                          text:
                              "\n: ${(state.interpretations?.getLongTermVariationStr() ?? "--")}",
                        ),
                      ]),
                  textAlign: TextAlign.left,
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          Container(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            padding: EdgeInsets.symmetric(vertical: 4.h),
            alignment: Alignment.center,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "FHR 1",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
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
    );
  }

  Widget _buildFHR2Panel(BuildContext context, DetailsState state) {
    return Container(
      height: 0.30.sh,
      width: 0.24.sw,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey)),
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
                  const TextSpan(text: "BASAL HR", children: [
                    TextSpan(text: "\nACCELERATION"),
                    TextSpan(text: "\nDECELERATION"),
                    TextSpan(text: "\nSHORT TERM VARI "),
                    TextSpan(text: "\nLONG TERM VARI "),
                  ]),
                  textAlign: TextAlign.left,
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
                ),
                AutoSizeText.rich(
                  TextSpan(
                    text:
                        ": ${(state.interpretations2?.basalHeartRate ?? "--")}",
                    children: [
                      TextSpan(
                        text:
                            "\n: ${(state.interpretations2?.getnAccelerationsStr() ?? "--")}",
                      ),
                      TextSpan(
                        text:
                            "\n: ${(state.interpretations2?.getnDecelerationsStr() ?? "--")}",
                      ),
                      TextSpan(
                        text:
                            "\n: ${(state.interpretations2?.getShortTermVariationBpmStr() ?? "--")}/${(state.interpretations2?.getShortTermVariationMilliStr() ?? "--")}",
                      ),
                      TextSpan(
                        text:
                            "\n: ${(state.interpretations2?.getLongTermVariationStr() ?? "--")}",
                      ),
                    ],
                  ),
                  textAlign: TextAlign.left,
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          Container(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            padding: EdgeInsets.symmetric(vertical: 4.h),
            alignment: Alignment.center,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "FHR 2",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
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
    );
  }

  Widget _buildMovementsPanel(BuildContext context, DetailsState state) {
    return Container(
      height: 0.15.sh,
      width: 0.24.sw,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey)),
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
                    const TextSpan(text: "DURATION"),
                    TextSpan(
                        text: "\nMOVEMENTS",
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.w500)),
                    TextSpan(
                        text: "\nSHORT TERM VARI ",
                        style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.white.withOpacity(0),
                            fontWeight: FontWeight.w500)),
                  ]),
                  textAlign: TextAlign.left,
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
                ),
                AutoSizeText.rich(
                  TextSpan(text: "", children: [
                    TextSpan(
                      text: ": ${(state.test.bpmEntries.length ~/ 60)} m",
                    ),
                    TextSpan(
                      text:
                          "\n: ${(state.test.movementEntries.length)}/${(state.test.autoFetalMovement.length)}",
                    ),
                    const TextSpan(text: "\n "),
                  ]),
                  textAlign: TextAlign.left,
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomStats(BuildContext context, DetailsState state) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _buildStatItem(
                    state.interpretations!.getBasalHeartRateStr(), "BASAL HR"),
                _buildStatItem(state.interpretations!.getnAccelerationsStr(),
                    "ACCELERATION"),
                _buildStatItem(state.interpretations!.getnDecelerationsStr(),
                    "DECELERATION"),
                _buildStatItem(state.movements ?? '', "MOVEMENTS"),
                _buildStatItem(
                    state.interpretations!.getShortTermVariationBpmStr(),
                    "SHORT TERM VARI"),
                _buildStatItem(state.interpretations!.getLongTermVariationStr(),
                    "LONG TERM VARI"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey)),
      ),
      child: SizedBox(
        height: 54.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 22.sp,
                  color: Colors.black87,
                  height: 1,
                  fontWeight: FontWeight.w500),
            ),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w300,
                color: Colors.black87,
                fontSize: 8.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBar(BuildContext context, DetailsState state) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
            iconSize: 35,
            icon: Icon(state.gridPreMin == 1 ? Icons.zoom_in : Icons.zoom_out),
            onPressed: () => context.read<DetailsCubit>().handleZoomChange(),
          ),
          !state.isLoadingShare
              ? IconButton(
                  iconSize: 35,
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    if (!state.isLoadingPrint) {
                      context
                          .read<DetailsCubit>()
                          .startPrintProcess(PrintAction.share);
                    }
                  },
                )
              : IconButton(
                  iconSize: 35,
                  icon: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                  onPressed: () {},
                ),
          !state.isLoadingPrint
              ? IconButton(
                  iconSize: 35,
                  icon: const Icon(Icons.print),
                  onPressed: () {
                    if (!state.isLoadingShare) {
                      context
                          .read<DetailsCubit>()
                          .startPrintProcess(PrintAction.print);
                    }
                  },
                )
              : IconButton(
                  iconSize: 35,
                  icon: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                  onPressed: () {},
                ),
          IconButton(
            iconSize: 35,
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Implementation for settings can be added here
            },
          ),
        ],
      ),
    );
  }
}
