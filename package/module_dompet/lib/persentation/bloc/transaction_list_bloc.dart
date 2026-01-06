import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:module_dompet/domain/entities/transaction_entity.dart';
import 'package:module_dompet/domain/usecase/get_list_transaction.dart' as get_list_uc;

part 'transaction_list_event.dart';
part 'transaction_list_state.dart';

class TransactionListBloc extends Bloc<TransactionListEvent, TransactionListState> {
  final get_list_uc.GetListTransaction getListTransaction;
  
  StreamSubscription<List<TransactionEntity>>? _transactionsSub;

  TransactionListBloc(this.getListTransaction) : super(TransactionListInitial()) {
    on<GetListTransaction>(_onGetListTransaction);
    on<_TransactionsUpdatedEvent>(_onTransactionsUpdated);
    on<_TransactionsErrorEvent>(_onTransactionsError);
  }

  void _onGetListTransaction(
    GetListTransaction event,
    Emitter<TransactionListState> emit,
  ) {
    // cancel previous subscription
    _transactionsSub?.cancel();
    emit(TransactionListLoading());

    _transactionsSub = getListTransaction.execute(withTempat: event.withTempat).listen(
      (transactions) => add(_TransactionsUpdatedEvent(transactions)),
      onError: (err) => add(_TransactionsErrorEvent(err.toString())),
    );
  }

  void _onTransactionsUpdated(
    _TransactionsUpdatedEvent event,
    Emitter<TransactionListState> emit,
  ) {
    emit(TransactionListSuccess(event.transactions));
  }

  void _onTransactionsError(
    _TransactionsErrorEvent event,
    Emitter<TransactionListState> emit,
  ) {
    emit(TransactionListError(event.message));
  }

  @override
  Future<void> close() {
    _transactionsSub?.cancel();
    return super.close();
  }
}
