import 'package:cleer/domain/models/agreement/agreement.dart';
import 'package:cleer/domain/models/enums/payment_method_type.dart';
import 'package:cleer/domain/models/transaction/transaction_enums.dart';
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
    @Default(TransactionStatus.pending) TransactionStatus status,
    @Default('NGN') String currency,
    String? flutterwavePaymentMethodId,
    Agreement? agreement,
  }) = _Transaction;

  bool get isTerminal =>
      status == TransactionStatus.successful ||
      status == TransactionStatus.failed ||
      status == TransactionStatus.cancelled;
}
