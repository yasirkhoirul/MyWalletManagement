


import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:module_auth/data/auth_repository_impl.dart';
import 'package:module_auth/data/datasource/auth_remote_data.dart';
import 'package:module_auth/domain/repository/auth_repository.dart';
import 'package:module_auth/domain/usecase/post_login.dart';
import 'package:module_auth/domain/usecase/post_logout.dart';
import 'package:module_auth/domain/usecase/post_signup.dart';
import 'package:module_auth/persentation/bloc/auth_bloc.dart';

final GetIt locator = GetIt.instance;

Future<void> init() async{
  //remotedata
  locator.registerLazySingleton<AuthRemoteData>(() => AuthRemoteDataImpl(locator()),);

  //repository
  locator.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(locator()),);

  //bloc
  locator.registerCachedFactory(() => AuthBloc(locator(), locator(), locator()),);

  //usecase
  locator.registerLazySingleton(() => PostLogin(locator()),);
  locator.registerLazySingleton(() => PostLogout(locator()),);
  locator.registerLazySingleton(() => PostSignup(locator()),);

  //firebase
  locator.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance,);

  
}