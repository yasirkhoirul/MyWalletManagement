import 'package:module_auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<String> onLogin(User data);
  Future<String> onSignUp(User data);
  Future<void> onForget(String email);
  Future<void> onLogout();
  Stream onListenAuth();
}