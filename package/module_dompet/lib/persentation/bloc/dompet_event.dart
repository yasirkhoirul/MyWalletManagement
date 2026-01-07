part of 'dompet_bloc.dart';

abstract class DompetEvent {}

/// Load dompet by Firebase user ID
class LoadDompet extends DompetEvent {
  final String userId;
  LoadDompet(this.userId);
}

/// Create new dompet for user
class CreateDompet extends DompetEvent {
  final String userId;
  final double initialAmount;
  CreateDompet(this.userId, this.initialAmount);
}

/// Internal event when dompet stream updates
class _DompetUpdated extends DompetEvent {
  final DompetEntity? dompet;
  _DompetUpdated(this.dompet);
}
