


import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:module_core/service/network/network_service.dart';
import 'package:module_auth/data/auth_repository_impl.dart';
import 'package:module_auth/data/datasource/auth_remote_data.dart';
import 'package:module_auth/domain/repository/auth_repository.dart';
import 'package:module_auth/domain/usecase/listen_auth.dart';
import 'package:module_auth/domain/usecase/post_forgot_email.dart';
import 'package:module_auth/domain/usecase/post_login.dart';
import 'package:module_auth/domain/usecase/post_logout.dart';
import 'package:module_auth/domain/usecase/post_signup.dart';
import 'package:module_auth/persentation/bloc/auth_bloc.dart';
import 'package:module_dompet/data/datasource/db/database.dart';
import 'package:module_dompet/data/datasource/dompet_local_datasource.dart';
import 'package:module_dompet/data/transaction_repository_impl.dart';
import 'package:module_dompet/domain/repository/transaction_repository.dart';
import 'package:module_dompet/domain/usecase/delete_dompet_month.dart';
import 'package:module_dompet/domain/usecase/delete_transaction.dart' as delete_transaction;
import 'package:module_dompet/domain/usecase/get_dompet_months.dart';
import 'package:module_dompet/domain/usecase/get_list_transaction.dart' as get_list_transaction;
import 'package:module_dompet/domain/usecase/get_transaction_detail.dart' as get_transaction_detail;
import 'package:module_dompet/domain/usecase/insert_transaction.dart' as insert_transaction;
import 'package:module_dompet/domain/usecase/update_transaction.dart' as update_transaction;
import 'package:module_dompet/persentation/bloc/dompet_month_bloc.dart';
import 'package:module_dompet/persentation/bloc/transaction_bloc.dart';
import 'package:module_dompet/persentation/bloc/transaction_list_bloc.dart';

final GetIt locator = GetIt.instance;

Future<void> init() async{
  // Register core services
  locator.registerLazySingleton<NetworkService>(() => NetworkService());
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
  locator.registerLazySingleton<AuthBloc>(() => AuthBloc(locator<PostLogin>(), locator<PostLogout>(), locator<PostSignup>(), locator<ListenAuth>(),locator()));

  // ============ DOMPET MODULE ============
  
  // Database (singleton)
  locator.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // Local datasource
  locator.registerLazySingleton<DompetLocalDatasource>(() => DompetLocalDatasourceImpl(
    locator<AppDatabase>(),
    locator<AppDatabase>().transactionDao,
  ));

  // Repository
  locator.registerLazySingleton<TransactionRepository>(() => TransactionRepositoryImpl(locator<DompetLocalDatasource>()));

  // Usecases
  locator.registerLazySingleton<get_list_transaction.GetListTransaction>(() => get_list_transaction.GetListTransaction(locator<TransactionRepository>()));
  locator.registerLazySingleton<get_transaction_detail.GetTransactionDetail>(() => get_transaction_detail.GetTransactionDetail(locator<TransactionRepository>()));
  locator.registerLazySingleton<insert_transaction.InsertTransaction>(() => insert_transaction.InsertTransaction(locator<TransactionRepository>()));
  locator.registerLazySingleton<update_transaction.UpdateTransaction>(() => update_transaction.UpdateTransaction(locator<TransactionRepository>()));
  locator.registerLazySingleton<delete_transaction.DeleteTransaction>(() => delete_transaction.DeleteTransaction(locator<TransactionRepository>()));
  locator.registerLazySingleton<DeleteDompetMonth>(() => DeleteDompetMonth(locator<TransactionRepository>()));
  locator.registerLazySingleton<GetDompetMonths>(() => GetDompetMonths(locator<TransactionRepository>()));

  // BLoCs
  locator.registerLazySingleton<TransactionListBloc>(() => TransactionListBloc(locator<get_list_transaction.GetListTransaction>()));
  locator.registerLazySingleton<TransactionBloc>(() => TransactionBloc(
    locator<get_transaction_detail.GetTransactionDetail>(),
    locator<insert_transaction.InsertTransaction>(),
    locator<update_transaction.UpdateTransaction>(),
    locator<delete_transaction.DeleteTransaction>(),
  ));
  locator.registerLazySingleton<DompetMonthBloc>(() => DompetMonthBloc(locator<GetDompetMonths>(),locator()));

}