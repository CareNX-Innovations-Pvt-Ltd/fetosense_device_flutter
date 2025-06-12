part of 'all_mothers_cubit.dart';

/// The base state class for managing the mothers list in the application.
///
/// `AllMothersState` is a sealed class used by `AllMothersCubit` to represent
/// different states during the process of loading, fetching, or filtering
/// the list of mothers. Subclasses include initial, loading, success, and failure states.
///
/// This class extends [Equatable] for value comparison in state management.

@immutable
sealed class AllMothersState extends Equatable {
  const AllMothersState();

  @override
  List<Object> get props => [];
}

final class AllMothersInitial extends AllMothersState {}

final class AllMothersLoading extends AllMothersState {}

final class AllMothersSuccess extends AllMothersState {
  final List<Mother> mother;

  const AllMothersSuccess(this.mother);

  @override
  List<Object> get props => [mother];
}

final class AllMothersFailure extends AllMothersState {
  final String error;

  const AllMothersFailure(this.error);

  @override
  List<Object> get props => [error];
}