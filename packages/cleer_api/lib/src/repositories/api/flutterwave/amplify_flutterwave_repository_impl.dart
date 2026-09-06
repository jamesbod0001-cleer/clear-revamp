import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer_api/src/env/env.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:cleer_api/src/mappers/flutterwave_mappers.dart';
import 'package:cleer_api/src/services/api/amplify_flutterwave_proxy_service_client.dart';

// Request/Response Models
import 'package:cleer_api/src/services/api/models/flutterwave/models/charge_filter/charge_filter.dart';
import 'package:cleer_api/src/services/api/models/flutterwave/models/name/name_object.dart';
import 'package:cleer_api/src/services/api/models/flutterwave/models/phone/phone_object.dart';
import 'package:cleer_api/src/services/api/models/flutterwave/models/ussd/ussd_object.dart';
import 'package:cleer_api/src/services/api/models/flutterwave/requests/create_charge/create_charge_request.dart';
import 'package:cleer_api/src/services/api/models/flutterwave/requests/update_charge/update_charge_request.dart';
import 'package:cleer_api/src/services/api/models/flutterwave/models/authorization/authorization_objects.dart';
import 'package:cleer_api/src/services/api/models/flutterwave/requests/create_customer/create_customer_request.dart';
import 'package:cleer_api/src/services/api/models/flutterwave/requests/create_payment_method/create_payment_method_request.dart';
import 'package:cleer_api/src/services/api/models/flutterwave/requests/create_virtual_account/create_virtual_account_request.dart';
import 'package:cleer_api/src/services/api/models/flutterwave/requests/resolve_account/resolve_account_request.dart';

// Core Utilities
import 'package:cleer_core/models/customer/customer.dart';
import 'package:cleer_core/models/payment_method/payment_method.dart';
import 'package:cleer_core/models/virtual_account/virtual_account.dart';
import 'package:cleer_core/utils/reference_generator.dart';
import 'package:cleer_core/utils/security_utils.dart';
import 'package:result_dart/result_dart.dart';
import 'package:cleer_api/src/repositories/api/mixins/amplify_api_repository_mixin.dart';

