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
class AuthOnCheck extends AuthEvent{
  final bool isLogged;
  AuthOnCheck(this.isLogged);
}
class AuthOnForgot extends AuthEvent{
  final String email;
  AuthOnForgot(this.email);
}
class AuthOnLogout extends AuthEvent{}