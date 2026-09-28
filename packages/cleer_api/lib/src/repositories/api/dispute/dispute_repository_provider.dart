import 'package:cleer_api/src/repositories/api/dispute/amplify_dispute_repository_impl.dart';
import 'package:cleer_api/src/services/api/amplify_dispute_service_client.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dispute_repository_provider.g.dart';

@Riverpod(keepAlive: true)
DisputeRepository disputeRepository(Ref ref) =>
    AmplifyDisputeRepositoryImpl(
      disputeServiceClient: ref.watch(amplifyDisputeServiceClientProvider),
    );
