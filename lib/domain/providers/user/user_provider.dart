import 'package:cleer/ui/auth/auth_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cleer/data/repositories/api/user/user_repository.dart';
import 'package:cleer/domain/models/user/user.dart';
import 'package:cleer/domain/use_cases/auth/auth_use_case.dart';

part 'user_provider.g.dart';

@Riverpod(keepAlive: true)
Stream<User?> user(Ref ref) {
  final authState = ref.watch(authUseCaseProvider).value;
  final userId = authState?.currentUserAuthIdentity?.userId;

  if (userId == null) {
    return Stream.value(null);
  }

  return ref.watch(userRepositoryProvider).watchUser(userId);
}
