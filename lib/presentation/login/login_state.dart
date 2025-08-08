part of 'login_cubit.dart';

/// Abstract base class representing the state of the login process.
///
/// `LoginState` is used by [LoginCubit] to emit different authentication states,
/// such as initial, loading, success, or failure. Subclasses provide specific
/// information for each state, allowing the UI to react accordingly.
///
/// All subclasses must implement [Equatable] for value comparison.

class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}


final class LoginInitial extends LoginState {}
final class LoginLoading extends LoginState {}
final class LoginSuccess extends LoginState {

}
final class LoginFailure extends LoginState {
  final String error;

  const LoginFailure(this.error);

  @override
  List<Object> get props => [error];
}
