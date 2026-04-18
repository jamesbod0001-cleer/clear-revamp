import 'package:freezed_annotation/freezed_annotation.dart';

part 'charge.freezed.dart';

@freezed
abstract class Charge with _$Charge {
  const factory Charge({
    required String id,
    required String agreementId,
    required String reference,
    required double amount,
    required String currency,
    required ChargeStatus status,
    required ChargeAction action,
    String? customerId,
    DateTime? createdAt,
    List<ChargeFee>? feeBreakdown, // Optional: for detailed UI
  }) = _Charge;
}

enum ChargeStatus { succeeded, pending, failed, voided, unknown }

@freezed
abstract class ChargeFee with _$ChargeFee {
  const factory ChargeFee({
    required String type, // e.g., 'vat', 'merchant', 'app'
    required double amount,
  }) = _ChargeFee;
}

@freezed
class ChargeAction with _$ChargeAction {
  const factory ChargeAction.none() = _None;
  const factory ChargeAction.redirect(String url) = _Redirect;
  const factory ChargeAction.otp() = _Otp;
  const factory ChargeAction.pin() = _Pin;
  const factory ChargeAction.bankTransfer({
    required String accountNumber,
    required String bankName,
    DateTime? expiry,
  }) = _BankTransfer;
  const factory ChargeAction.qrCode(String imageUrl) = _QrCode;
  const factory ChargeAction.displayInstruction(String note) = _Instruction;
}
