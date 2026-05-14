import 'package:cleer_api/src/repositories/api/agreement/amplify_agreement_repository_impl.dart';
import 'package:cleer_api/src/services/api/amplify_agreement_service_client.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'agreement_repository_provider.g.dart';

@riverpod
AgreementRepository agreementRepository(Ref ref) =>
    AmplifyAgreementRepositoryImpl(
      amplifyAgreementServiceClient: ref.watch(
        amplifyAgreementServiceClientProvider,
      ),
    );
