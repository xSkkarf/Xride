import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:xride/services/auth_service.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService authService;

  AuthCubit(this.authService) : super(UserLoggedOut());

  Future<void> checkLoginStatus() async {
    emit(AuthLoading()); // Emit loading while checking the login status
    final isLoggedIn = await authService.isLoggedIn();

    if (isLoggedIn) {
      emit(UserLoggedIn());
    } else {
      emit(UserLoggedOut());
    }
  }

  Future<bool> attemptTokenRefresh() async {
    bool result = await authService.attemptTokenRefresh();
    return result;
  }

  Future<void> monitorTokenExpiration() async {
    final refreshSuccessful = await authService.monitorTokenExpiration();

    if (refreshSuccessful) {
      emit(UserLoggedIn()); // Update the state with the new token
    } else {
      emit(UserLoggedOut()); // If refresh fails, log the user out
    }
  }

  Future<void> login(String email, String password) async {
    try {
      emit(AuthLoading());
      await authService.login(email, password);
      emit(UserLoggedIn());
    } catch (e) {
      emit(AuthFailure(e.toString()));
      emit(UserLoggedOut());
    }
  }

  Future<bool> isLoggedIn() async {
    final isLoggedIn = await authService.isLoggedIn();
    return isLoggedIn;
  }

  Future<void> logout() async {
    try{
      await authService.logout();
      emit(UserLoggedOut()); 
    } catch (e) {
      emit(AuthFailure(e.toString()));
      emit(UserLoggedOut());
    }
  }

  Future<void> signup(
    String username,
    String email, 
    String firstName, 
    String lastName, 
    String phoneNumber,
    String address,
    String nationalId,
    String password,
    String rePassword
    ) async {
      
    try {
      emit(AuthCreateLoading());
      await authService.signup(
        username,
        email,
        firstName,
        lastName,
        phoneNumber,
        address,
        nationalId,
        password,
        rePassword
      );
      emit(AuthCreateSuccess());
    } catch (e) {
      emit(AuthCreateFailure(e.toString()));
    }
  }
}
