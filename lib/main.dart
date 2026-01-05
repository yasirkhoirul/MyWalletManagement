import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:module_auth/persentation/bloc/auth_bloc.dart';
import 'package:my_wallet_management/router/myrouter.dart';
import 'injection.dart' as injector;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await injector.init();

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(create: (context) => injector.locator<AuthBloc>()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    return MaterialApp.router(routerConfig: MyRouter().getMyrouter(authBloc));
  }
}
