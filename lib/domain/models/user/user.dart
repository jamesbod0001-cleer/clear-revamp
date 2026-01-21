import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String phoneNumber,
    required String firstName,
    required String lastName,
    String? email,
    DateTime? createdAt,
  }) = _User;
}
