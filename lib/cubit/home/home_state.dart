part of 'home_cubit.dart';

@immutable
sealed class HomeState {}

final class HomeInitial extends HomeState {}

final class UserLoggedOut extends HomeState {}

final class HomeError extends HomeState {
  final String error;

  HomeError(this.error);
}

final class UserLoading extends HomeState {}

final class UserFetchSuccess extends HomeState {
  final UserModel user;

  UserFetchSuccess(this.user);
}

final class UserFetchFail extends HomeState {
  final String error;

  UserFetchFail(this.error);
}