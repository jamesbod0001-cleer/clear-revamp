import 'package:cleer/data/services/flutterwave/responses/bank/bank_response.dart';
import 'package:cleer/data/services/flutterwave/responses/customer/customer_response.dart';
import 'package:cleer/data/services/flutterwave/responses/payment_method/payment_method_response.dart';
import 'package:cleer/data/services/flutterwave/responses/virtual_account/virtual_account_response.dart';
import 'package:cleer/domain/models/bank/bank.dart';
import 'package:cleer/domain/models/customer/customer.dart';
import 'package:cleer/domain/models/enums/card_network.dart';
import 'package:cleer/domain/models/enums/virtual_account_type.dart';
import 'package:cleer/domain/models/payment_method/payment_method.dart';
import 'package:cleer/domain/models/virtual_account/virtual_account.dart';

extension BankResponseMapper on BankResponse {
  Bank toDomain() => Bank(id: id, code: code, name: name);
}

extension CustomerResponseMapper on CustomerResponse {
  Customer toDomain(String fallbackUserId) => Customer(
    id: id,
    cleerId: meta?['cleer_id'] as String? ?? fallbackUserId,
    firstName: name.first,
    lastName: name.last,
    phoneNumber: phone.number,
  );
}

extension PaymentMethodResponseMapper on PaymentMethodResponse {
  PaymentMethod toDomain() {
    switch (type) {
      case 'card':
        return PaymentMethod(
          id: id,
          type: .card,
          cardDetails: CardDetails(
            last4: card!.last4,
            network: mapToCardNetwork(card!.network),
            expiryMonth: card!.expiryMonth,
            expiryYear: card!.expiryYear,
          ),
          createdAt: createdDatetime,
        );
      case 'opay':
        return PaymentMethod(id: id, type: .opay, createdAt: createdDatetime);
      default:
        throw Exception('Unknown payment method type: $type');
    }
  }
}

CardNetwork mapToCardNetwork(String? network) {
  if (network == null) return CardNetwork.unknown;

  return switch (network.toUpperCase()) {
    'MASTERCARD' => CardNetwork.mastercard,
    'VISA' => CardNetwork.visa,
    'AMERICAN EXPRESS' => CardNetwork.americanExpress,
    'DISCOVER' => CardNetwork.discover,
    'VERVE' => CardNetwork.verve,
    'AFRIGO' => CardNetwork.afrigo,
    _ => CardNetwork.unknown,
  };
}

extension VirtualAccountResponseMapper on VirtualAccountResponse {
  VirtualAccount toDomain() {
    return VirtualAccount(
      id: id,
      accountNumber: accountNumber,
      bankName: accountBankName,
      accountType: mapToVirtualAccountType(accountType),
      amount: amount,
      reference: reference,
      note: note,
      expiresAt: accountExpirationDatetime,
      createdAt: createdDatetime,
    );
  }
}

VirtualAccountType mapToVirtualAccountType(String accountType) {
  return switch (accountType) {
    'dynamic' => VirtualAccountType.dynamic,
    'static' => VirtualAccountType.static,
    _ => throw Exception('Unknown virtual account type: $accountType'),
  };
}
