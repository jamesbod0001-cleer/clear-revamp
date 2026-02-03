import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/data/exceptions/payment_exception_handler.dart';
import 'package:cleer/data/mappers/flutterwave_mappers.dart';
import 'package:cleer/data/repositories/flutterwave/flutterwave_repository.dart';
import 'package:cleer/data/services/flutterwave/flutterwave_service_client.dart';
import 'package:cleer/data/services/flutterwave/models/name/name_object.dart';
import 'package:cleer/data/services/flutterwave/models/phone/phone_object.dart';
import 'package:cleer/data/services/flutterwave/requests/create_customer/create_customer_request.dart';
import 'package:cleer/data/services/flutterwave/requests/resolve_account/resolve_account_request.dart';
import 'package:cleer/domain/failures/payment_failures.dart';
import 'package:cleer/domain/models/bank/bank.dart';
import 'package:cleer/domain/models/customer/customer.dart';
import 'package:cleer/domain/models/enums/country_code.dart';
import 'package:cleer/domain/use_cases/flutterwave/params/create_customer_params.dart';
import 'package:cleer/domain/use_cases/flutterwave/params/resolve_account_params.dart';
import 'package:result_dart/result_dart.dart';

class FlutterwaveRepositoryImpl extends FlutterwaveRepository {
  final FlutterwaveServiceClient _flutterwaveServiceClient;

  FlutterwaveRepositoryImpl({
    required FlutterwaveServiceClient flutterwaveServiceClient,
  }) : _flutterwaveServiceClient = flutterwaveServiceClient;

  final _log = AmplifyLogger('FlutterwaveRepositoryImpl');

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
}
