import 'package:go_router/go_router.dart';
import 'package:module_auth/module_auth.dart';

class MyRouter {
  GoRouter getMyrouter() {
    return GoRouter(
      initialLocation: '/',
      routes: [
      StatefulShellRoute.indexedStack(branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/',
          builder: (context, state) => LoginPage(),)
        ])
      ])
    ], redirect: (context, state) {});
  }
}
