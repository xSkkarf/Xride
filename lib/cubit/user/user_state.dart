part of 'user_cubit.dart';

@immutable
sealed class UserState {}

final class UserInitial extends UserState {}

final class UserLoading extends UserState {}

final class UserFetchSuccess extends UserState {
  final UserModel user;

  UserFetchSuccess(this.user);
}

final class UserFetchFail extends UserState {
  final String error;

  UserFetchFail(this.error);
}