import 'package:cleer/config/assets.gen.dart';
import 'package:cleer/domain/providers/activity/activity_provider.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_core/models/activity/activity.dart';
import 'package:cleer_core/models/paginated_list/paginated_list.dart';
import 'package:cleer_ui/cleer_ui.dart';
import 'package:cleer_ui/widgets/app_empty_state.dart';
import 'package:cleer_ui/widgets/buttons/app_back_button.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class ActivityTimelineScreen extends ConsumerWidget {
  const ActivityTimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final activitiesState = ref.watch(userActivitiesProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: Dimens.padding.p18,
        titleTextStyle: context.typo.headlineSmall,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(Dimens.spacing.sp12),
            const AppBackButton(),
            Gap(Dimens.spacing.sp24),
            Text(l10n.activityTimeline),
          ],
        ),
        toolbarHeight: 102,
      ),
      body: activitiesState.when(
        skipLoadingOnReload: true,
        data: (PaginatedList<Activity> activities) {
          if (activities.items.isEmpty) {
            return Column(
              children: [
                const Spacer(flex: 221),
                Padding(
                  padding: Dimens.mobile.edgeInsetsScreenHorizontal,
                  child: AppEmptyState(
                    icon: Assets.icons.rewindTimeOff.svg(
                      width: Dimens.size.s80,
                      height: Dimens.size.s80,
                      colorFilter: ColorFilter.mode(
                        context.color.blue1000,
                        BlendMode.srcIn,
                      ),
                    ),
                    title: l10n.noActivityYet,
                    subtitle: Padding(
                      padding: .symmetric(horizontal: Dimens.padding.p40),
                      child: Text(
                        l10n.whenYouCreateAgreementsOrSecurePaymentsYourActivityHistoryWillAppearHere,
                        textAlign: .center,
                        style: context.typo.bodySmall.copyWith(
                          color: context.color.grey800,
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(flex: 279),
              ],
            );
          }

          final groupedActivities = _groupActivitiesByDate(activities.items);

          return NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent - 200) {
                ref.read(userActivitiesProvider.notifier).loadMore();
              }
              return false;
            },
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: Dimens.mobile.edgeInsetsScreenHorizontal.copyWith(
                    top: Dimens.padding.p36,
                    bottom: Dimens.padding.p20,
                  ),
                  sliver: MultiSliver(
                    children: [
                      ..._buildGroupedSlivers(context, groupedActivities),

                      if (activitiesState.value?.hasNextPage == true)
                        SliverToBoxAdapter(
                          child: ActivityCardSkeletonList(itemCount: 2),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        error: (Object error, StackTrace stackTrace) {
          /// TODO: Add proper error state here
          return SizedBox.shrink();
        },
        loading: () => Padding(
          padding: Dimens.mobile.edgeInsetsScreenHorizontal.copyWith(
            top: Dimens.padding.p36,
          ),
          child: ActivityCardSkeletonList(),
        ),
      ),
    );
  }

  // --- HELPER METHODS ---

  /// Groups a flat list of activities into a Map where the Key is the
  /// date header (e.g., "Today", "Yesterday") and the Value is the list of activities.
  Map<String, List<Activity>> _groupActivitiesByDate(
    List<Activity> activities,
  ) {
    final Map<String, List<Activity>> grouped = {};

    for (final activity in activities) {
      final header = _getDateHeader(activity.createdAt);
      grouped.putIfAbsent(header, () => []).add(activity);
    }

    return grouped;
  }

  /// Determines the string to use for the section header
  String _getDateHeader(DateTime? date) {
    if (date == null) return 'Unknown';

    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final activityMidnight = DateTime(date.year, date.month, date.day);
    final daysDifference = todayMidnight.difference(activityMidnight).inDays;

    if (daysDifference == 0) return 'Today';
    if (daysDifference == 1) return 'Yesterday';
    if (now.year == date.year) {
      return DateFormat('MMM d').format(date); // e.g., "Oct 12"
    }
    return DateFormat('MMM d, yyyy').format(date); // e.g., "Oct 12, 2023"
  }

  /// Builds the UI elements (Headers and Lists) for the CustomScrollView
  List<Widget> _buildGroupedSlivers(
    BuildContext context,
    Map<String, List<Activity>> groupedActivities,
  ) {
    final List<Widget> slivers = [];

    for (final entry in groupedActivities.entries) {
      final groupName = entry.key;
      final groupItems = entry.value;

      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(
              top: slivers.isEmpty ? 0 : Dimens.padding.p40,
              bottom: Dimens.padding.p16,
            ),
            child: Text(
              groupName,
              style: context.typo.titleSmall.copyWith(
                color: context.color.grey600,
              ),
            ),
          ),
        ),
      );

      slivers.add(
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            return Padding(
              padding: EdgeInsets.only(bottom: Dimens.padding.p28),
              child: ActivityCard(activity: groupItems[index]),
            );
          }, childCount: groupItems.length),
        ),
      );
    }

    return slivers;
  }
}

/// A simple helper widget to combine multiple Slivers into a single Sliver context.
/// (If you are using the `sliver_tools` package, you can use their `MultiSliver`.
/// Otherwise, you can just return the raw list directly into the `slivers` array of CustomScrollView).
class MultiSliver extends StatelessWidget {
  final List<Widget> children;
  const MultiSliver({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(slivers: children);
  }
}
