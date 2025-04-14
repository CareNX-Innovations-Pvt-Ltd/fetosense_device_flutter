part of 'mother_details_cubit.dart';

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
