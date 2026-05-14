import 'package:cleer_core/models/photo/photo.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

@freezed
abstract class User with _$User {
  const User._();

  const factory User({
    required String id,
    required String identityId,
    required String phoneNumber,
    required String firstName,
    required String lastName,
    String? email,
    bool? isEmailVerified,
    Photo? profilePicture,
    required String flutterwaveCustomerId,
    @Default([]) List<String> flutterwavePaymentMethodIds,
    DateTime? createdAt,
  }) = _User;

  String get fullName => '$firstName $lastName';
}
