part of 'register_mother_cubit.dart';

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

class DoctorsLoaded extends RegisterMotherState {
  final List<Map<String, String>> doctors;

  const DoctorsLoaded(this.doctors);
}

class DoctorSelected extends RegisterMotherState {}

