import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_preview.freezed.dart';

@freezed
abstract class UserPreview with _$UserPreview {
  const UserPreview._();

  const factory UserPreview({
    required String id,
    required String firstName,
    required String lastName,
  }) = _UserPreview;

  String get fullName => '$firstName $lastName';
}
