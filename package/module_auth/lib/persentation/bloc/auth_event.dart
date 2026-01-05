part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

class AuthStarted extends AuthEvent{}

class AuthOnLogin extends AuthEvent{
  final User data;
  AuthOnLogin(this.data);
}

class AuthOnSignUp extends AuthEvent{
  final User data;
  AuthOnSignUp(this.data);
}
class AuthOnLogout extends AuthEvent{}
