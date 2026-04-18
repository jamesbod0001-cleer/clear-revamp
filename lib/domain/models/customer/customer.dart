import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer.freezed.dart';

@freezed
abstract class Customer with _$Customer {
  const factory Customer({
    required String id,           // The Flutterwave ID (e.g., cus_3XarB...)
    required String cleerId,      // Your internal Amplify User ID
    required String firstName,
    required String lastName,
    required String phoneNumber,
    DateTime? createdAt,
  }) = _Customer;
}