import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/data/mappers/transaction_mappers.dart';
import 'package:cleer/data/repositories/api/transaction/transaction_repository.dart';
import 'package:cleer/data/services/api/amplify_transaction_service_client.dart';
import 'package:cleer/domain/models/transaction/transaction.dart';
import 'package:fpdart/fpdart.dart';
import 'package:result_dart/result_dart.dart';
import 'package:cleer/data/repositories/api/mixins/amplify_api_repository_mixin.dart';
import 'package:cleer/domain/failures/data_failures.dart';

class AmplifyTransactionRepositoryImpl
    with AmplifyApiRepositoryMixin
    implements TransactionRepository {
  final AmplifyTransactionServiceClient _amplifyTransactionServiceClient;

  AmplifyTransactionRepositoryImpl({
    required AmplifyTransactionServiceClient amplifyTransactionServiceClient,
  }) : _amplifyTransactionServiceClient = amplifyTransactionServiceClient;

  @override
  AmplifyLogger get log => AmplifyLogger('AmplifyTransactionRepositoryImpl');

  @override
  Future<ResultDart<Transaction, DataFailure>> createTransaction(
    Transaction transaction,
  ) async {
    return await performDataOperation<Transaction>(
      operation: () async {
        log.info('Creating transaction: $transaction');
        final response = await _amplifyTransactionServiceClient
            .createTransaction(transaction.toAmplify());
        log.info('Transaction created: $response');
        return response.toDomain();
      },
      operationName: 'CreateTransaction',
      targetId: 'Flutterwave Id: ${transaction.flutterwaveId}',
    );
  }

  @override
  Future<ResultDart<Option<Transaction>, DataFailure>>
  getTransactionByFlutterwaveId(String flutterwaveId) async {
    return await performDataOperation<Option<Transaction>>(
      operation: () async {
        log.info('Getting transaction by Flutterwave ID: $flutterwaveId');
        final response = await _amplifyTransactionServiceClient
            .getTransactionByFlutterwaveId(flutterwaveId);
        log.info('Transaction retrieved: $response');
        return Option.fromNullable(response?.toDomain());
      },
      operationName: 'GetTransactionByFlutterwaveId',
      targetId: 'Flutterwave Id: $flutterwaveId',
    );
  }

  @override
  Future<ResultDart<Transaction, DataFailure>> updateTransaction(
    Transaction transaction,
  ) async {
    return await performDataOperation<Transaction>(
      operation: () async {
        log.info('Updating transaction: $transaction');
        final response = await _amplifyTransactionServiceClient
            .updateTransaction(transaction.toAmplify());
        log.info('Transaction updated: $response');
        return response.toDomain();
      },
      operationName: 'UpdateTransaction',
      targetId: 'Flutterwave Id: ${transaction.flutterwaveId}',
    );
  }
}
