part of 'register_mother_cubit.dart';

@immutable
sealed class RegisterMotherState extends Equatable {
  const RegisterMotherState();

  @override
  List<Object> get props => [];
}

final class RegisterMotherInitial extends RegisterMotherState {}

final class RegisterMotherLoading extends RegisterMotherState {}

final class RegisterMotherSuccess extends RegisterMotherState {}

final class RegisterMotherFailure extends RegisterMotherState {
  final String failure;

  const RegisterMotherFailure(this.failure);
}
