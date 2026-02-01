enum InitiatorRole { sender, recipient }

enum DisbursementType { oneTime, milestones }

enum AgreementCategory {
  physicalGoods(
    'Physical Goods',
    'Electronics, Fashion, Wigs, Gadgets, etc.',
  ),
  servicesWork(
    'Services & Work',
    'Freelance, Repairs, Consulting, Digital services, etc.',
  );

  final String label;
  final String examples;
  const AgreementCategory(this.label, this.examples);

  /// Helper to convert string from database back to enum
  static AgreementCategory? fromName(String? name) {
    return AgreementCategory.values.firstWhere(
          (e) => e.name == name,
      orElse: () => AgreementCategory.physicalGoods,
    );
  }
}
