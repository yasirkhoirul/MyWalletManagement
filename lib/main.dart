import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:module_core/service/network/network_service.dart';
import 'package:module_core/theme/theme.dart';
import 'package:module_core/theme/util.dart';
import 'firebase_options.dart';
import 'package:module_auth/persentation/bloc/auth_bloc.dart';
import 'package:module_dompet/persentation/bloc/dompet_month_bloc.dart';
import 'package:module_dompet/persentation/bloc/transaction_bloc.dart';
import 'package:module_dompet/persentation/bloc/transaction_list_bloc.dart';
import 'package:my_wallet_management/router/myrouter.dart';
import 'injection.dart' as injector;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await injector.init();

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(create: (context) => injector.locator<AuthBloc>()),
      BlocProvider(create: (context) => injector.locator<TransactionListBloc>()),
      BlocProvider(create: (context) => injector.locator<TransactionBloc>()),
      BlocProvider(create: (context) => injector.locator<DompetMonthBloc>()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void reassemble() {
    super.reassemble();
    // Called on hot reload — refresh network status
    try {
      NetworkService().refresh();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = createTextTheme(context, "Roboto Flex", "Montserrat");

    MaterialTheme theme = MaterialTheme(textTheme);
    final authBloc = context.read<AuthBloc>();
    return MaterialApp.router(
      theme: theme.dark(),
      routerConfig: MyRouter().getMyrouter(authBloc));
  }
}
