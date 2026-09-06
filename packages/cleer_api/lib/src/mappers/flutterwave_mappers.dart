import 'package:cleer_api/src/services/api/models/flutterwave/responses/bank/bank_response.dart';
import 'package:cleer_api/src/services/api/models/flutterwave/responses/charge/charge_response.dart';
import 'package:cleer_api/src/services/api/models/flutterwave/responses/customer/customer_response.dart';
import 'package:cleer_api/src/services/api/models/flutterwave/responses/payment_method/payment_method_response.dart';
import 'package:cleer_api/src/services/api/models/flutterwave/responses/virtual_account/virtual_account_response.dart';
import 'package:cleer_core/models/customer/customer.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:cleer_core/models/payment_method/payment_method.dart';
import 'package:cleer_core/models/virtual_account/virtual_account.dart';

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
          id: id ?? '',
          type: .card,
          cardDetails: CardDetails(
            first6: card?.first6 ?? '',
            last4: card?.last4 ?? '',
            network: mapToCardNetwork(card?.network),
            expiryMonth: card?.expiryMonth ?? 0,
            expiryYear: card?.expiryYear ?? 0,
          ),
          createdAt: createdDatetime,
        );
      case 'opay':
        return PaymentMethod(id: id ?? '', type: .opay, createdAt: createdDatetime);
      case 'ussd':
        return PaymentMethod(
          id: id ?? '',
          type: .ussd,
          ussdDetails: USSDDetails(accountBankCode: ussd?.accountBank ?? ''),
          createdAt: createdDatetime,
        );
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
      id: id ?? '',
      accountNumber: accountNumber ?? '',
      bankName: accountBankName ?? '',
      accountType: mapToVirtualAccountType(accountType!),
      amount: amount ?? 0,
      reference: reference ?? '',
      note: note ?? '',
      expiresAt: accountExpirationDatetime,
      createdAt: createdDatetime!,
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

extension ChargeResponseMapper on ChargeResponse {
  Charge toDomain(String fallbackAgreementId) {
    return Charge(
      id: id ?? '',
      agreementId: (meta?['cleer_agreement_id'] ?? meta?['cleerAgreementId'] ?? meta?['agreement_id']) as String? ?? fallbackAgreementId,
      reference: reference ?? '',
      amount: amount ?? 0.0,
      currency: currency ?? 'NGN',
      status: _mapToChargeStatus(status),
      action: _mapToChargeAction(nextAction),
      customerId: customerId,
      createdAt: createdDatetime,
      feeBreakdown: fees
          ?.map(
            (fee) => ChargeFee(
              type: ChargeFeeType.fromValue(fee.type),
              amount: fee.amount ?? 0,
            ),
          )
          .toList(),
    );
  }
}

ChargeStatus _mapToChargeStatus(String? status) {
  switch (status?.toLowerCase()) {
    case 'succeeded':
      return ChargeStatus.succeeded;
    case 'pending':
      return ChargeStatus.pending;
    case 'failed':
      return ChargeStatus.failed;
    case 'voided':
      return ChargeStatus.voided;
    default:
      return ChargeStatus.unknown;
  }
}

ChargeAction _mapToChargeAction(
  NextActionObject? next,
  // , String? rootRedirect
) {
  if (next != null) {
    switch (next.type) {
      case 'redirect_url':
        return ChargeAction.redirect(next.redirectUrl?.url ?? '');
      case 'requires_otp':
        return const ChargeAction.otp();
      case 'requires_pin':
        return const ChargeAction.pin();
      case 'requires_bank_transfer':
        return ChargeAction.bankTransfer(
          accountNumber: next.requiresBankTransfer?.accountNumber ?? '',
          bankName: next.requiresBankTransfer?.accountBankName ?? '',
          expiry: next.requiresBankTransfer?.accountExpirationDatetime,
        );
      case 'qr_code':
        return ChargeAction.qrCode(next.qrCode?.image ?? '');
      case 'payment_instruction':
        return ChargeAction.displayInstruction(
          next.paymentInstruction?.note ?? '',
        );
      default:
        return const ChargeAction.none();
    }
  }

  // if (rootRedirect != null && rootRedirect.isNotEmpty) {
  //   // Optional: Only return if it doesn't match your cleer:// callback
  //   return ChargeAction.redirect(rootRedirect);
  // }

  return const ChargeAction.none();
}
