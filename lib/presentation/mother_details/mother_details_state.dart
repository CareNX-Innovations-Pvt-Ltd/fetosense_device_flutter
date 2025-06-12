part of 'mother_details_cubit.dart';

/// Abstract base class representing the state of the mother details feature.
///
/// `MotherDetailsState` is used by [MotherDetailsCubit] to emit different states
/// during the process of fetching test data for a mother. Subclasses represent
/// specific states such as initial, loading, success, or failure, allowing the UI
/// to react accordingly.
///
/// All subclasses must implement [Equatable] for value comparison.

@immutable
sealed class MotherDetailsState extends Equatable {
  const MotherDetailsState();

  @override
  List<Object> get props => [];
}

final class MotherDetailsInitial extends MotherDetailsState {}

final class MotherDetailsLoading extends MotherDetailsState {}

final class MotherDetailsSuccess extends MotherDetailsState {
  final List<Test> test;

  const MotherDetailsSuccess(this.test);
}

final class MotherDetailsFailure extends MotherDetailsState {
  final String failure;

  const MotherDetailsFailure(this.failure);
}
