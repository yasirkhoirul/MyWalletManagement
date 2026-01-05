import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:module_auth/domain/entities/user.dart';
import 'package:module_auth/domain/usecase/listen_auth.dart';
import 'package:module_auth/domain/usecase/post_forgot_email.dart';
import 'package:module_auth/domain/usecase/post_login.dart';
import 'package:module_auth/domain/usecase/post_logout.dart';
import 'package:module_auth/domain/usecase/post_signup.dart';
import 'package:module_core/error/custom_exception.dart';



part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final PostLogin postLogin;
  final PostLogout postLogout;
  final PostSignup postSignup;
  final ListenAuth listenAuth;
  final PostForgotEmail forgotEmail;
  late final StreamSubscription _authSub;
  AuthBloc(this.postLogin, this.postLogout, this.postSignup,this.listenAuth,this.forgotEmail) : super(AuthInitial()) {
    _authSub = listenAuth.execute().listen((event) {
      add(AuthOnCheck(event!=null));
    },);
    // register handlers directly (don't register handlers inside another handler)
    on<AuthOnCheck>(onCheck);
    on<AuthStarted>(onStarted);
    on<AuthOnLogin>(onLogin);
    on<AuthOnLogout>(onLogout);
    on<AuthOnSignUp>(onSignUp);
    on<AuthOnForgot>(onForget);
  }

  @override
  Future<void> close() {
    _authSub.cancel();
    return super.close();
  }

  Future<void> onCheck(AuthOnCheck event,Emitter<AuthState> emit) async{
    if (event.isLogged) {
      emit(AuthSucces("Sudah Login"));
    } else {
      emit(AuthInitial());
    }
  }

  Future<void> onStarted(AuthStarted event,Emitter<AuthState> emit)async{
    emit(AuthInitial());
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
      await postSignup.execute(event.data);
      add(AuthOnLogin(event.data));
    } catch (e) {
      emit(AuthFailed(e.toString()));
    }
  }

  Future<void> onForget(AuthOnForgot event,Emitter<AuthState> emit)async{
    emit(AuthLoading());
    try {
      await forgotEmail.execute(event.email);
      emit(AuthOnSendEmail());
    } on CustomFirebaseException catch(e){
      emit(AuthFailed(e.message));
    }
  }
}
