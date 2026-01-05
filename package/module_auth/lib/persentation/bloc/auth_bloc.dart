import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:module_auth/domain/entities/user.dart';
import 'package:module_auth/domain/usecase/post_login.dart';
import 'package:module_auth/domain/usecase/post_logout.dart';
import 'package:module_auth/domain/usecase/post_signUp.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final PostLogin postLogin;
  final PostLogout postLogout;
  final PostSignup postSignup;
  AuthBloc(this.postLogin, this.postLogout, this.postSignup) : super(AuthInitial()) {
    on<AuthEvent>((event, emit) {
      on<AuthStarted>(onStarted);
      on<AuthOnLogin>(onLogin);
      on<AuthOnLogout>(onLogout);
      on<AuthOnSignUp>(onSignUp);
    });
  }

  Future<void> onStarted(AuthStarted event,Emitter<AuthState> emit)async{
    emit(AuthLoading());
  }

  Future<void> onLogin(AuthOnLogin event, Emitter<AuthState> emit)async{
    emit(AuthLoading());
    try {
      final response = await postLogin.execute(event.data);
      emit(AuthSucces(response));
    } catch (e) {
      emit(AuthFailed(e.toString()));
    }
  }

  Future<void> onLogout(AuthOnLogout event, Emitter<AuthState> emit)async{
    emit(AuthLoading());
    try {
      await postLogout.execute();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthFailed(e.toString()));
    }
  }
  Future<void> onSignUp(AuthOnSignUp event, Emitter<AuthState> emit)async{
    emit(AuthLoading());
    try {
      final response = await postSignup.execute(event.data);
      emit(AuthSucces(response));
    } catch (e) {
      emit(AuthFailed(e.toString()));
    }
  }
}
