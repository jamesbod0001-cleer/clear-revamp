import 'package:amplify_flutter/amplify_flutter.dart' hide SignedOutException;
import 'package:cleer/data/repositories/api/user/user_repository.dart';
import 'package:cleer/domain/failures/data_failures.dart';
import 'package:cleer/domain/models/user/user.dart';
import 'package:result_dart/result_dart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_use_case.g.dart';

@Riverpod(keepAlive: true)
class UserUseCase extends _$UserUseCase {
  late final UserRepository _userRepository;

  final _log = AmplifyLogger("UserUseCase");

  @override
  void build() {
    _userRepository = ref.watch(userRepositoryProvider);
    return;
  }

  Future<ResultDart<User, DataFailure>> updateUserProfile(User user) async {
    final result = await _userRepository.updateUserProfile(user);
    result.fold((user){
      _log.info("User updated successfully");
    }, (failure){
      _log.error("User update failed");
    });
    return result;
  }

}
