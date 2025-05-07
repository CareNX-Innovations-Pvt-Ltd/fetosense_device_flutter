part of 'register_mother_cubit.dart';

@immutable
sealed class RegisterMotherState extends Equatable {
  const RegisterMotherState();

  @override
  List<Object?> get props => [];
}

final class RegisterMotherInitial extends RegisterMotherState {}

final class RegisterMotherLoading extends RegisterMotherState {}

final class RegisterMotherSuccess extends RegisterMotherState {
  final Test? test;
  final Mother? mother;

  const RegisterMotherSuccess(this.test, this.mother);

  @override
  List<Object?> get props => [test, mother];
}

final class RegisterMotherFailure extends RegisterMotherState {
  final String failure;

  const RegisterMotherFailure(this.failure);

  @override
  List<Object?> get props => [failure];
}

final class RegisterMotherDoctorLoaded extends RegisterMotherState {
  final List<Doctor> doctors;


  const RegisterMotherDoctorLoaded(this.doctors);

  @override
  List<Object?> get props => [doctors];
}
