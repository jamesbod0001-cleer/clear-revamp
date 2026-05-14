import 'package:cleer_core/cleer_core.dart';
import 'package:result_dart/result_dart.dart';

abstract class UserRepository {
  Future<ResultDart<User, DataFailure>> getOrCreateUserProfile(User user);
  Future<ResultDart<User, DataFailure>> updateUserProfile(User user);
  Future<ResultDart<User, DataFailure>> getUser(String id);
  Stream<User> observeUserUpdates(String id);
}
