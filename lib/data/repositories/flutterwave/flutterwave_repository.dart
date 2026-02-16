import 'package:cleer/data/repositories/flutterwave/flutterwave_repository_impl.dart';
import 'package:cleer/data/services/flutterwave/flutterwave_service_client.dart';
import 'package:cleer/domain/failures/payment_failures.dart';
import 'package:cleer/domain/models/bank/bank.dart';
import 'package:cleer/domain/models/charge/charge.dart';
import 'package:cleer/domain/models/customer/customer.dart';
import 'package:cleer/domain/models/enums/country_code.dart';
import 'package:cleer/domain/models/payment_method/payment_method.dart';
import 'package:cleer/domain/models/virtual_account/virtual_account.dart';
import 'package:cleer/domain/use_cases/flutterwave/params/create_charge_params.dart';
import 'package:cleer/domain/use_cases/flutterwave/params/create_customer_params.dart';
import 'package:cleer/domain/use_cases/flutterwave/params/create_payment_method_params.dart';
import 'package:cleer/domain/use_cases/flutterwave/params/create_virtual_account_params.dart';
import 'package:cleer/domain/use_cases/flutterwave/params/list_charges_params.dart';
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

  Future<ResultDart<Customer, PaymentFailure>> createCustomer({
    required CreateCustomerParams params,
    required String userId,
  });

  Future<ResultDart<PaymentMethod, PaymentFailure>> getPaymentMethod(String id);
  Future<ResultDart<PaymentMethod, PaymentFailure>> createPaymentMethod(
    CreatePaymentMethodParams params,
  );

  Future<ResultDart<VirtualAccount, PaymentFailure>> createVirtualAccount(
    CreateVirtualAccountParams params,
  );

  Future<ResultDart<Charge, PaymentFailure>> createCharge(
    CreateChargeParams params,
  );

  Future<ResultDart<Charge, PaymentFailure>> getCharge(String id);
  Future<ResultDart<List<Charge>, PaymentFailure>> listCharges(
    ListChargesParams params,
  );
}
