import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/data/exceptions/backend_exception.dart';
import 'package:cleer/data/mappers/agreement_mappers.dart';
import 'package:cleer/data/repositories/api/agreement/agreement_repository.dart';
import 'package:cleer/data/services/api/amplify_agreement_service_client.dart';
import 'package:cleer/domain/models/agreement/agreement.dart';
import 'package:cleer/utils/short_code_generator.dart';
import 'package:result_dart/result_dart.dart';
import 'package:cleer/data/repositories/api/mixins/amplify_api_repository_mixin.dart';
import 'package:cleer/domain/failures/data_failures.dart';

class AmplifyAgreementRepositoryImpl
    with AmplifyApiRepositoryMixin
    implements AgreementRepository {
  final AmplifyAgreementServiceClient _amplifyAgreementServiceClient;

  AmplifyAgreementRepositoryImpl({
    required AmplifyAgreementServiceClient amplifyAgreementServiceClient,
  }) : _amplifyAgreementServiceClient = amplifyAgreementServiceClient;

  @override
  AmplifyLogger get log => AmplifyLogger('AmplifyAgreementRepositoryImpl');

  @override
  Future<ResultDart<Agreement, DataFailure>> createAgreement(
    Agreement agreement,
  ) async {
    return await performDataOperation<Agreement>(
      operation: () async {
        int attempts = 0;
        String currentCode = agreement.shortCode;

        while (attempts < 3) {
          log.info(
            'Checking shortCode uniqueness: $currentCode (Attempt ${attempts + 1})',
          );

          // Check if the code is already taken
          final existing = await _amplifyAgreementServiceClient
              .queryAgreementByShortCode(currentCode);

          if (existing != null && existing.items.isEmpty) {
            log.info('ShortCode is unique. Proceeding with creation.');

            // Map and Create
            final response = await _amplifyAgreementServiceClient
                .createAgreement(
                  agreement.copyWith(shortCode: currentCode).toAmplify(),
                );

            return response.toDomain();
          }

          // Collision logic
          log.warn(
            'ShortCode collision detected for $currentCode. Generating new code...',
          );
          currentCode = ShortCodeGenerator.generate();
          attempts++;
        }

        // If we exhaust attempts, we throw a specific error that the mixin will catch
        throw BackendException(
          'Could not generate a unique short code after 3 attempts.',
          recoverySuggestion: 'Please try creating the agreement again.',
        );
      },
      operationName: 'CreateAgreement',
      // We use the shortCode as the targetId for logging if the UUID isn't generated yet
      targetId: agreement.shortCode,
    );
  }

  @override
  Future<ResultDart<Agreement, DataFailure>> getAgreement(String id) async {
    return await performDataOperation<Agreement>(
      operation: () async {
        final response = await _amplifyAgreementServiceClient.queryAgreement(
          id,
        );
        return response.toDomain();
      },
      operationName: 'GetAgreement',
      targetId: id,
    );
  }

  @override
  Future<ResultDart<Agreement, DataFailure>> updateAgreement(
    Agreement agreement,
  ) async {
    return await performDataOperation<Agreement>(
      operation: () async {
        final response = await _amplifyAgreementServiceClient.updateAgreement(
          agreement.toAmplify(),
        );
        return response.toDomain();
      },
      operationName: 'UpdateAgreement',
      targetId: agreement.id,
    );
  }
}