class AmplifyFlutterwaveRepositoryImpl
    with AmplifyApiRepositoryMixin
    implements FlutterwaveRepository {
  final AmplifyFlutterwaveProxyServiceClient _proxyServiceClient;

  AmplifyFlutterwaveRepositoryImpl({
    required AmplifyFlutterwaveProxyServiceClient proxyServiceClient,
  }) : _proxyServiceClient = proxyServiceClient;

  @override
  AmplifyLogger get log => AmplifyLogger('AmplifyFlutterwaveRepositoryImpl');

  // ==========================================
  // BANKS
  // ==========================================

  @override
  Future<ResultDart<List<Bank>, DataFailure>> getBanks(
      CountryCode countryCode,
      ) async {
    return await performDataOperation<List<Bank>>(
      operationName: 'GetBanks',
      targetId: countryCode.name,
      timeoutDuration: const Duration(seconds: 45), // 🔴 45s Timeout
      operation: () async {
        log.info('Retrieving banks for country code: ${countryCode.name}');
        final response = await _proxyServiceClient.retrieveBanks(
          countryCode.name,
        );
        return response.data.map((dto) => dto.toDomain()).toList();
      },
    );
  }

  @override
  Future<ResultDart<String, DataFailure>> resolveAccount(
      ResolveAccountParams params,
      ) async {
    return await performDataOperation<String>(
      operationName: 'ResolveAccount',
      targetId: params.accountNumber,
      timeoutDuration: const Duration(seconds: 45), // 🔴 45s Timeout
      operation: () async {
        log.info(
          'Resolving account for bank code: ${params.bankCode} and account number: ${params.accountNumber}',
        );
        final response = await _proxyServiceClient.resolveAccount(
          ResolveAccountRequest(
            account: AccountObject(
              code: params.bankCode,
              number: params.accountNumber,
            ),
          ),
        );
        return response.data.accountName;
      },
    );
  }

  // ==========================================
  // CUSTOMERS
  // ==========================================

  @override
  Future<ResultDart<Customer, DataFailure>> createCustomer({
    required CreateCustomerParams params,
    required String userId,
  }) async {
    return await performDataOperation<Customer>(
      operationName: 'CreateCustomer',
      targetId: userId,
      timeoutDuration: const Duration(seconds: 45), // 🔴 45s Timeout
      operation: () async {
        log.info('Creating customer for userId: $userId');

        final sanitizedNumber = params.phoneNumber
            .replaceAll('+234', '')
            .replaceFirst(RegExp(r'^0'), '');

        final String idempotencyKey = PaymentSecurityUtils.generateNonce();

        final response = await _proxyServiceClient.createCustomer(
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
          idempotencyKey,
        );

        return response.data.toDomain(userId);
      },
    );
  }

  // ==========================================
  // PAYMENT METHODS
  // ==========================================

  @override
  Future<ResultDart<PaymentMethod, DataFailure>> getPaymentMethod(
      String id,
      ) async {
    return await performDataOperation<PaymentMethod>(
      operationName: 'GetPaymentMethod',
      targetId: id,
      timeoutDuration: const Duration(seconds: 45), // 🔴 45s Timeout
      operation: () async {
        log.info('Retrieving payment method with id: $id');
        final response = await _proxyServiceClient.retrievePaymentMethod(id);
        return response.data.toDomain();
      },
    );
  }

  @override
  Future<ResultDart<PaymentMethod, DataFailure>> createPaymentMethod(
      CreatePaymentMethodParams params,
      ) async {
    return await performDataOperation<PaymentMethod>(
      operationName: 'CreatePaymentMethod',
      timeoutDuration: const Duration(seconds: 45), // 🔴 45s Timeout
      operation: () async {
        log.info('Creating payment method with type: ${params.runtimeType}');

        final CreatePaymentMethodRequest request = await params.when(
          card:
              (
              cardNumber,
              expiryMonth,
              expiryYear,
              cvv,
              cardHolderName,
              customerId,
              meta,
              ) async {
            final String nonce = PaymentSecurityUtils.generateNonce();
            final String encryptionKey = Env.flutterwaveEncryptionKey;

            return CreatePaymentMethodRequest(
              type: PaymentMethodType.card.snakeCase,
              card: CardRequestObject(
                encryptedCardNumber: await PaymentSecurityUtils.encryptAESGCM(cardNumber, encryptionKey, nonce),
                encryptedExpiryMonth: await PaymentSecurityUtils.encryptAESGCM(expiryMonth, encryptionKey, nonce),
                encryptedExpiryYear: await PaymentSecurityUtils.encryptAESGCM(expiryYear, encryptionKey, nonce),
                encryptedCvv: await PaymentSecurityUtils.encryptAESGCM(cvv, encryptionKey, nonce),
                nonce: nonce,
              ),
              customerId: customerId,
              meta: meta,
            );
          },
          opay: (customerId, meta) async {
            return CreatePaymentMethodRequest(
              type: PaymentMethodType.opay.snakeCase,
              customerId: customerId,
              meta: meta,
            );
          },
          ussd: (accountBankCode, customerId, meta) {
            return CreatePaymentMethodRequest(
              type: PaymentMethodType.ussd.snakeCase,
              ussd: USSDObject(accountBank: accountBankCode),
              customerId: customerId,
              meta: meta,
            );
          },
        );

        final response = await _proxyServiceClient.createPaymentMethod(request);
        return response.data.toDomain();
      },
    );
  }

  // ==========================================
  // VIRTUAL ACCOUNTS
  // ==========================================

  @override
  Future<ResultDart<VirtualAccount, DataFailure>> createVirtualAccount(
      CreateVirtualAccountParams params,
      ) async {
    return await performDataOperation<VirtualAccount>(
      operationName: 'CreateVirtualAccount',
      timeoutDuration: const Duration(seconds: 45), // 🔴 45s Timeout
      operation: () async {
        log.info('Creating virtual account');

        final CreateVirtualAccountRequest request = await params.when(
          dynamic:
              (reference, customerId, amount, expiry, narration, merchantVatAmount, meta) async {
            return CreateVirtualAccountRequest(
              reference: reference,
              customerId: customerId,
              amount: amount,
              accountType: VirtualAccountType.dynamic.name,
              expiry: expiry,
              narration: narration,
              merchantVatAmount: merchantVatAmount,
              meta: meta,
            );
          },
          static:
              (reference, customerId, bvn, nin, narration, merchantVatAmount, meta) {
            return CreateVirtualAccountRequest(
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
          },
        );

        final response = await _proxyServiceClient.createVirtualAccount(
          request,
        );
        return response.data.toDomain();
      },
    );
  }

  // ==========================================
  // CHARGES
  // ==========================================

  @override
  Future<ResultDart<Charge, DataFailure>> createCharge(
      CreateChargeParams params,
      ) async {
    return await performDataOperation<Charge>(
      operationName: 'CreateCharge',
      targetId: params.agreementId,
      timeoutDuration: const Duration(seconds: 45), // 🔴 45s Timeout
      operation: () async {
        log.info('Creating charge for Agreement ID: ${params.agreementId}');
        log.info(params.redirectUrl.toString());

        final request = CreateChargeRequest(
          amount: params.amount,
          reference: ReferenceGenerator.generate(params.agreementId),
          customerId: params.customerId,
          paymentMethodId: params.paymentMethodId,
          redirectUrl: params.redirectUrl,
          meta: {'cleer_agreement_id': params.agreementId, ...params.meta ?? {}},
        );

        final response = await _proxyServiceClient.createCharge(request);
        return response.data.toDomain(params.agreementId);
      },
    );
  }

  @override
  Future<ResultDart<Charge, DataFailure>> updateCharge({
    required String chargeId,
    required UpdateChargeParams params,
  }) async {
    return await performDataOperation<Charge>(
      operationName: 'UpdateCharge',
      targetId: chargeId,
      timeoutDuration: const Duration(seconds: 45), // 🔴 45s Timeout
      operation: () async {
        log.info('Updating charge with id: $chargeId');

        final authorization = await params.when(
          pin: (pin) async {
            final String nonce = PaymentSecurityUtils.generateNonce();
            final String encryptionKey = Env.flutterwaveEncryptionKey;
            final String encryptedPin =
                await PaymentSecurityUtils.encryptAESGCM(
              pin,
              encryptionKey,
              nonce,
            );
            return AuthorizationObject(
              type: 'pin',
              pin: PinObject(nonce: nonce, encryptedPin: encryptedPin),
            );
          },
          otp: (otp) async {
            return AuthorizationObject(
              type: 'otp',
              otp: OtpObject(code: otp),
            );
          },
        );

        final response = await _proxyServiceClient.updateCharge(
          chargeId,
          UpdateChargeRequest(authorization: authorization),
        );
        return response.data.toDomain('');
      },
    );
  }

  @override
  Future<ResultDart<Charge, DataFailure>> getCharge(String id) async {
    return await performDataOperation<Charge>(
      operationName: 'GetCharge',
      targetId: id,
      timeoutDuration: const Duration(seconds: 45), // 🔴 45s Timeout
      operation: () async {
        log.info('Retrieving charge with id: $id');
        final response = await _proxyServiceClient.retrieveCharge(id);
        return response.data.toDomain('');
      },
    );
  }

  @override
  Future<ResultDart<List<Charge>, DataFailure>> listCharges(
      ListChargesParams params,
      ) async {
    return await performDataOperation<List<Charge>>(
      operationName: 'ListCharges',
      timeoutDuration: const Duration(seconds: 45), // 🔴 45s Timeout
      operation: () async {
        log.info('Retrieving charges list');

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

        final response = await _proxyServiceClient.listCharges(request);
        return response.data.map((charge) => charge.toDomain('')).toList();
      },
    );
  }
}