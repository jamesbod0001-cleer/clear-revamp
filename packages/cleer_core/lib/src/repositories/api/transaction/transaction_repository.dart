import 'package:cleer_core/cleer_core.dart';
import 'package:fpdart/fpdart.dart';
import 'package:result_dart/result_dart.dart';

abstract class TransactionRepository {
  Future<ResultDart<Transaction, DataFailure>> createTransaction(
    Transaction transaction,
  );
  Future<ResultDart<Option<Transaction>, DataFailure>>
  getTransactionByFlutterwaveId(String flutterwaveId);
  Future<ResultDart<Transaction, DataFailure>> updateTransaction(
    Transaction transaction,
  );
}
