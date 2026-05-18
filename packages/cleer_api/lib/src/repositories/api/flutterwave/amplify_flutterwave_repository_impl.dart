import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer_api/src/env/env.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:cleer_api/src/mappers/flutterwave_mappers.dart';
import 'package:cleer_api/src/services/api/amplify_flutterwave_proxy_service_client.dart';

// Request/Response Models
import 'package:cleer_api/src/services/api/models/flutterwave/models/charge_filter/charge_filter.dart';
import 'package:cleer_api/src/services/api/models/flutterwave/models/cof/cof_object.dart';
import 'package:cleer_api/src/services/api/models/flutterwave/models/name/name_object.dart';
import 'package:cleer_api/src/services/api/models/flutterwave/models/phone/phone_object.dart';
import 'package:cleer_api/src/services/api/models/flutterwave/models/ussd/ussd_object.dart';
import 'package:cleer_api/src/services/api/models/flutterwave/requests/create_charge/create_charge_request.dart';
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
  Future<ResultDart<List<Bank>, DataFailure>> getBanks(CountryCode countryCode) async {
    return await performDataOperation<List<Bank>>(
      operation: () async {
        log.info('Retrieving banks for country code: ${countryCode.name}');
        final response = await _proxyServiceClient.retrieveBanks(countryCode.name);
        return response.data.map((dto) => dto.toDomain()).toList();
      },
      operationName: 'GetBanks',
      targetId: countryCode.name,
    );
  }

  @override
  Future<ResultDart<String, DataFailure>> resolveAccount(ResolveAccountParams params) async {
    return await performDataOperation<String>(
      operation: () async {
        log.info('Resolving account for bank code: ${params.bankCode} and account number: ${params.accountNumber}');
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
      operationName: 'ResolveAccount',
      targetId: params.accountNumber,
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
      operation: () async {
        log.info('Creating customer for userId: $userId');

        final sanitizedNumber = params.phoneNumber
            .replaceAll('+234', '')
            .replaceFirst(RegExp(r'^0'), '');

        // Generate an Idempotency Key locally to ensure safe retries
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
      operationName: 'CreateCustomer',
      targetId: userId,
    );
  }

  // ==========================================
  // PAYMENT METHODS
  // ==========================================

  @override
  Future<ResultDart<PaymentMethod, DataFailure>> getPaymentMethod(String id) async {
    return await performDataOperation<PaymentMethod>(
      operation: () async {
        log.info('Retrieving payment method with id: $id');
        final response = await _proxyServiceClient.retrievePaymentMethod(id);
        return response.data.toDomain();
      },
      operationName: 'GetPaymentMethod',
      targetId: id,
    );
  }

  @override
  Future<ResultDart<PaymentMethod, DataFailure>> createPaymentMethod(
      CreatePaymentMethodParams params,
      ) async {
    return await performDataOperation<PaymentMethod>(
      operation: () async {
        log.info('Creating payment method with type: ${params.runtimeType}');

        final CreatePaymentMethodRequest request = await params.when(
          card: (cardNumber, expiryMonth, expiryYear, cvv, cardHolderName, customerId, meta) async {
            // Local Encryption: Card details never hit our backend in plaintext.
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
                cof: COFObject(enabled: true),
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
      operationName: 'CreatePaymentMethod',
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
      operation: () async {
        log.info('Creating virtual account');

        final CreateVirtualAccountRequest request = await params.when(
          dynamic: (reference, customerId, amount, expiry, narration, merchantVatAmount, meta) async {
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
          static: (reference, customerId, bvn, nin, narration, merchantVatAmount, meta) {
            return CreateVirtualAccountRequest(
              reference: reference,
              customerId: customerId,
              amount: 0, // Static accounts don't have a fixed amount
              accountType: VirtualAccountType.static.name,
              narration: narration,
              merchantVatAmount: merchantVatAmount,
              meta: meta,
              bvn: bvn,
              nin: nin,
            );
          },
        );

        final response = await _proxyServiceClient.createVirtualAccount(request);
        return response.data.toDomain();
      },
      operationName: 'CreateVirtualAccount',
    );
  }

  // ==========================================
  // CHARGES
  // ==========================================

  @override
  Future<ResultDart<Charge, DataFailure>> createCharge(CreateChargeParams params) async {
    return await performDataOperation<Charge>(
      operation: () async {
        log.info('Creating charge for Agreement ID: ${params.agreementId}');

        final request = CreateChargeRequest(
          amount: params.amount,
          reference: ReferenceGenerator.generate(params.agreementId),
          customerId: params.customerId,
          paymentMethodId: params.paymentMethodId,
          meta: {'agreement_id': params.agreementId, ...params.meta ?? {}},
        );

        final response = await _proxyServiceClient.createCharge(request);
        return response.data.toDomain(params.agreementId);
      },
      operationName: 'CreateCharge',
      targetId: params.agreementId,
    );
  }

  @override
  Future<ResultDart<Charge, DataFailure>> getCharge(String id) async {
    return await performDataOperation<Charge>(
      operation: () async {
        log.info('Retrieving charge with id: $id');
        final response = await _proxyServiceClient.retrieveCharge(id);
        return response.data.toDomain('');
      },
      operationName: 'GetCharge',
      targetId: id,
    );
  }

  @override
  Future<ResultDart<List<Charge>, DataFailure>> listCharges(ListChargesParams params) async {
    return await performDataOperation<List<Charge>>(
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
      operationName: 'ListCharges',
    );
  }
}