import 'package:equatable/equatable.dart';
import 'package:fetosense_device_flutter/data/models/intrepretations2.dart';
import 'package:fetosense_device_flutter/data/models/test_model.dart';

/// The status of the print process.
enum PrintStatus {
  preProcessing,
  generateFile,
  generatingPrint,
  fileReady,
}

/// The action to be performed when printing or sharing the test details.
enum PrintAction { print, share }


/// Represents the state for the test details view managed by [DetailsCubit].
///
/// `DetailsState` holds all relevant data for rendering and interacting with
/// the test details screen, including the test model, interpretations, print/share
/// status, UI controls (such as grid zoom and offset), and user selections.
/// It supports value comparison via [Equatable] for efficient state updates.
///
/// Use [copyWith] to create updated copies of the state with modified fields.
///
/// Example usage:
/// ```dart
/// final newState = state.copyWith(isLoadingPrint: true);
/// ```
class DetailsState extends Equatable {
  final Test test;
  final Interpretations2? interpretations;
  final Interpretations2? interpretations2;
  final PrintStatus printStatus;
  final int gridPreMin;
  final int mOffset;
  final bool isLoadingShare;
  final bool isLoadingPrint;
  final PrintAction? action;
  final String? radioValue;
  final String? movements;

  const DetailsState({
    required this.test,
    this.interpretations,
    this.interpretations2,
    this.printStatus = PrintStatus.preProcessing,
    this.gridPreMin = 3,
    this.mOffset = 0,
    this.isLoadingShare = false,
    this.isLoadingPrint = false,
    this.action,
    this.radioValue,
    this.movements,
  });

  DetailsState copyWith({
    Test? test,
    Interpretations2? interpretations,
    Interpretations2? interpretations2,
    PrintStatus? printStatus,
    int? gridPreMin,
    int? mOffset,
    bool? isLoadingShare,
    bool? isLoadingPrint,
    PrintAction? action,
    String? radioValue,
    String? movements,
  }) {
    return DetailsState(
      test: test ?? this.test,
      interpretations: interpretations ?? this.interpretations,
      interpretations2: interpretations2 ?? this.interpretations2,
      printStatus: printStatus ?? this.printStatus,
      gridPreMin: gridPreMin ?? this.gridPreMin,
      mOffset: mOffset ?? this.mOffset,
      isLoadingShare: isLoadingShare ?? this.isLoadingShare,
      isLoadingPrint: isLoadingPrint ?? this.isLoadingPrint,
      action: action ?? this.action,
      radioValue: radioValue ?? this.radioValue,
      movements: movements ?? this.movements,
    );
  }

  @override
  List<Object?> get props => [
    test,
    interpretations,
    interpretations2,
    printStatus,
    gridPreMin,
    mOffset,
    isLoadingShare,
    isLoadingPrint,
    action,
    radioValue,
    movements,
  ];
}

class DetailsInitial extends DetailsState {
  const DetailsInitial({required super.test});

}