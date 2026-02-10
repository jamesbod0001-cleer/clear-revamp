import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/data/mappers/agreement_mappers.dart';
import 'package:cleer/data/repositories/api/agreement/agreement_repository.dart';
import 'package:cleer/data/services/api/amplify_agreement_service_client.dart';
import 'package:cleer/domain/models/agreement/agreement.dart';
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
        final response = await _amplifyAgreementServiceClient.createAgreement(
          agreement.toAmplify(),
        );
        return response.toDomain();
      },
      operationName: 'CreateAgreement',
      targetId: agreement.id,
    );
  }
}
