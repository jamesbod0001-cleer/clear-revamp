import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/data/exceptions/payment_exception_handler.dart';
import 'package:cleer/data/mappers/flutterwave_mappers.dart';
import 'package:cleer/data/repositories/flutterwave/flutterwave_repository.dart';
import 'package:cleer/data/services/flutterwave/flutterwave_service_client.dart';
import 'package:cleer/data/services/flutterwave/models/charge_filter/charge_filter.dart';
import 'package:cleer/data/services/flutterwave/models/cof/cof_object.dart';
import 'package:cleer/data/services/flutterwave/models/name/name_object.dart';
import 'package:cleer/data/services/flutterwave/models/phone/phone_object.dart';
import 'package:cleer/data/services/flutterwave/models/ussd/ussd_object.dart';
import 'package:cleer/data/services/flutterwave/requests/create_charge/create_charge_request.dart';
import 'package:cleer/data/services/flutterwave/requests/create_customer/create_customer_request.dart';
import 'package:cleer/data/services/flutterwave/requests/create_payment_method/create_payment_method_request.dart';
import 'package:cleer/data/services/flutterwave/requests/create_virtual_account/create_virtual_account_request.dart';
import 'package:cleer/data/services/flutterwave/requests/resolve_account/resolve_account_request.dart';
import 'package:cleer/domain/failures/payment_failures.dart';
import 'package:cleer/domain/models/bank/bank.dart';
import 'package:cleer/domain/models/charge/charge.dart';
import 'package:cleer/domain/models/customer/customer.dart';
import 'package:cleer/domain/models/enums/country_code.dart';
import 'package:cleer/domain/models/enums/payment_method_type.dart';
import 'package:cleer/domain/models/enums/virtual_account_type.dart';
import 'package:cleer/domain/models/payment_method/payment_method.dart';
import 'package:cleer/domain/models/virtual_account/virtual_account.dart';
import 'package:cleer/domain/use_cases/flutterwave/params/create_charge_params.dart';
import 'package:cleer/domain/use_cases/flutterwave/params/create_customer_params.dart';
import 'package:cleer/domain/use_cases/flutterwave/params/create_payment_method_params.dart';
import 'package:cleer/domain/use_cases/flutterwave/params/create_virtual_account_params.dart';
import 'package:cleer/domain/use_cases/flutterwave/params/list_charges_params.dart';
import 'package:cleer/domain/use_cases/flutterwave/params/resolve_account_params.dart';
import 'package:cleer/env/env.dart';
import 'package:cleer/utils/reference_generator.dart';
import 'package:cleer/utils/security_utils.dart';
import 'package:dio/dio.dart';
import 'package:result_dart/result_dart.dart';

class FlutterwaveRepositoryImpl extends FlutterwaveRepository {
  final FlutterwaveServiceClient _flutterwaveServiceClient;

  FlutterwaveRepositoryImpl({
    required FlutterwaveServiceClient flutterwaveServiceClient,
  }) : _flutterwaveServiceClient = flutterwaveServiceClient;

  final _log = AmplifyLogger('FlutterwaveRepositoryImpl');

  // Banks
  @override
  Future<ResultDart<List<Bank>, PaymentFailure>> getBanks(
    CountryCode countryCode,
  ) async {
    try {
      _log.info('Retrieving banks for country code: $countryCode');
      final response = await _flutterwaveServiceClient.retrieveBanks(
        countryCode.name,
      );
      final List<Bank> banks = response.data
          .map((dto) => dto.toDomain())
          .toList();

      _log.info('Successfully retrieved banks for country code: $countryCode');

      return Success(banks);
    } on DioException catch (e) {
      final failure = FlutterwaveExceptionHandler.handleException(e);
      _log.error(
        'Error retrieving banks for country code: $countryCode',
        failure,
      );
      return Failure(failure);
    }
  }

  @override
  Future<ResultDart<String, PaymentFailure>> resolveAccount(
    ResolveAccountParams params,
  ) async {
    try {
      _log.info(
        'Resolving account for bank code: ${params.bankCode} and account number: ${params.accountNumber}',
      );
      final response = await _flutterwaveServiceClient.resolveAccount(
        ResolveAccountRequest(
          account: AccountObject(
            code: params.bankCode,
            number: params.accountNumber,
          ),
        ),
      );
      _log.info(
        'Successfully resolved account for bank code: ${params.bankCode} and account number: ${params.accountNumber}',
      );
      String accountName = response.data.accountName;
      return Success(accountName);
    } on DioException catch (e) {
      final failure = FlutterwaveExceptionHandler.handleException(e);
      _log.error(
        'Error resolving account for bank code: ${params.bankCode} and account number: ${params.accountNumber}',
        failure,
      );
      return Failure(failure);
    }
  }

