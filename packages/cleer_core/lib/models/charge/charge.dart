import 'package:freezed_annotation/freezed_annotation.dart';

import 'charge_enums.dart';

export 'charge_enums.dart';

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

@freezed
abstract class ChargeFee with _$ChargeFee {
  const factory ChargeFee({
    required ChargeFeeType type,
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

extension ChargeFeeListX on List<ChargeFee> {
  /// Finds a specific [ChargeFee] by its [ChargeFeeType].
  ChargeFee? ofType(ChargeFeeType type) {
    for (final fee in this) {
      if (fee.type == type) return fee;
    }
    return null;
  }

  /// Specific fee amounts with fallback to 0.0
  double get vatAmount => ofType(ChargeFeeType.vat)?.amount ?? 0.0;
  double get appFeeAmount => ofType(ChargeFeeType.app)?.amount ?? 0.0;
  double get merchantFeeAmount => ofType(ChargeFeeType.merchant)?.amount ?? 0.0;
  double get stampDutyAmount => ofType(ChargeFeeType.stampDuty)?.amount ?? 0.0;

  /// Sum of all fee amounts in the list
  double get totalAmount => fold(0.0, (sum, fee) => sum + fee.amount);
}

extension ChargeX on Charge {
  /// Gets a specific [ChargeFee] object from feeBreakdown.
  ChargeFee? getFee(ChargeFeeType type) => feeBreakdown?.ofType(type);

  /// Quick accessors for fee amounts
  double get vatAmount => feeBreakdown?.vatAmount ?? 0.0;
  double get appFeeAmount => feeBreakdown?.appFeeAmount ?? 0.0;
  double get merchantFeeAmount => feeBreakdown?.merchantFeeAmount ?? 0.0;
  double get stampDutyAmount => feeBreakdown?.stampDutyAmount ?? 0.0;

  /// Total sum of all fees in breakdown
  double get totalFees => feeBreakdown?.totalAmount ?? 0.0;
}
