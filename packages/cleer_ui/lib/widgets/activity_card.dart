import 'package:cleer_core/cleer_core.dart';
import 'package:cleer_ui/cleer_ui.dart';
import 'package:cleer_ui/generated/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ActivityCard extends StatelessWidget {
  const ActivityCard({
    super.key,
    required this.activity,
    this.showDayContext = false,
  });
  final Activity activity;
  final bool showDayContext;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Skeleton.leaf(child: _buildAvatar(context)),
        Gap(Dimens.spacing.sp10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: Dimens.spacing.sp2,
            children: [
              Text(
                activity.heading,
                style: context.typo.bodySmall.copyWith(
                  color: context.color.grey800,
                ),
              ),
              Text(
                activity.supportingText,
                style: context.typo.bodyMedium.copyWith(
                  color: context.color.grey800,
                  fontWeight: AppFontWeights.regular,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              _buildFooter(context),
              if (context.isMobile)
                Text(
                  formatTime(activity.createdAt),
                  style: context.typo.bodySmall.copyWith(
                    color: context.color.grey600,
                  ),
                ),
            ],
          ),
        ),
        if (context.isAtLeastTablet) ...[
          Gap(Dimens.spacing.sp24),
          Text(
            formatTime(activity.createdAt),
            style: context.typo.bodySmall.copyWith(
              color: context.color.grey600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAvatar(BuildContext context) {
    late Color color;
    late Widget icon;

    switch (activity.type) {
      case ActivityType.agreement:
        color = context.color.infoLight;
        icon = Assets.images.handshake.image(
          height: Dimens.size.s18,
          width: Dimens.size.s28,
        );
      case ActivityType.payment:
        color = context.color.successLight;
        icon = PhosphorIcon(
          PhosphorIcons.moneyWavy(PhosphorIconsStyle.duotone),
          color: context.color.success,
          size: Dimens.size.s24,
        );
      case ActivityType.delivery:
        color = Color(0xFFFDF0E1);
        icon = PhosphorIcon(
          PhosphorIcons.truck(PhosphorIconsStyle.duotone),
          color: context.color.warning,
          size: Dimens.size.s24,
        );
    }

    return Container(
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: SizedBox.square(
        dimension: Dimens.size.s48,
        child: Center(child: icon),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    // Only show if there is at least one piece of info
    if (activity.formattedAmount == null && activity.description == null) {
      return const SizedBox.shrink();
    }

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: context.typo.bodyMedium.copyWith(color: context.color.grey600),
        children: [
          if (activity.formattedAmount != null)
            TextSpan(
              text: activity.formattedAmount,
              style: TextStyle(color: context.color.grey1000),
            ),
          if (activity.formattedAmount != null && activity.description != null)
            const TextSpan(text: ' · '),
          if (activity.description != null)
            TextSpan(text: activity.description),
        ],
      ),
    );
  }

  String formatTime(DateTime? date) {
    if (date == null) return '';

    final now = DateTime.now();
    final difference = now.difference(date);
    final timeString = DateFormat.jm().format(date); // e.g., '10:53 AM'

    // 1. Less than 60 minutes ago -> "X mins ago" (Used in BOTH modes)
    if (difference.inMinutes < 60 &&
        difference.inHours == 0 &&
        now.day == date.day) {
      if (difference.inMinutes < 1) return 'Just now';
      return '${difference.inMinutes} mins ago';
    }

    // 2. If it's in the Timeline (showDayContext == false), just return the time!
    if (!showDayContext) {
      return timeString;
    }

    // 3. If it's on the HomeScreen (showDayContext == true), calculate and add the day
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final activityMidnight = DateTime(date.year, date.month, date.day);
    final daysDifference = todayMidnight.difference(activityMidnight).inDays;

    if (daysDifference == 0) {
      return 'Today, $timeString';
    } else if (daysDifference == 1) {
      return 'Yesterday, $timeString';
    } else if (daysDifference < 7) {
      final weekdayString = DateFormat('EEEE').format(date);
      return '$weekdayString, $timeString';
    } else if (now.year == date.year) {
      return '${DateFormat('MMM d').format(date)}, $timeString';
    } else {
      return '${DateFormat('MMM d, yyyy').format(date)}, $timeString';
    }
  }
}
