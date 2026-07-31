import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer_api/src/exceptions/backend_exception.dart';
import 'package:cleer_api/src/services/api/models/flutterwave/models/charge_filter/charge_filter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cleer_api/src/services/amplify_providers.dart';
import 'package:cleer_api/src/services/api/mixins/api_error_checker.dart';

// Flutterwave Models
import 'package:cleer_api/src/services/api/models/flutterwave/requests/create_charge/create_charge_request.dart';
import 'package:cleer_api/src/services/api/models/flutterwave/requests/create_customer/create_customer_request.dart';
import 'package:cleer_api/src/services/api/models/flutterwave/requests/create_payment_method/create_payment_method_request.dart';
import 'package:cleer_api/src/services/api/models/flutterwave/requests/create_virtual_account/create_virtual_account_request.dart';
import 'package:cleer_api/src/services/api/models/flutterwave/requests/resolve_account/resolve_account_request.dart';
import 'package:cleer_api/src/services/api/models/flutterwave/requests/update_charge/update_charge_request.dart';
import 'package:cleer_api/src/services/api/models/flutterwave/responses/bank/bank_response.dart';
import 'package:cleer_api/src/services/api/models/flutterwave/responses/base/flutterwave_response.dart';
import 'package:cleer_api/src/services/api/models/flutterwave/responses/charge/charge_response.dart';
import 'package:cleer_api/src/services/api/models/flutterwave/responses/customer/customer_response.dart';
import 'package:cleer_api/src/services/api/models/flutterwave/responses/payment_method/payment_method_response.dart';
import 'package:cleer_api/src/services/api/models/flutterwave/responses/resolve_account/resolve_account_response.dart';
import 'package:cleer_api/src/services/api/models/flutterwave/responses/virtual_account/virtual_account_response.dart';

part 'amplify_flutterwave_proxy_service_client.g.dart';

@Riverpod(keepAlive: true)
AmplifyFlutterwaveProxyServiceClient amplifyFlutterwaveProxyServiceClient(Ref ref) =>
    AmplifyFlutterwaveProxyServiceClient(amplifyAPI: ref.watch(amplifyAPIProvider));

class AmplifyFlutterwaveProxyServiceClient with ApiErrorChecker {
  final APICategory _amplifyAPI;

  AmplifyFlutterwaveProxyServiceClient({required APICategory amplifyAPI})
      : _amplifyAPI = amplifyAPI;

  // ==========================================
  // CORE PROXY ENGINE
  // ==========================================

