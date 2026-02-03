import 'package:cleer/data/services/flutterwave/responses/bank/bank_response.dart';
import 'package:cleer/data/services/flutterwave/responses/customer/customer_response.dart';
import 'package:cleer/domain/models/bank/bank.dart';
import 'package:cleer/domain/models/customer/customer.dart';

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
