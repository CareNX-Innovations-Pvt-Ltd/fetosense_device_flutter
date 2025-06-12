part of 'register_mother_cubit.dart';

/// Abstract base class representing the state of the register mother feature.
///
/// `RegisterMotherState` is used by [RegisterMotherCubit] to emit different states
/// during the process of registering a mother and saving test data. Subclasses represent
/// specific states such as initial, loading, success, or failure, allowing the UI
/// to react accordingly.
///
/// All subclasses must implement [Equatable] for value comparison.

@immutable
sealed class RegisterMotherState extends Equatable {
  const RegisterMotherState();

  @override
  List<Object> get props => [];
}

final class RegisterMotherInitial extends RegisterMotherState {}

final class RegisterMotherLoading extends RegisterMotherState {}

final class RegisterMotherSuccess extends RegisterMotherState {
  final Test? test;
  final Mother? mother;
  const RegisterMotherSuccess(this.test, this.mother);
}

final class RegisterMotherFailure extends RegisterMotherState {
  final String failure;

  const RegisterMotherFailure(this.failure);
}