  // Customers
  @override
  Future<ResultDart<Customer, PaymentFailure>> createCustomer({
    required CreateCustomerParams params,
    required String userId,
  }) async {
    try {
      _log.info('Creating customer with params: $params');
      final sanitizedNumber = params.phoneNumber
          .replaceAll('+234', '')
          .replaceFirst(RegExp(r'^0'), '');
      final response = await _flutterwaveServiceClient.createCustomer(
        CreateCustomerRequest(
          email: '$userId@cleerpayments.com',
          name: NameObject(
            first: params.firstName,
            middle: params.middleName,
            last: params.lastName,
          ),
          phone: PhoneObject(countryCode: '234', number: sanitizedNumber),
          meta: {'cleer_id': userId, ...params.meta ?? {}},
        ),
        userId,
      );
      _log.info('Successfully created customer with params: $params');
      return Success(response.data.toDomain(userId));
    } on DioException catch (e) {
      final failure = FlutterwaveExceptionHandler.handleException(e);
      _log.error('Error creating customer with params: $params', failure);
      return Failure(failure);
    }
  }

  // Payment Methods
  @override
  Future<ResultDart<PaymentMethod, PaymentFailure>> getPaymentMethod(
    String id,
  ) async {
    try {
      _log.info('Retrieving payment method with id: $id');
      final response = await _flutterwaveServiceClient.retrievePaymentMethod(
        id,
      );
      _log.info('Successfully retrieved payment method with id: $id');
      return Success(response.data.toDomain());
    } on DioException catch (e) {
      final failure = FlutterwaveExceptionHandler.handleException(e);
      _log.error('Error retrieving payment method with id: $id', failure);
      return Failure(failure);
    }
  }

  @override
  Future<ResultDart<PaymentMethod, PaymentFailure>> createPaymentMethod(
    CreatePaymentMethodParams params,
  ) async {
    try {
      _log.info('Creating payment method with type: ${params.runtimeType}');
      final CreatePaymentMethodRequest request = await params.when(
        card:
            (
              String cardNumber,
              String expiryMonth,
              String expiryYear,
              String cvv,
              String? cardHolderName,
              String? customerId,
              Map<String, dynamic>? meta,
            ) async {
              final String nonce = PaymentSecurityUtils.generateNonce();
              final String encryptionKey = Env.flutterwaveEncryptionKey;
              final request = CreatePaymentMethodRequest(
                type: PaymentMethodType.card.snakeCase,
                card: CardRequestObject(
                  encryptedCardNumber: await PaymentSecurityUtils.encryptAESGCM(
                    cardNumber,
                    encryptionKey,
                    nonce,
                  ),
                  encryptedExpiryMonth:
                      await PaymentSecurityUtils.encryptAESGCM(
                        expiryMonth,
                        encryptionKey,
                        nonce,
                      ),
                  encryptedExpiryYear: await PaymentSecurityUtils.encryptAESGCM(
                    expiryYear,
                    encryptionKey,
                    nonce,
                  ),
                  encryptedCvv: await PaymentSecurityUtils.encryptAESGCM(
                    cvv,
                    encryptionKey,
                    nonce,
                  ),
                  nonce: nonce,
                  cof: COFObject(enabled: true),
                ),
                customerId: customerId,
                meta: meta,
              );
              return request;
            },
        opay: (String? customerId, Map<String, dynamic>? meta) async {
          final request = CreatePaymentMethodRequest(
            type: PaymentMethodType.opay.snakeCase,
            customerId: customerId,
            meta: meta,
          );
          return request;
        },
        ussd:
            (
              String accountBankCode,
              String? customerId,
              Map<String, dynamic>? meta,
            ) {
              _log.info(accountBankCode);
              final request = CreatePaymentMethodRequest(
                type: PaymentMethodType.ussd.snakeCase,
                ussd: USSDObject(accountBank: accountBankCode),
                customerId: customerId,
                meta: meta,
              );
              return request;
            },
      );
      final response = await _flutterwaveServiceClient.createPaymentMethod(
        request,
      );
      _log.info(
        'Successfully created payment method with type: ${params.runtimeType}, id: ${response.data.id}',
      );
      return Success(response.data.toDomain());
    } on DioException catch (e) {
      final failure = FlutterwaveExceptionHandler.handleException(e);
      _log.error(
        'Error creating payment method with type: ${params.runtimeType}',
        failure,
      );
      return Failure(failure);
    }
  }