  Future<Map<String, dynamic>> _callProxy({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    const String document = '''
      mutation FlutterwaveProxy(\$method: String!, \$endpoint: String!, \$payload: String, \$headers: String) {
        flutterwaveProxy(method: \$method, endpoint: \$endpoint, payload: \$payload, headers: \$headers)
      }
    ''';

    final request = GraphQLRequest<String>(
      document: document,
      variables: {
        'method': method,
        'endpoint': endpoint,
        if (body != null) 'payload': jsonEncode(body),
        if (headers != null) 'headers': jsonEncode(headers),
      },
      // CRITICAL: Ensure only authenticated Cognito users can trigger payments
      authorizationMode: APIAuthorizationType.userPools,
    );

    final response = await _amplifyAPI.mutate(request: request).response;

    // --- Error Parsing ---
    if (response.hasErrors) {
      final error = response.errors.first;

      // Extract the Flutterwave code (e.g., "0307") passed from Lambda -> AppSync
      final String? fwCode = error.extensions?['errorType']?.toString();

      throw BackendException(
        error.message,
        code: fwCode ?? 'ProxyError',
      );
    }

    if (response.data == null) {
      throw BackendException(
        'No data returned from payment proxy.',
        code: 'ProxyEmptyResponse',
      );
    }

    // --- Success Parsing ---
    final Map<String, dynamic> jsonData = jsonDecode(response.data!);
    final String proxyString = jsonData['flutterwaveProxy'] as String;

    return jsonDecode(proxyString) as Map<String, dynamic>;
  }


  // ==========================================
  // ENDPOINTS
  // ==========================================

  /// v4 Banks endpoint
  Future<FlutterwaveResponse<List<BankResponse>>> retrieveBanks(String country) async {
    final response = await _callProxy(
      method: 'GET',
      endpoint: '/banks?country=$country',
    );
    return FlutterwaveResponse.fromJson(
      response,
          (json) => (json as List).map((e) => BankResponse.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<FlutterwaveResponse<ResolveAccountResponse>> resolveAccount(ResolveAccountRequest body) async {
    final response = await _callProxy(
      method: 'POST',
      endpoint: '/banks/account-resolve',
      body: body.toJson(),
    );
    return FlutterwaveResponse.fromJson(
      response,
          (json) => ResolveAccountResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<FlutterwaveResponse<CustomerResponse>> createCustomer(
      CreateCustomerRequest body,
      String idempotencyKey,
      ) async {
    final response = await _callProxy(
      method: 'POST',
      endpoint: '/customers',
      body: body.toJson(),
      headers: {
        'X-Idempotency-Key': idempotencyKey,
      },
    );
    return FlutterwaveResponse.fromJson(
      response,
          (json) => CustomerResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<FlutterwaveResponse<PaymentMethodResponse>> createPaymentMethod(CreatePaymentMethodRequest body) async {
    final response = await _callProxy(
      method: 'POST',
      endpoint: '/payment-methods',
      body: body.toJson(),
    );
    return FlutterwaveResponse.fromJson(
      response,
          (json) => PaymentMethodResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<FlutterwaveResponse<PaymentMethodResponse>> retrievePaymentMethod(String id) async {
    final response = await _callProxy(
      method: 'GET',
      endpoint: '/payment-methods/$id',
    );
    return FlutterwaveResponse.fromJson(
      response,
          (json) => PaymentMethodResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<FlutterwaveResponse<VirtualAccountResponse>> createVirtualAccount(CreateVirtualAccountRequest body) async {
    final response = await _callProxy(
      method: 'POST',
      endpoint: '/virtual-accounts',
      body: body.toJson(),
    );
    return FlutterwaveResponse.fromJson(
      response,
          (json) => VirtualAccountResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<FlutterwaveResponse<ChargeResponse>> createCharge(CreateChargeRequest body) async {
    final response = await _callProxy(
      method: 'POST',
      endpoint: '/charges',
      body: body.toJson(),
    );
    return FlutterwaveResponse.fromJson(
      response,
          (json) => ChargeResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<FlutterwaveResponse<ChargeResponse>> retrieveCharge(String id) async {
    final response = await _callProxy(
      method: 'GET',
      endpoint: '/charges/$id',
    );
    return FlutterwaveResponse.fromJson(
      response,
          (json) => ChargeResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<FlutterwaveResponse<List<ChargeResponse>>> listCharges(ChargeFilter filter) async {
    // Convert the filter object into a URL query string
    final queryString = _buildQueryString(filter.toJson());

    final response = await _callProxy(
      method: 'GET',
      endpoint: '/charges$queryString',
    );
    return FlutterwaveResponse.fromJson(
      response,
          (json) => (json as List).map((e) => ChargeResponse.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<FlutterwaveResponse<ChargeResponse>> updateCharge(String id, UpdateChargeRequest body) async {
    final response = await _callProxy(
      method: 'POST', // Or PUT, depending on FW specs
      endpoint: '/charges/$id',
      body: body.toJson(),
    );
    return FlutterwaveResponse.fromJson(
      response,
          (json) => ChargeResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  // ==========================================
  // HELPERS
  // ==========================================

  /// Safely converts a JSON map to a URL query string (e.g., ?status=successful&page=1)
  /// Ignores any null values.
  String _buildQueryString(Map<String, dynamic> params) {
    final cleanParams = <String, String>{};

    params.forEach((key, value) {
      if (value != null) {
        cleanParams[key] = value.toString();
      }
    });

    if (cleanParams.isEmpty) return '';
    return '?${Uri(queryParameters: cleanParams).query}';
  }
}