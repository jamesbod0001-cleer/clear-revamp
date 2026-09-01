import 'package:cleer_core/cleer_core.dart';
import 'package:cleer_core/models/transaction/transaction_enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';

@freezed
abstract class Transaction with _$Transaction {
  const Transaction._();

  const factory Transaction({
    required String? id,
    required PaymentMethodType paymentMethodType,
    required String reference,
    required String flutterwaveId,
    required double amount,
    @Default(0.0) double cleerFee,
    @Default(0.0) double gatewayFee,
    @Default(TransactionStatus.pending) TransactionStatus status,
    @Default('NGN') String currency,
    String? flutterwavePaymentMethodId,
    Agreement? agreement,
  }) = _Transaction;

  /// Total debited from the user
  double get totalPaid => amount + gatewayFee;

  bool get isTerminal =>
      status == TransactionStatus.successful ||
      status == TransactionStatus.failed ||
      status == TransactionStatus.cancelled;
}
