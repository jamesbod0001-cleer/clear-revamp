import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/data/exceptions/payment_exception_handler.dart';
import 'package:cleer/data/mappers/flutterwave_mappers.dart';
import 'package:cleer/data/repositories/flutterwave/flutterwave_repository.dart';
import 'package:cleer/data/services/flutterwave/flutterwave_service_client.dart';
import 'package:cleer/data/services/flutterwave/models/name/name_object.dart';
import 'package:cleer/data/services/flutterwave/models/phone/phone_object.dart';
import 'package:cleer/data/services/flutterwave/requests/create_customer/create_customer_request.dart';
import 'package:cleer/data/services/flutterwave/requests/create_payment_method/create_payment_method_request.dart';
import 'package:cleer/data/services/flutterwave/requests/create_virtual_account/create_virtual_account_request.dart';
import 'package:cleer/data/services/flutterwave/requests/resolve_account/resolve_account_request.dart';
import 'package:cleer/domain/failures/payment_failures.dart';
import 'package:cleer/domain/models/bank/bank.dart';
import 'package:cleer/domain/models/customer/customer.dart';
import 'package:cleer/domain/models/enums/country_code.dart';
import 'package:cleer/domain/models/enums/payment_method_type.dart';
import 'package:cleer/domain/models/enums/virtual_account_type.dart';
import 'package:cleer/domain/models/payment_method/payment_method.dart';
import 'package:cleer/domain/models/virtual_account/virtual_account.dart';
import 'package:cleer/domain/use_cases/flutterwave/params/create_customer_params.dart';
import 'package:cleer/domain/use_cases/flutterwave/params/create_payment_method_params.dart';
import 'package:cleer/domain/use_cases/flutterwave/params/create_virtual_account_params.dart';
import 'package:cleer/domain/use_cases/flutterwave/params/resolve_account_params.dart';
import 'package:cleer/env/env.dart';
import 'package:cleer/utils/security_utils.dart';
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
    } catch (e) {
      _log.error('Error retrieving banks for country code: $countryCode', e);
      return Failure(PaymentExceptionHandler.handleException(e));
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
    } catch (e) {
      _log.error(
        'Error resolving account for bank code: ${params.bankCode} and account number: ${params.accountNumber}',
        e,
      );
      return Failure(PaymentExceptionHandler.handleException(e));
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
    } catch (e) {
      _log.error('Error creating customer with params: $params', e);
      return Failure(PaymentExceptionHandler.handleException(e));
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
    } catch (e) {
      _log.error('Error retrieving payment method with id: $id', e);
      return Failure(PaymentExceptionHandler.handleException(e));
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
                ),
              );

              return request;
            },
        opay: () async {
          final request = CreatePaymentMethodRequest(
            type: PaymentMethodType.opay.snakeCase,
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
    } catch (e) {
      _log.error(
        'Error creating payment method with type: ${params.runtimeType}',
        e,
      );
      return Failure(PaymentExceptionHandler.handleException(e));
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
    } catch (e) {
      _log.error('Error creating virtual account with params: $params', e);
      return Failure(PaymentExceptionHandler.handleException(e));
    }
  }
}
