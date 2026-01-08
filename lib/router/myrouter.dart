import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:module_auth/module_auth.dart';
import 'package:module_auth/persentation/bloc/auth_bloc.dart';
import 'package:module_core/widget/main_scaffold.dart';
import 'package:module_dompet/persentation/page/analyze_page.dart';
import 'package:module_dompet/persentation/page/budget_page.dart';
import 'package:module_dompet/persentation/page/dompet_month_page.dart';
import 'package:module_dompet/persentation/page/overview_page.dart';
import 'package:module_dompet/persentation/page/transaction_page.dart';
import 'package:module_dompet/persentation/bloc/sync_bloc.dart';
import 'package:module_dompet/data/datasource/db/dao.dart';
import 'package:module_dompet/data/datasource/sync_service.dart';
import 'package:my_wallet_management/notifier/auth_listerner.dart';

class MyRouter {
  GoRouter getMyrouter(AuthBloc authbloc, bool introCompleted) {
    return GoRouter(
      refreshListenable: AuthListerner(authbloc),
      // Show intro only on first launch, otherwise go to login
      initialLocation: introCompleted ? '/' : '/intro',
      routes: [
        GoRoute(
          path: '/intro',
          builder: (context, state) => const IntroductionPage(),
        ),
        GoRoute(path: '/', builder: (context, state) => LoginPage()),
        GoRoute(path: '/signup', builder: (context, state) => SignupPage()),
        GoRoute(
          path: '/forgetpassword',
          builder: (context, state) => ForgotPage(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            // Map SyncBloc stream to SyncStatus stream
            final syncStream = context.read<SyncBloc>().stream.map((syncState) {
              if (syncState is SyncInProgress) return SyncStatus.syncing;
              if (syncState is SyncSuccess) return SyncStatus.success;
              if (syncState is SyncError) return SyncStatus.failed;
              return SyncStatus.idle;
            });
            return MainScaffold(
              navigationShell,
              onLogout: () async {
                // Clear local database to prevent data leakage between users
                try {
                  final dao = GetIt.I<TransactionDao>();
                  await dao.clearAllData();
                  // Also clear sync preferences
                  final syncService = GetIt.I<SyncService>();
                  await syncService.clearLastSyncTime();
                } catch (e) {
                  // Log error but continue with logout
                  print('Error clearing data on logout: $e');
                }
                authbloc.add(AuthOnLogout());
              },
              syncStatusStream: syncStream,
            );
          },
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
                  builder: (context, state) => DompetMonthPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/analyze',
                  builder: (context, state) => const AnalyzePage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/budget',
                  builder: (context, state) => const BudgetPage(),
                ),
              ],
            ),
          ],
        ),
      ],
      redirect: (context, state) {
        final bool isLogin = authbloc.state is AuthSucces;
        final unsecurepath = ['/', '/signup', '/forgetpassword', '/intro'];
        if (!isLogin && !unsecurepath.contains(state.fullPath)) {
          return '/';
        }
        if (isLogin && unsecurepath.contains(state.fullPath)) {
          return '/overview';
        }
        return null;
      },
    );
  }
}
