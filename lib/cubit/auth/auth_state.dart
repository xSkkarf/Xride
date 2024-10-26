part of 'auth_cubit.dart';

@immutable
sealed class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}
class AuthFailure extends AuthState {
  final String error;

  AuthFailure(this.error);
}

final class UserLoggedOut extends AuthState {}

final class UserLoggedIn extends AuthState {}
