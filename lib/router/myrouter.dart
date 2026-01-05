import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:module_auth/module_auth.dart';
import 'package:module_auth/persentation/bloc/auth_bloc.dart';
import 'package:module_core/widget/main_scaffold.dart';
import 'package:module_dompet/persentation/page/history_page.dart';
import 'package:module_dompet/persentation/page/overview_page.dart';
import 'package:module_dompet/persentation/page/transaction_page.dart';
import 'package:my_wallet_management/notifier/auth_listerner.dart';

class MyRouter {
  GoRouter getMyrouter(AuthBloc authbloc) {
    return GoRouter(
      refreshListenable: AuthListerner(authbloc),
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => LoginPage()),
        GoRoute(path: '/signup', builder: (context, state) => SignupPage()),
        GoRoute(path: '/forgetpassword', builder: (context, state) => ForgotPage()),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
            MainScaffold(navigationShell, onLogout: () => authbloc.add(AuthOnLogout())),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/overview',
                  builder: (context, state) => OverviewPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/transaction',
                  builder: (context, state) => TransactionPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/history',
                  builder: (context, state) => HistoryPage(),
                ),
              ],
            ),
          ],
        ),
      ],
      redirect: (context, state) {
        Logger().d("state saat ini adalah ${authbloc.state} dan go router path saat ini adlaah ${state.fullPath}");
        final bool isLogin = authbloc.state is AuthSucces;
        final unsecurepath = ['/', '/signup','/forgetpassword'];
        if (!isLogin && !unsecurepath.contains(state.fullPath)) {
          return '/';
        }
        if (isLogin && unsecurepath.contains(state.fullPath)){
          return '/overview';
        }
        return null;
      },
    );
  }
}
