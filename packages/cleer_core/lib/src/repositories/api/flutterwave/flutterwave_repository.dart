import 'package:cleer_core/cleer_core.dart';
import 'package:cleer_core/models/customer/customer.dart';
import 'package:cleer_core/models/payment_method/payment_method.dart';
import 'package:cleer_core/models/virtual_account/virtual_account.dart';
import 'package:result_dart/result_dart.dart';

abstract class FlutterwaveRepository {
  Future<ResultDart<List<Bank>, DataFailure>> getBanks(
      CountryCode countryCode,
      );
  Future<ResultDart<String, DataFailure>> resolveAccount(
      ResolveAccountParams params,
      );

  Future<ResultDart<Customer, DataFailure>> createCustomer({
    required CreateCustomerParams params,
    required String userId,
  });

  Future<ResultDart<PaymentMethod, DataFailure>> getPaymentMethod(String id);
  Future<ResultDart<PaymentMethod, DataFailure>> createPaymentMethod(
      CreatePaymentMethodParams params,
      );

  Future<ResultDart<VirtualAccount, DataFailure>> createVirtualAccount(
      CreateVirtualAccountParams params,
      );

  Future<ResultDart<Charge, DataFailure>> createCharge(
      CreateChargeParams params,
      );

  Future<ResultDart<Charge, DataFailure>> getCharge(String id);
  Future<ResultDart<List<Charge>, DataFailure>> listCharges(
      ListChargesParams params,
      );
}
