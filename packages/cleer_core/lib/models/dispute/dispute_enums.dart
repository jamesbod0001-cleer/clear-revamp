enum DisputeStatus {
  open('OPEN'),
  underReview('UNDER_REVIEW'),
  resolved('RESOLVED'),
  dismissed('DISMISSED');

  final String id;
  const DisputeStatus(this.id);

  static DisputeStatus fromId(String id) {
    return DisputeStatus.values.firstWhere(
      (e) => e.id == id,
      orElse: () => DisputeStatus.open,
    );
  }
}

enum DisputeReasonCategory { products, services, milestones }

enum DisputeReason {
  // Products
  itemNotReceived('item_not_received', DisputeReasonCategory.products),
  itemDamaged('item_damaged', DisputeReasonCategory.products),
  wrongItemReceived('wrong_item_received', DisputeReasonCategory.products),
  itemSignificantlyDifferent('item_significantly_different', DisputeReasonCategory.products),
  deliveryIssue('delivery_issue', DisputeReasonCategory.products),
  productOther('product_other', DisputeReasonCategory.products),

  // Services
  workNotDelivered('work_not_delivered', DisputeReasonCategory.services),
  workIncomplete('work_incomplete', DisputeReasonCategory.services),
  workDoesNotMatch('work_does_not_match', DisputeReasonCategory.services),
  serviceDeadlineMissed('service_deadline_missed', DisputeReasonCategory.services),
  paymentReleasedByMistake('payment_released_by_mistake', DisputeReasonCategory.services),
  serviceOther('service_other', DisputeReasonCategory.services),

  // Milestones
  milestoneNotCompleted('milestone_not_completed', DisputeReasonCategory.milestones),
  milestoneDoesNotMatch('milestone_does_not_match', DisputeReasonCategory.milestones),
  workRequiresRevisions('work_requires_revisions', DisputeReasonCategory.milestones),
  milestoneDeadlineMissed('milestone_deadline_missed', DisputeReasonCategory.milestones),
  milestoneOther('milestone_other', DisputeReasonCategory.milestones);

  final String id;
  final DisputeReasonCategory category;

  const DisputeReason(this.id, this.category);

  static DisputeReason fromId(String id) {
    return DisputeReason.values.firstWhere(
      (e) => e.id == id,
      orElse: () => DisputeReason.productOther,
    );
  }

  static List<DisputeReason> forCategory(DisputeReasonCategory category) {
    return DisputeReason.values.where((r) => r.category == category).toList();
  }
}
