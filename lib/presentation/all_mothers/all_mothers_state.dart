part of 'all_mothers_cubit.dart';

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