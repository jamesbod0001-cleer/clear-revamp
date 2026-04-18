import 'package:amplify_flutter/amplify_flutter.dart' hide SignedOutException;
import 'package:cleer/data/repositories/api/transaction/transaction_repository.dart';
import 'package:cleer/domain/failures/data_failures.dart';
import 'package:cleer/domain/models/transaction/transaction.dart';
import 'package:fpdart/fpdart.dart';
import 'package:result_dart/result_dart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transaction_use_case.g.dart';

@Riverpod(keepAlive: true)
class TransactionUseCase extends _$TransactionUseCase {
  late final TransactionRepository _transactionRepository;

  final _log = AmplifyLogger("TransactionUseCase");

  @override
  void build() {
    _transactionRepository = ref.watch(transactionRepositoryProvider);
    return;
  }

  Future<ResultDart<Option<Transaction>, DataFailure>>
  getTransactionByFlutterwaveId(String flutterwaveId) async {
    _log.info('Getting transaction by Flutterwave ID: $flutterwaveId');
    final result = await _transactionRepository.getTransactionByFlutterwaveId(
      flutterwaveId,
    );
    result.fold(
      (transaction) {
        _log.info('Transaction retrieved: $transaction');
      },
      (failure) {
        _log.error('Error getting transaction', failure);
        throw failure;
      },
    );
    return result;
  }

  Future<ResultDart<Transaction, DataFailure>> updateTransaction(
    Transaction transaction,
  ) async {
    _log.info('Updating transaction: $transaction');
    final result = await _transactionRepository.updateTransaction(transaction);
    result.fold(
      (transaction) {
        _log.info('Transaction updated: $transaction');
      },
      (failure) {
        _log.error('Error updating transaction', failure);
        throw failure;
      },
    );
    return result;
  }
}
