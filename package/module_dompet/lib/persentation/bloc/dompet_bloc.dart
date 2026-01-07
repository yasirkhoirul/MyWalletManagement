import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:module_dompet/domain/entities/dompet_entity.dart';
import 'package:module_dompet/domain/usecase/get_or_create_dompet.dart';

part 'dompet_event.dart';
part 'dompet_state.dart';

/// BLoC for managing dompet (wallet) state
class DompetBloc extends Bloc<DompetEvent, DompetState> {
  final GetOrCreateDompet _getOrCreateDompet;
  StreamSubscription<DompetEntity?>? _dompetSubscription;

  DompetBloc(this._getOrCreateDompet) : super(DompetInitial()) {
    on<LoadDompet>(_onLoadDompet);
    on<CreateDompet>(_onCreateDompet);
    on<_DompetUpdated>(_onDompetUpdated);
  }

  Future<void> _onLoadDompet(
    LoadDompet event,
    Emitter<DompetState> emit,
  ) async {
    emit(DompetLoading());

    try {
      // First check if dompet exists
      final dompet = await _getOrCreateDompet.execute(event.userId);

      if (dompet == null) {
        emit(DompetNotFound(event.userId));
      } else {
        emit(DompetLoaded(dompet));
        // Subscribe to updates
        _subscribeToUpdates(event.userId);
      }
    } catch (e) {
      emit(DompetError(e.toString()));
    }
  }

  Future<void> _onCreateDompet(
    CreateDompet event,
    Emitter<DompetState> emit,
  ) async {
    emit(DompetLoading());

    try {
      final dompet = await _getOrCreateDompet.create(
        event.userId,
        event.initialAmount,
      );
      emit(DompetLoaded(dompet));
      // Subscribe to updates
      _subscribeToUpdates(event.userId);
    } catch (e) {
      emit(DompetError(e.toString()));
    }
  }

  void _onDompetUpdated(_DompetUpdated event, Emitter<DompetState> emit) {
    if (event.dompet != null) {
      emit(DompetLoaded(event.dompet!));
    }
  }

  void _subscribeToUpdates(String userId) {
    _dompetSubscription?.cancel();
    _dompetSubscription = _getOrCreateDompet.watch(userId).listen((dompet) {
      if (dompet != null) {
        add(_DompetUpdated(dompet));
      }
    });
  }

  @override
  Future<void> close() {
    _dompetSubscription?.cancel();
    return super.close();
  }
}
