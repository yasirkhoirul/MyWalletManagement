import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_dompet/data/datasource/sync_service.dart';

// ========== EVENTS ==========

abstract class SyncEvent {}

class StartSync extends SyncEvent {
  final int dompetId;
  StartSync(this.dompetId);
}

class CheckPendingSync extends SyncEvent {}

// ========== STATES ==========

abstract class SyncState {}

class SyncInitial extends SyncState {}

class SyncInProgress extends SyncState {
  final String message;
  SyncInProgress([this.message = 'Syncing...']);
}

class SyncSuccess extends SyncState {
  final SyncResult result;
  SyncSuccess(this.result);
}

class SyncError extends SyncState {
  final String error;
  SyncError(this.error);
}

class SyncPendingCount extends SyncState {
  final int count;
  SyncPendingCount(this.count);
}

// ========== BLOC ==========

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final SyncService _syncService;

  SyncBloc(this._syncService) : super(SyncInitial()) {
    on<StartSync>(_onStartSync);
    on<CheckPendingSync>(_onCheckPendingSync);
  }

  Future<void> _onStartSync(StartSync event, Emitter<SyncState> emit) async {
    emit(SyncInProgress('Starting sync...'));

    try {
      final result = await _syncService.performSync(event.dompetId);

      if (result.success) {
        emit(SyncSuccess(result));
      } else {
        emit(SyncError(result.message));
      }
    } catch (e) {
      emit(SyncError('Sync failed: $e'));
    }
  }

  Future<void> _onCheckPendingSync(
    CheckPendingSync event,
    Emitter<SyncState> emit,
  ) async {
    try {
      final count = await _syncService.getPendingSyncCount();
      emit(SyncPendingCount(count));
    } catch (e) {
      // Silently fail for background check
    }
  }
}
