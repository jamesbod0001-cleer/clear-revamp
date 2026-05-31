
import 'package:cleer_core/models/activity/activity.dart';
import 'package:cleer_core/models/activity/activity_enums.dart';
import 'package:cleer_ui/themes/dimensions.dart';
import 'package:cleer_ui/widgets/activity_card.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ActivityCardSkeletonList extends StatelessWidget {
  const ActivityCardSkeletonList({
    super.key,
    this.itemCount = 4,
    this.showDayContext = false,
  });

  final int itemCount;
  final bool showDayContext;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: .zero,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return ActivityCard(
            showDayContext: showDayContext,
            activity: Activity(
              userId: '',
              type: ActivityType.agreement,
              heading: BoneMock.title,
              supportingText: BoneMock.subtitle,
              formattedAmount: BoneMock.words(1),
              description: BoneMock.words(4),
              createdAt: DateTime.now(),
            ),
          );
        },
        separatorBuilder: (context, index) => Gap(Dimens.spacing.sp28),
      ),
    );
  }
}