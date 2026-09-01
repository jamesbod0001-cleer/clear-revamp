enum ChargeStatus { succeeded, pending, failed, voided, unknown }

enum ChargeFeeType {
  vat('vat', 'VAT'),
  app('app', 'App Fee'),
  merchant('merchant', 'Merchant Fee'),
  stampDuty('stamp_duty', 'Stamp Duty'),
  unknown('unknown', 'Fee');

  final String value;
  final String label;

  const ChargeFeeType(this.value, this.label);

  static ChargeFeeType fromValue(String? type) {
    if (type == null) return ChargeFeeType.unknown;
    return switch (type.toLowerCase()) {
      'vat' => ChargeFeeType.vat,
      'app' => ChargeFeeType.app,
      'merchant' => ChargeFeeType.merchant,
      'stamp_duty' => ChargeFeeType.stampDuty,
      _ => ChargeFeeType.unknown,
    };
  }
}
