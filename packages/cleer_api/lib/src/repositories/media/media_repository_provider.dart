import 'package:cleer_core/cleer_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cleer_api/src/repositories/media/media_repository_impl.dart';
import 'package:cleer_api/src/services/media/media_service_client.dart';

part 'media_repository_provider.g.dart';

@riverpod
MediaRepository mediaRepository(Ref ref) => MediaRepositoryImpl(
  mediaServiceClient: ref.watch(mediaServiceClientProvider),
);
