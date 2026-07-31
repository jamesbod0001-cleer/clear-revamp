import 'package:cleer_api/src/repositories/api/transaction/amplify_transaction_repository_impl.dart';
import 'package:cleer_api/src/services/api/amplify_transaction_service_client.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transaction_repository_provider.g.dart';

@Riverpod(keepAlive: true)
TransactionRepository transactionRepository(Ref ref) =>
    AmplifyTransactionRepositoryImpl(
      amplifyTransactionServiceClient: ref.watch(
        amplifyTransactionServiceClientProvider,
      ),
    );
