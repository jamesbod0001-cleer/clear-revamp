import 'package:cleer_api/src/models/ModelProvider.dart' as amplify_model;
import 'package:cleer_api/src/mappers/agreement_mappers.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:cleer_core/models/transaction/transaction.dart' as domain;
import 'package:cleer_core/models/transaction/transaction_enums.dart';

/// Extensions on the Amplify Transaction model to convert it to the Domain Task entity.
extension TransactionToDomainMapper on amplify_model.Transaction {
  domain.Transaction toDomain() {
    return domain.Transaction(
      id: id,
      paymentMethodType: _mapTransactionPaymentMethodTypeToDomain(
        paymentMethodType!,
      ),
      reference: reference,
      flutterwaveId: flutterwaveId,
      amount: amount,
      cleerFee: cleerFee ?? 0.0,
      gatewayFee: gatewayFee ?? 0.0,
      currency: currency,
      flutterwavePaymentMethodId: flutterwavePaymentMethodId,
      status: _mapTransactionStatusToDomain(status!),
      agreement: agreement?.toDomain(),
    );
  }
}

/// Extensions on the Domain Transaction entity to convert it back to the Amplify model for mutations.
extension TransactionToAmplifyMapper on domain.Transaction {
  amplify_model.Transaction toAmplify() {
    return amplify_model.Transaction(
      id: id,
      paymentMethodType: _mapTransactionPaymentMethodTypeToAmplify(
        paymentMethodType,
      ),
      reference: reference,
      flutterwaveId: flutterwaveId,
      amount: amount,
      cleerFee: cleerFee,
      gatewayFee: gatewayFee,
      currency: currency,
      flutterwavePaymentMethodId: flutterwavePaymentMethodId,
      status: _mapTransactionStatusToAmplify(status),
      agreement: agreement?.toAmplify(),
    );
  }
}

TransactionStatus _mapTransactionStatusToDomain(
  amplify_model.TransactionStatus p,
) {
  switch (p) {
    case amplify_model.TransactionStatus.PENDING:
      return TransactionStatus.pending;
    case amplify_model.TransactionStatus.SUCCESSFUL:
      return TransactionStatus.successful;
    case amplify_model.TransactionStatus.FAILED:
      return TransactionStatus.failed;
    case amplify_model.TransactionStatus.CANCELLED:
      return TransactionStatus.cancelled;
  }
}

amplify_model.TransactionStatus _mapTransactionStatusToAmplify(
  TransactionStatus p,
) {
  switch (p) {
    case TransactionStatus.pending:
      return amplify_model.TransactionStatus.PENDING;
    case TransactionStatus.successful:
      return amplify_model.TransactionStatus.SUCCESSFUL;
    case TransactionStatus.failed:
      return amplify_model.TransactionStatus.FAILED;
    case TransactionStatus.cancelled:
      return amplify_model.TransactionStatus.CANCELLED;
  }
}

PaymentMethodType _mapTransactionPaymentMethodTypeToDomain(
  amplify_model.TransactionPaymentMethodType p,
) {
  switch (p) {
    case amplify_model.TransactionPaymentMethodType.CARD:
      return PaymentMethodType.card;
    case amplify_model.TransactionPaymentMethodType.OPAY:
      return PaymentMethodType.opay;
    case amplify_model.TransactionPaymentMethodType.USSD:
      return PaymentMethodType.ussd;
    case amplify_model.TransactionPaymentMethodType.BANK_TRANSFER:
      return PaymentMethodType.bankTransfer;
  }
}

amplify_model.TransactionPaymentMethodType
_mapTransactionPaymentMethodTypeToAmplify(PaymentMethodType p) {
  switch (p) {
    case PaymentMethodType.card:
      return amplify_model.TransactionPaymentMethodType.CARD;
    case PaymentMethodType.opay:
      return amplify_model.TransactionPaymentMethodType.OPAY;
    case PaymentMethodType.ussd:
      return amplify_model.TransactionPaymentMethodType.USSD;
    case PaymentMethodType.bankTransfer:
      return amplify_model.TransactionPaymentMethodType.BANK_TRANSFER;
  }
}
