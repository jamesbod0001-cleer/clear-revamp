enum InitiatorRole { sender, recipient }

enum DisbursementType { oneTime, milestones }

enum AgreementCategory {
  physicalGoods(
    'physical_goods',
    'Physical Goods',
    'E.g. Electronics, Fashion, Gadgets, etc.',
  ),
  servicesWork(
    'service_work',
    'Services & Work',
    'E.g. Freelance, Repairs, Consulting, Digital services, etc.',
  );

  final String id;
  final String label;
  final String examples;
  const AgreementCategory(this.id, this.label, this.examples);

  /// Helper to convert string from database back to enum
  static AgreementCategory fromId(String id) {
    return AgreementCategory.values.firstWhere((e) => e.id == id);
  }
}

enum AgreementStatus {
  draft,
  awaitingRecipient,
  awaitingFunding,
  funded,
  inProgress,
  readyForRelease,
  processingRelease,

  cancelled,
  rejected,
  released,
}
