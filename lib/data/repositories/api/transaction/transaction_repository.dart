import 'package:cleer/data/repositories/api/transaction/amplify_transaction_repository_impl.dart';
import 'package:cleer/data/services/api/amplify_transaction_service_client.dart';
import 'package:cleer/domain/models/transaction/transaction.dart';
import 'package:fpdart/fpdart.dart';
import 'package:result_dart/result_dart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cleer/domain/failures/data_failures.dart';

part 'transaction_repository.g.dart';

@riverpod
TransactionRepository transactionRepository(Ref ref) =>
    AmplifyTransactionRepositoryImpl(
      amplifyTransactionServiceClient: ref.watch(
        amplifyTransactionServiceClientProvider,
      ),
    );

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