  @override
  Future<ResultDart<VirtualAccount, PaymentFailure>> createVirtualAccount(
    CreateVirtualAccountParams params,
  ) async {
    try {
      _log.info('Creating virtual account with params: $params');
      final CreateVirtualAccountRequest request = await params.when(
        dynamic:
            (
              String reference,
              String customerId,
              double amount,
              int? expiry,
              String? narration,
              String? merchantVatAmount,
              Map<String, dynamic>? meta,
            ) async {
              final request = CreateVirtualAccountRequest(
                reference: reference,
                customerId: customerId,
                amount: amount,
                accountType: VirtualAccountType.dynamic.name,
                expiry: expiry,
                narration: narration,
                merchantVatAmount: merchantVatAmount,
                meta: meta,
              );
              return request;
            },
        static:
            (
              String reference,
              String customerId,
              String? bvn,
              String? nin,
              String? narration,
              String? merchantVatAmount,
              Map<String, dynamic>? meta,
            ) {
              final request = CreateVirtualAccountRequest(
                reference: reference,
                customerId: customerId,
                amount: 0,
                accountType: VirtualAccountType.static.name,
                narration: narration,
                merchantVatAmount: merchantVatAmount,
                meta: meta,
                bvn: bvn,
                nin: nin,
              );
              return request;
            },
      );
      final response = await _flutterwaveServiceClient.createVirtualAccount(
        request,
      );
      _log.info('Successfully created virtual account with params: $params');
      return Success(response.data.toDomain());
    } on DioException catch (e) {
      final failure = FlutterwaveExceptionHandler.handleException(e);
      _log.error(
        'Error creating virtual account with params: $params',
        failure,
      );
      return Failure(failure);
    }
  }

  @override
  Future<ResultDart<Charge, PaymentFailure>> createCharge(
    CreateChargeParams params,
  ) async {
    try {
      _log.info('Creating charge with params: $params');
      final request = CreateChargeRequest(
        amount: params.amount,
        reference: ReferenceGenerator.generate(params.agreementId),
        customerId: params.customerId,
        paymentMethodId: params.paymentMethodId,
        meta: {'agreement_id': params.agreementId, ...params.meta ?? {}},
      );

      final response = await _flutterwaveServiceClient.createCharge(request);
      return Success(response.data.toDomain(params.agreementId));
    } on DioException catch (e) {
      final failure = FlutterwaveExceptionHandler.handleException(e);
      _log.error('Error creating charge with params: $params', failure);
      return Failure(failure);
    }
  }

  @override
  Future<ResultDart<Charge, PaymentFailure>> getCharge(String id) async {
    try {
      _log.info('Retrieving charge with id: $id');
      final response = await _flutterwaveServiceClient.retrieveCharge(id);
      _log.info('Successfully retrieved charge with id: $id');
      return Success(response.data.toDomain(''));
    } on DioException catch (e) {
      final failure = FlutterwaveExceptionHandler.handleException(e);
      _log.error('Error retrieving charge with id: $id', failure);
      return Failure(failure);
    }
  }

  @override
  Future<ResultDart<List<Charge>, PaymentFailure>> listCharges(
    ListChargesParams params,
  ) async {
    try {
      _log.info('Retrieving charges with params: $params');
      final request = ChargeFilter(
        status: params.status,
        reference: params.reference,
        to: params.to,
        from: params.from,
        customerId: params.customerId,
        virtualAccountId: params.virtualAccountId,
        paymentMethodId: params.paymentMethodId,
        page: params.page,
        size: params.size,
      );
      final response = await _flutterwaveServiceClient.listCharges(request);
      _log.info('Successfully retrieved charges with params: $params');
      return Success(
        response.data.map((charge) => charge.toDomain('')).toList(),
      );
    } on DioException catch (e) {
      final failure = FlutterwaveExceptionHandler.handleException(e);
      _log.error('Error retrieving charges with params: $params', failure);
      return Failure(failure);
    }
  }
}
