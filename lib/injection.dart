


import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:module_auth/data/auth_repository_impl.dart';
import 'package:module_auth/data/datasource/auth_remote_data.dart';
import 'package:module_auth/domain/repository/auth_repository.dart';
import 'package:module_auth/domain/usecase/listen_auth.dart';
import 'package:module_auth/domain/usecase/post_forgot_email.dart';
import 'package:module_auth/domain/usecase/post_login.dart';
import 'package:module_auth/domain/usecase/post_logout.dart';
import 'package:module_auth/domain/usecase/post_signup.dart';
import 'package:module_auth/persentation/bloc/auth_bloc.dart';

final GetIt locator = GetIt.instance;

Future<void> init() async{
  // Firebase: register first so other dependents can use it
  locator.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  // Remote data that depends on FirebaseAuth
  locator.registerLazySingleton<AuthRemoteData>(() => AuthRemoteDataImpl(locator<FirebaseAuth>()));

  // Repository depends on remote data
  locator.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(locator<AuthRemoteData>()));

  // Usecases depend on repository
  locator.registerLazySingleton<PostLogin>(() => PostLogin(locator<AuthRepository>()));
  locator.registerLazySingleton<PostLogout>(() => PostLogout(locator<AuthRepository>()));
  locator.registerLazySingleton<PostSignup>(() => PostSignup(locator<AuthRepository>()));
  locator.registerLazySingleton<ListenAuth>(() => ListenAuth(locator<AuthRepository>()));
  locator.registerLazySingleton(() => PostForgotEmail(locator()),);

  // Bloc: use factory so consumers get a fresh instance when needed
  locator.registerFactory<AuthBloc>(() => AuthBloc(locator<PostLogin>(), locator<PostLogout>(), locator<PostSignup>(), locator<ListenAuth>(),locator()));

}