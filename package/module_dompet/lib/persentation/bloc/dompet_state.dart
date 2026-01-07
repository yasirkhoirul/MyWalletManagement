part of 'dompet_bloc.dart';

abstract class DompetState {}

/// Initial state before loading
class DompetInitial extends DompetState {}

/// Loading state
class DompetLoading extends DompetState {}

/// Dompet loaded successfully
class DompetLoaded extends DompetState {
  final DompetEntity dompet;
  DompetLoaded(this.dompet);
}

/// Dompet not found - triggers initial wallet dialog
class DompetNotFound extends DompetState {
  final String userId;
  DompetNotFound(this.userId);
}

/// Error state
class DompetError extends DompetState {
  final String message;
  DompetError(this.message);
}
