import 'package:bloc/bloc.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';
import 'package:module_dompet/domain/entities/transaction_entity.dart';
import 'package:module_dompet/domain/usecase/delete_transaction.dart' as delete_tx_usecase;
import 'package:module_dompet/domain/usecase/get_transaction_detail.dart' as get_detail_usecase;
import 'package:module_dompet/domain/usecase/insert_transaction.dart' as insert_tx_usecase;
import 'package:module_dompet/domain/usecase/update_transaction.dart' as update_tx_usecase;

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final get_detail_usecase.GetTransactionDetail getTransactionDetail;
  final insert_tx_usecase.InsertTransaction insertTransaction;
  final update_tx_usecase.UpdateTransaction updateTransaction;
  final delete_tx_usecase.DeleteTransaction deleteTransaction;

  TransactionBloc(
    this.getTransactionDetail,
    this.insertTransaction,
    this.updateTransaction,
    this.deleteTransaction,
  ) : super(TransactionInitial()) {
    on<GetTransactionDetailEvent>(_onGetTransactionDetail);
    on<InsertTransactionEvent>(_onInsertTransaction);
    on<UpdateTransactionEvent>(_onUpdateTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
  }

  Future<void> _onGetTransactionDetail(
    GetTransactionDetailEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      final result = await getTransactionDetail.execute(event.transactionId);
      emit(TransactionDetailSuccess(result));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onInsertTransaction(
    InsertTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      await insertTransaction.execute(event.entity, event.dompetId);
      emit(TransactionSuccess('Transaction inserted successfully'));
    } catch (e) {
      Logger().e(e);
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onUpdateTransaction(
    UpdateTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      await updateTransaction.execute(event.entity, event.dompetId);
      emit(TransactionSuccess('Transaction updated successfully'));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onDeleteTransaction(
    DeleteTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      await deleteTransaction.execute(event.transactionId);
      emit(TransactionSuccess('Transaction deleted successfully'));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }
}
