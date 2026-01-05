import 'package:module_auth/domain/entities/user.dart';
import 'package:module_auth/domain/entities/auth_user.dart';

abstract class AuthRepository {
  Future<String> onLogin(User data);
  Future<String> onSignUp(User data);
  Future<void> onForget(String email);
  Future<void> onLogout();
  /// Stream of currently authenticated user as domain `AuthUser` or null.
  Stream<AuthUser?> onListenAuth();
}