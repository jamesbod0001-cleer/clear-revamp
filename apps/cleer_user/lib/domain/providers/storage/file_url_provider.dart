import 'package:cleer/domain/use_cases/storage/storage_use_case.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'file_url_provider.g.dart';

@riverpod
Future<String> fileUrl(Ref ref, String key) async {
  if (key.isEmpty) return "";

  final storageUseCase = ref.read(storageUseCaseProvider.notifier);

  final result = await storageUseCase.getUrl(key);

  return result.fold((url) => url.toString(), (failure) => throw failure);
}
