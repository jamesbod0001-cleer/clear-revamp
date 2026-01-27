import 'package:cleer/data/repositories/flutterwave/flutterwave_repository_impl.dart';
import 'package:cleer/data/services/flutterwave/flutterwave_service_client.dart';
import 'package:cleer/domain/failures/payment_failures.dart';
import 'package:cleer/domain/models/bank/bank.dart';
import 'package:cleer/domain/models/enums/country_code.dart';
import 'package:cleer/domain/use_cases/flutterwave/params/resolve_account_params.dart';
import 'package:result_dart/result_dart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'flutterwave_repository.g.dart';

@riverpod
FlutterwaveRepository flutterwaveRepository(Ref ref) =>
    FlutterwaveRepositoryImpl(
      flutterwaveServiceClient: ref.watch(flutterwaveServiceClientProvider),
    );

abstract class FlutterwaveRepository {
  Future<ResultDart<List<Bank>, PaymentFailure>> getBanks(
    CountryCode countryCode,
  );
  Future<ResultDart<String, PaymentFailure>> resolveAccount(
    ResolveAccountParams params,
  );
}
