import 'package:cleer/domain/providers/storage/file_url_provider.dart';
import 'package:cleer/domain/providers/user/user_provider.dart';
import 'package:cleer/ui/agreements/extensions/agreement_ui_extensions.dart';
import 'package:cleer/ui/core/extensions/file_extensions.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:cleer_ui/cleer_ui.dart';
import 'package:cleer_ui/widgets/images/app_image.dart';
import 'package:cleer_ui/widgets/images/blur_hash_widget.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

class DisputeReportCard extends ConsumerWidget {
  const DisputeReportCard({super.key, required this.dispute});

  final Dispute dispute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final user = ref.watch(userProfileProvider).value;
    final reporter = dispute.raisedBy;
    final firstName = reporter?.firstName ?? '';
    final lastName = reporter?.lastName ?? '';
    final initials =
        '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'
            .toUpperCase();

    final formattedDate = dispute.createdAt != null
        ? DateFormat('d MMM, h:mm a').format(dispute.createdAt!)
        : '';

    final evidenceKeys = dispute.evidenceKeys ?? [];

    return Container(
      padding: EdgeInsets.all(Dimens.padding.p16),
      decoration: BoxDecoration(
        color: context.color.outline,
        borderRadius: BorderRadius.circular(Dimens.radius.r8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Skeleton.leaf(
                child: Container(
                  width: Dimens.size.s44,
                  height: Dimens.size.s44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.color.grayComponent,
                  ),
                  child: ClipOval(
                    child: Builder(
                      builder: (BuildContext context) {
                        if (reporter?.profilePicture == null) {
                          return Material(
                            color: const Color(0xFFF97316),
                            child: Center(
                              child: Text(
                                initials,
                                style: context.typo.titleMedium.copyWith(
                                  color: context.color.white,
                                ),
                              ),
                            ),
                          );
                        }
                        final profileUrlAsync = ref.watch(
                          fileUrlProvider(reporter!.profilePicture!.key),
                        );
                        return profileUrlAsync.when(
                          data: (url) => AppImage(
                            imageUrl: url,
                            blurHash: reporter.profilePicture!.blurHash ?? '',
                            fit: BoxFit.cover,
                          ),
                          loading: () => BlurHashWidget(
                            hash: reporter.profilePicture!.blurHash ?? '',
                          ),
                          error: (_, _) => Center(
                            child: PhosphorIcon(PhosphorIcons.imageBroken()),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Gap(Dimens.spacing.sp12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reporter?.id == user?.id
                        ? l10n.yourReport
                        : l10n.usersReport(firstName.isNotEmpty ? firstName : 'User'),
                    style: context.typo.labelMedium,
                  ),
                  if (formattedDate.isNotEmpty)
                    Text(
                      formattedDate,
                      style: context.typo.bodySmall.copyWith(
                        color: context.color.grey600,
                      ),
                    ),
                ],
              ),
            ],
          ),
          Gap(Dimens.spacing.sp20),
          Text(
            l10n.reasonWithLabel(dispute.reason.getLabel(context)),
            style: context.typo.bodyMedium.copyWith(
              color: context.color.grey800,
            ),
          ),
          Gap(Dimens.spacing.sp12),
          Text(
            '"${dispute.description}"',
            style: context.typo.bodyMedium.copyWith(
              fontWeight: AppFontWeights.regular,
              color: context.color.grey800,
            ),
          ),
          if (evidenceKeys.isNotEmpty) ...[
            Gap(Dimens.spacing.sp12),
            LayoutBuilder(
              builder: (context, constraints) {
                final dimension =
                    (constraints.maxWidth - (Dimens.spacing.sp8 * 3)) / 4;
                return Wrap(
                  spacing: Dimens.spacing.sp8,
                  runSpacing: Dimens.spacing.sp8,
                  children: evidenceKeys.map((key) {
                    return EvidenceTileCard(
                      s3Key: key,
                      dimension: dimension,
                    );
                  }).toList(),
                );
              },
            ),
          ],
          Gap(Dimens.spacing.sp12),
          Skeleton.leaf(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: Dimens.padding.p8,
                vertical: Dimens.padding.p3,
              ),
              decoration: BoxDecoration(
                color: context.color.successLight,
                borderRadius: BorderRadius.circular(Dimens.radius.r100),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PhosphorIcon(
                    PhosphorIcons.eye(.bold),
                    size: Dimens.size.s14,
                    color: context.color.success,
                  ),
                  Gap(Dimens.spacing.sp8),
                  Text(
                    l10n.visibleToBothParties,
                    style: context.typo.bodySmall.copyWith(
                      color: context.color.success,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EvidenceTileCard extends ConsumerWidget {
  const EvidenceTileCard({
    super.key,
    required this.s3Key,
    required this.dimension,
  });

  final String s3Key;
  final double dimension;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fileType = s3Key.fileType;
    final urlState = ref.watch(fileUrlProvider(s3Key));

    return InkWell(
      onTap: () async {
        final url = urlState.value;
        if (url != null && url.isNotEmpty) {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
      },
      borderRadius: BorderRadius.circular(Dimens.radius.r10),
      child: Skeleton.leaf(
        child: Container(
          width: dimension,
          height: dimension,
          decoration: BoxDecoration(
            color: _getBackgroundColor(context, fileType),
            borderRadius: BorderRadius.circular(Dimens.radius.r10),
            border: Border.all(color: context.color.grayComponent),
          ),
          clipBehavior: Clip.antiAlias,
          child: _buildTileContent(context, fileType, urlState),
        ),
      ),
    );
  }

  Color _getBackgroundColor(BuildContext context, EvidenceFileType fileType) {
    switch (fileType) {
      case EvidenceFileType.pdf:
        return context.color.errorLight;
      case EvidenceFileType.doc:
        return context.color.infoLight;
      case EvidenceFileType.video:
        return const Color(0xFF1E293B);
      case EvidenceFileType.image:
      case EvidenceFileType.unknown:
        return context.color.grey200;
    }
  }

  Widget _buildTileContent(
    BuildContext context,
    EvidenceFileType fileType,
    AsyncValue<String> urlState,
  ) {
    switch (fileType) {
      case EvidenceFileType.image:
        return urlState.when(
          data: (url) {
            if (url.isEmpty) {
              return Center(
                child: PhosphorIcon(
                  PhosphorIcons.image(),
                  color: context.color.grey600,
                  size: Dimens.size.s24,
                ),
              );
            }
            return Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Center(
                child: PhosphorIcon(
                  PhosphorIcons.imageBroken(),
                  color: context.color.grey600,
                  size: Dimens.size.s24,
                ),
              ),
            );
          },
          loading: () => Center(
            child: SizedBox.square(
              dimension: Dimens.size.s16,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          error: (_, _) => Center(
            child: PhosphorIcon(
              PhosphorIcons.imageBroken(),
              color: context.color.grey600,
              size: Dimens.size.s24,
            ),
          ),
        );

      case EvidenceFileType.pdf:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PhosphorIcon(
              PhosphorIcons.filePdf(),
              color: context.color.error,
              size: Dimens.size.s28,
            ),
            Gap(Dimens.spacing.sp2),
            Text(
              'PDF',
              style: context.typo.labelSmall.copyWith(
                color: context.color.error,
                fontWeight: AppFontWeights.bold,
              ),
            ),
          ],
        );

      case EvidenceFileType.doc:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PhosphorIcon(
              PhosphorIcons.fileDoc(),
              color: context.color.blue700,
              size: Dimens.size.s28,
            ),
            Gap(Dimens.spacing.sp2),
            Text(
              'DOC',
              style: context.typo.labelSmall.copyWith(
                color: context.color.blue700,
                fontWeight: AppFontWeights.bold,
              ),
            ),
          ],
        );

      case EvidenceFileType.video:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PhosphorIcon(
              PhosphorIcons.playCircle(PhosphorIconsStyle.fill),
              color: Colors.white,
              size: Dimens.size.s28,
            ),
            Gap(Dimens.spacing.sp2),
            Text(
              'VIDEO',
              style: context.typo.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: AppFontWeights.bold,
              ),
            ),
          ],
        );

      case EvidenceFileType.unknown:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PhosphorIcon(
              PhosphorIcons.file(),
              color: context.color.grey600,
              size: Dimens.size.s28,
            ),
            Gap(Dimens.spacing.sp2),
            Text(
              'FILE',
              style: context.typo.labelSmall.copyWith(
                color: context.color.grey600,
                fontWeight: AppFontWeights.bold,
              ),
            ),
          ],
        );
    }
  }
}
