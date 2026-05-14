import 'package:cleer_core/cleer_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cleer_api/src/repositories/storage/amplify_storage_repository_impl.dart';
import 'package:cleer_api/src/services/storage/amplify_storage_service_client.dart';

part 'storage_repository_provider.g.dart';

@riverpod
StorageRepository storageRepository(Ref ref) => AmplifyStorageRepositoryImpl(
  amplifyStorageServiceClient: ref.watch(amplifyStorageServiceClientProvider),
);
