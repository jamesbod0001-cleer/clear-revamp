import 'package:cleer/domain/models/photo/photo.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String identityId,
    required String phoneNumber,
    required String firstName,
    required String lastName,
    String? email,
    Photo? profilePicture,
    required String flutterwaveCustomerId,
    @Default([]) List<String> flutterwavePaymentMethodIds,
    DateTime? createdAt,
  }) = _User;
}
