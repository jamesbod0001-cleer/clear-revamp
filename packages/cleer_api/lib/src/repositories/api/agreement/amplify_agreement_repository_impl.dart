import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer_api/src/exceptions/backend_exception.dart';
import 'package:cleer_api/src/mappers/agreement_preview_mappers.dart';
import 'package:cleer_api/src/models/ModelProvider.dart' as amplify_model;
import 'package:cleer_core/cleer_core.dart';
import 'package:cleer_api/src/mappers/agreement_mappers.dart';
import 'package:cleer_api/src/mappers/status_history_mappers.dart';
import 'package:cleer_api/src/services/api/amplify_agreement_service_client.dart';
import 'package:cleer_api/src/services/api/models/paginated_request/paginated_request.dart';
import 'package:cleer_core/models/paginated_list/paginated_list.dart';
import 'package:cleer_core/utils/short_code_generator.dart';
import 'package:result_dart/result_dart.dart';
import 'package:cleer_api/src/repositories/api/mixins/amplify_api_repository_mixin.dart';

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

            final serverTime = await _amplifyAgreementServiceClient
                .getServerTime();
            // Map and Create
            final response = await _amplifyAgreementServiceClient
                .createAgreement(
                  agreement
                      .copyWith(shortCode: currentCode)
                      .toAmplify()
                      .copyWith(createdAt: serverTime),
                );
            return (await _amplifyAgreementServiceClient.queryAgreement(
              response.id,
            )).toDomain();
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
    Agreement agreement, {
    required String currentUserId,
  }) async {
    return await performDataOperation<Agreement>(
      operation: () async {
        log.info(agreement.createdAt.toString());
        final response = await _amplifyAgreementServiceClient.updateAgreement(
          agreement.copyWith(lastUpdatedBy: currentUserId).toAmplify(),
        );
        log.info(response.createdAt.toString());
        return (await _amplifyAgreementServiceClient.queryAgreement(
          response.id,
        )).toDomain();
      },
      operationName: 'UpdateAgreement',
      targetId: agreement.id,
    );
  }

  @override
  Future<ResultDart<PaginatedList<Agreement>, DataFailure>>
  getUserCompletedAgreements({dynamic nextRequest}) async {
    return await performDataOperation<PaginatedList<Agreement>>(
      operation: () async {
        final response = await _amplifyAgreementServiceClient
            .queryUserAgreementsByStatus(
              status: amplify_model.AgreementStatus.RELEASED,
              limit: 100,
              nextRequest: nextRequest,
            );
        return PaginatedList(
          items: response.items
              .whereType<amplify_model.Agreement>()
              .map((e) => e.toDomain())
              .toList(),
          hasNextPage: response.hasNextResult,
          nextRequest: response.requestForNextResult,
        );
      },
      operationName: 'GetUserCompletedAgreements',
    );
  }

  @override
  Future<ResultDart<List<Agreement>, DataFailure>>
  getUserOngoingAgreements() async {
    /// TODO: Come and update here when needed to add the other states that fall under on going
    return await performDataOperation<List<Agreement>>(
      operation: () async {
        final response = await _amplifyAgreementServiceClient
            .queryUserAgreements(
              PaginatedRequest(
                where: amplify_model.Agreement.STATUS
                    .eq(amplify_model.AgreementStatus.AWAITING_RECIPIENT)
                    .or(
                      amplify_model.Agreement.STATUS.eq(
                        amplify_model.AgreementStatus.AWAITING_FUNDING,
                      ),
                    )
                    .or(
                      amplify_model.Agreement.STATUS.eq(
                        amplify_model.AgreementStatus.FUNDED,
                      ),
                    )
                    .or(
                      amplify_model.Agreement.STATUS.eq(
                        amplify_model.AgreementStatus.IN_PROGRESS,
                      ),
                    )
                    .or(
                      amplify_model.Agreement.STATUS.eq(
                        amplify_model.AgreementStatus.READY_FOR_RELEASE,
                      ),
                    )
                    .or(
                      amplify_model.Agreement.STATUS.eq(
                        amplify_model.AgreementStatus.PROCESSING_RELEASE,
                      ),
                    ).or(
                      amplify_model.Agreement.STATUS.eq(
                        amplify_model.AgreementStatus.DISPUTED,
                      ),
                    ),
              ),
            );
        log.info(response.items.length.toString());
        return response.items
            .whereType<amplify_model.Agreement>()
            .map((e) => e.toDomain())
            .toList();
      },
      operationName: 'GetUserOngoingAgreements',
    );
  }

  @override
  Stream<Agreement> observeUserAgreementsUpdates() {
    return _amplifyAgreementServiceClient
        .observeUserAgreementsUpdates()
        .handleError((error) => log.error('Stream error for agreement', error))
        .where((event) => event.data != null)
        .map((event) {
          log.info('New event: Agreement updated: ${event.data}');
          return event.data!.toDomain();
        });
  }

  @override
  Future<ResultDart<AgreementPreview, DataFailure>> getAgreementPreview(
    String shortCode,
  ) async {
    return await performDataOperation<AgreementPreview>(
      operation: () async {
        final response = await _amplifyAgreementServiceClient
            .getAgreementPreviewData(shortCode);
        return response.toDomain();
      },
      operationName: 'GetAgreementPreviewData',
      targetId: shortCode,
    );
  }

  @override
  Future<ResultDart<String, DataFailure>> joinAgreement(
    String shortCode,
  ) async {
    return await performDataOperation<String>(
      operation: () async {
        final response = await _amplifyAgreementServiceClient.joinAgreement(
          shortCode,
        );
        return response;
      },
      operationName: 'JoinAgreement',
      targetId: shortCode,
    );
  }

  @override
  Future<ResultDart<Agreement, DataFailure>> releaseFunds(
    String id, {
    required String currentUserId,
  }) async {
    return await performDataOperation<Agreement>(
      operation: () async {
        final response = await _amplifyAgreementServiceClient.queryAgreement(
          id,
        );
        final Agreement agreement = response.toDomain();
        if (agreement.disbursementType == DisbursementType.oneTime) {
          final serverTime = await _amplifyAgreementServiceClient
              .getServerTime();
          final releaseEligibleTime = serverTime
              .getDateTimeInUtc()
              .toLocal()
              .add(const Duration(hours: 2));
          final updatedResponse = await _amplifyAgreementServiceClient
              .updateAgreement(
                agreement
                    .copyWith(
                      lastUpdatedBy: currentUserId,
                      status: AgreementStatus.processingRelease,
                      releaseEligibleAt: releaseEligibleTime,
                    )
                    .toAmplify(),
              );
          return (await _amplifyAgreementServiceClient.queryAgreement(
            updatedResponse.id,
          )).toDomain();
        } else {
          throw BackendException(
            'This function is only meant to be called for agreements with one time disbursement type.',
          );
        }
      },
      operationName: 'ReleaseFunds',
      targetId: id,
    );
  }

  @override
  Future<ResultDart<List<StatusHistory>, DataFailure>>
  getAgreementStatusHistory(String agreementId) async {
    return await performDataOperation(
      operation: () async {
        log.info('Getting status history for agreement: $agreementId');
        final response = await _amplifyAgreementServiceClient
            .queryAgreementStatusHistory(agreementId);
        log.info('Status history retrieved: ${response.items.length}');
        return response.items
            .whereType<amplify_model.StatusHistory>()
            .map((e) => e.toDomain())
            .toList();
      },
      operationName: 'GetAgreementStatusHistory',
    );
  }

  @override
  Stream<StatusHistory> observeAgreementStatusHistoryCreates(
    String agreementId,
  ) {
    return _amplifyAgreementServiceClient
        .observeAgreementStatusHistoryCreates(agreementId)
        .handleError(
          (error) => log.error('Stream error for status history', error),
        )
        .where((event) => event.data != null)
        .map((event) {
          log.info('New event: Status history created: ${event.data}');
          return event.data!.toDomain();
        });
  }
}
