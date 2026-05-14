import 'package:cleer_core/cleer_core.dart';
import 'package:cleer_core/models/customer/customer.dart';
import 'package:cleer_core/models/payment_method/payment_method.dart';
import 'package:cleer_core/models/virtual_account/virtual_account.dart';
import 'package:result_dart/result_dart.dart';

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
