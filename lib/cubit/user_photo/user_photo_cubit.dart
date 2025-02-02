import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:xride/services/user_photo_service.dart';

part 'user_photo_state.dart';

class UserPhotoCubit extends Cubit<UserPhotoState> {
  final UserPhotoService userPhotoService;

  UserPhotoCubit(this.userPhotoService) : super(UserPhotoInitial());

  Future<void> handleUpload(String photoType) async {
    if (isClosed) return; // Prevent emitting after closing
    emit(UserPhotoLoading());

    try {
      await userPhotoService.uploadPhoto(photoType);
      if (!isClosed) emit(UserPhotoFetchSuccess());
    } catch (e) {
      if (!isClosed) emit(UserPhotoFail(e.toString()));
    }
  }

  Future<void> handleDelete(String photoType) async {
    if (isClosed) return; // Prevent emitting after closing
    emit(UserPhotoLoading());

    try {
      await userPhotoService.deletePhoto(photoType);
      if (!isClosed) emit(UserPhotoDeleteSuccess());
    } catch (e) {
      if (!isClosed) emit(UserPhotoFail(e.toString()));
    }
  }
}
