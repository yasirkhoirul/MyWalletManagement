part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}
final class AuthLoading extends AuthState {}
final class AuthOnSendEmail extends AuthState {}
final class AuthSucces extends AuthState {
  final String message;
  AuthSucces(this.message);
}
final class AuthFailed extends AuthState {
  final String message;
  AuthFailed(this.message);
}
