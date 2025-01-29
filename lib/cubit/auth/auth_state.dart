part of 'auth_cubit.dart';

@immutable
sealed class AuthState {}

class AuthLoading extends AuthState {}
class AuthFailure extends AuthState {
  final String error;

  AuthFailure(this.error);
}

class AuthCreateLoading extends AuthState {}
class AuthCreateFailure extends AuthState {
  final String error;

  AuthCreateFailure(this.error);
}
class AuthCreateSuccess extends AuthState {}

final class UserLoggedOut extends AuthState {}

final class UserLoggedIn extends AuthState {}
