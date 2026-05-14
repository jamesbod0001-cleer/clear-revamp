import 'package:cleer_api/src/repositories/flutterwave/flutterwave_repository_impl.dart';
import 'package:cleer_api/src/services/flutterwave/flutterwave_service_client.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'flutterwave_repository_provider.g.dart';

@riverpod
FlutterwaveRepository flutterwaveRepository(Ref ref) =>
    FlutterwaveRepositoryImpl(
      flutterwaveServiceClient: ref.watch(flutterwaveServiceClientProvider),
    );
