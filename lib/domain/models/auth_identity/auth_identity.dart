import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_identity.freezed.dart';

@freezed
abstract class AuthIdentity with _$AuthIdentity {
  const factory AuthIdentity({
    required String id,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String? email,
  }) = _AuthIdentity;
}
