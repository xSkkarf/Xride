import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:xride/data/user/user_model.dart';
import 'package:xride/data/user/user_repo.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final UserRepo userRepo;

  UserCubit(this.userRepo) : super(UserInitial());

  Future<void> fetchUserInfo() async {
    try {
      emit(UserLoading());
      final user = await userRepo.fetchUserProfile();
      updateUserData(user);
    } catch (e) {
      emit(UserFetchFail(e.toString()));
    }
  }

  void updateUserData(UserModel user) {
    userRepo.saveUser(user);
    emit(UserFetchSuccess(user));
  }
}
