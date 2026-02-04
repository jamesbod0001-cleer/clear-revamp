import 'package:cleer/domain/models/enums/virtual_account_type.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'virtual_account.freezed.dart';

@freezed
abstract class VirtualAccount with _$VirtualAccount {
  const factory VirtualAccount({
    required String id,               // van_...
    required String accountNumber,
    required String bankName,
    required VirtualAccountType accountType,
    required double amount,           // The amount the user must send
    required String reference,        // Your internal transaction/agreement ID
    required String note,             // "Please make a transfer to..."
    required DateTime expiresAt,
    required DateTime createdAt,
    String? currency,
  }) = _VirtualAccount;

  const VirtualAccount._();

  /// UI Helper to show a countdown or "Expired" badge
  bool get isExpired => DateTime.now().isAfter(expiresAt);
}