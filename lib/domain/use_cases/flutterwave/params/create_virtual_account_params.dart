import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_virtual_account_params.freezed.dart';

@freezed
abstract class CreateVirtualAccountParams with _$CreateVirtualAccountParams {
  /// Use for one-time escrow funding
  const factory CreateVirtualAccountParams.dynamic({
    required String reference,
    required String customerId,
    required double amount,
    int? expiry,
    String? narration,
    String? merchantVatAmount,
    Map<String, dynamic>? meta,
  }) = _DynamicParams;

  /// Use for permanent user accounts
  @Assert('bvn != null || nin != null', 'Either bvn or nin must be provided')
  const factory CreateVirtualAccountParams.static({
    required String reference,
    required String customerId,
    String? bvn,
    String? nin,
    String? narration,
    String? merchantVatAmount,
    Map<String, dynamic>? meta,
  }) = _StaticParams;
}