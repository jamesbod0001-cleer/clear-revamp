import 'package:cleer/data/services/flutterwave/requests/create_customer/create_customer_request.dart';
import 'package:cleer/data/services/flutterwave/requests/resolve_account/resolve_account_request.dart';
import 'package:cleer/data/services/flutterwave/responses/bank/bank_response.dart';
import 'package:cleer/data/services/flutterwave/responses/base/flutterwave_response.dart';
import 'package:cleer/data/services/flutterwave/responses/customer/customer_response.dart';
import 'package:cleer/data/services/flutterwave/responses/resolve_account/resolve_account_response.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'flutterwave_dio_provider.dart';

part 'flutterwave_service_client.g.dart';

@RestApi()
abstract class FlutterwaveServiceClient {
  factory FlutterwaveServiceClient(Dio dio, {String baseUrl}) =
      _FlutterwaveServiceClient;

  /// v4 Banks endpoint: https://developersandbox-api.flutterwave.com/banks?country=NG
  @GET("/banks")
  Future<FlutterwaveResponse<List<BankResponse>>> retrieveBanks(
    @Query("country") String country,
  );

  @POST("/banks/account-resolve")
  Future<FlutterwaveResponse<ResolveAccountResponse>> resolveAccount(
    @Body() ResolveAccountRequest body,
  );

  @POST("/customers")
  Future<FlutterwaveResponse<CustomerResponse>> createCustomer(
    @Body() CreateCustomerRequest body,
    @Header("X-Idempotency-Key") String idempotencyKey,
  );
}

@riverpod
FlutterwaveServiceClient flutterwaveServiceClient(Ref ref) {
  final dio = ref.watch(flutterwaveDioProvider);
  return FlutterwaveServiceClient(dio);
}
