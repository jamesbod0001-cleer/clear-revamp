import 'package:freezed_annotation/freezed_annotation.dart';

part 'charge_filter.g.dart';

@JsonSerializable(includeIfNull: false)
class ChargeFilter {
  final String? status;
  final String? reference;
  final DateTime? to;
  final DateTime? from;
  @JsonKey(name: 'customer_id')
  final String? customerId;
  @JsonKey(name: 'virtual_account_id')
  final String? virtualAccountId;
  @JsonKey(name: 'payment_method_id')
  final String? paymentMethodId;
  @JsonKey(name: 'order_id')
  final String? orderId;
  final int page;
  final int size;

  ChargeFilter({
    this.status,
    this.reference,
    this.to,
    this.from,
    this.customerId,
    this.virtualAccountId,
    this.paymentMethodId,
    this.orderId,
    this.page = 1,
    this.size = 10,
  });

  Map<String, dynamic> toJson() => _$ChargeFilterToJson(this);

  static ChargeFilter fromJson(Map<String, dynamic> json) =>
      _$ChargeFilterFromJson(json);
}
