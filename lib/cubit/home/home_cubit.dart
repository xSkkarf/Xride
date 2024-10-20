import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:xride/data/user/user_model.dart';
import 'package:xride/data/user/user_repo.dart';
import 'package:xride/services/home_service.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeService homeService;
  final UserRepo userRepo = UserRepo();

  HomeCubit(this.homeService) : super(HomeInitial());

  Future<void> logout() async {
    try{
      await homeService.logout();
      emit(UserLoggedOut()); 
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> fetchUserInfo() async {
    try {
      emit(UserLoading());
      final user = await userRepo.fetchUserProfile();
      emit(UserFetchSuccess(user));
      
    } catch (e) {
      emit(UserFetchFail(e.toString()));
    }
  }
}
