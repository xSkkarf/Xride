part of 'user_photo_cubit.dart';

@immutable
sealed class UserPhotoState {}

final class UserPhotoInitial extends UserPhotoState {}

final class UserPhotoLoading extends UserPhotoState {}

final class UserPhotoFetchSuccess extends UserPhotoState {}

final class UserPhotoDeleteSuccess extends UserPhotoState {}

final class UserPhotoFail extends UserPhotoState {
  final String error;

  UserPhotoFail(this.error);
}