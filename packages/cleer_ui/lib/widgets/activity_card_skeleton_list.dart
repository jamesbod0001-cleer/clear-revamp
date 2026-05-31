
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < itemCount; i++) ...[
            ActivityCard(
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
            ),
            if (i < itemCount - 1) Gap(Dimens.spacing.sp28),
          ],
        ],
      ),
    );
  }
}