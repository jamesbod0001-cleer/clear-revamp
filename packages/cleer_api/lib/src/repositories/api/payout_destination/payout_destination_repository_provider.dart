import 'package:cleer_api/src/repositories/api/payout_destination/amplify_payout_destination_repository_impl.dart';
import 'package:cleer_api/src/services/api/amplify_payout_destination_service_client.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payout_destination_repository_provider.g.dart';

@Riverpod(keepAlive: true)
PayoutDestinationRepository payoutDestinationRepository(Ref ref) =>
    AmplifyPayoutDestinationRepositoryImpl(
      amplifyPayoutDestinationServiceClient: ref.watch(
        amplifyPayoutDestinationServiceClientProvider,
      ),
    );
