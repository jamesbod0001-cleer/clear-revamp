import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_identity.freezed.dart';
part 'auth_identity.g.dart';

@freezed
abstract class AuthIdentity with _$AuthIdentity {
  const factory AuthIdentity({
    required String userId,
    required String identityId,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String? email,
    bool? isEmailVerified,
  }) = _AuthIdentity;

  factory AuthIdentity.fromJson(Map<String, dynamic> json) =>
      _$AuthIdentityFromJson(json);
}
