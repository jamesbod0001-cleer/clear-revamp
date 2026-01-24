import 'package:cleer/data/services/flutterwave/responses/bank/bank_response.dart';
import 'package:cleer/domain/models/bank/bank.dart';

extension BankResponseMapper on BankResponse {
  Bank toDomain() => Bank(id: id, code: code, name: name);
}
