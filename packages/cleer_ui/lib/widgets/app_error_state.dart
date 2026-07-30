import 'package:cleer_ui/cleer_ui.dart';
import 'package:cleer_ui/widgets/buttons/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

enum AppErrorStateVariant { page, card, minimal }

class AppErrorState extends StatelessWidget {
  const AppErrorState({
    super.key,
    required this.isOffline,
    required this.onRetry,
    this.variant = AppErrorStateVariant.page,
    this.title,
    this.subtitle,
    this.retryText,
  });

  final bool isOffline;
  final VoidCallback onRetry;
  final AppErrorStateVariant variant;
  final String? title;
  final String? subtitle;
  final String? retryText;

  @override
  Widget build(BuildContext context) {
    return switch (variant) {
      AppErrorStateVariant.page => _PageError(
          isOffline: isOffline,
          onRetry: onRetry,
          title: title,
          subtitle: subtitle,
          retryText: retryText,
        ),
      AppErrorStateVariant.card => _CardError(
          isOffline: isOffline,
          onRetry: onRetry,
          title: title,
          subtitle: subtitle,
          retryText: retryText,
        ),
      AppErrorStateVariant.minimal => _MinimalError(
          isOffline: isOffline,
          title: title,
          subtitle: subtitle,
        ),
    };
  }
}

class _PageError extends StatelessWidget {
  const _PageError({
    required this.isOffline,
    required this.onRetry,
    this.title,
    this.subtitle,
    this.retryText,
  });

  final bool isOffline;
  final VoidCallback onRetry;
  final String? title;
  final String? subtitle;
  final String? retryText;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: Dimens.of(context).edgeInsetsScreenHorizontal,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PhosphorIcon(
              isOffline ? PhosphorIcons.wifiSlash() : PhosphorIcons.warningCircle(),
              size: Dimens.size.s80,
              color: context.color.grey600,
            ),
            Gap(Dimens.spacing.sp24),
            if (title != null) ...[
              Text(
                title!,
                textAlign: TextAlign.center,
                style: context.typo.headlineSmall,
              ),
              Gap(Dimens.spacing.sp8),
            ],
            Text(
              subtitle ?? '',
              textAlign: TextAlign.center,
              style: context.typo.bodyMedium.copyWith(
                color: context.color.grey800,
              ),
            ),
            Gap(Dimens.spacing.sp32),
            SizedBox(
              width: 160,
              child: PrimaryButton(
                onPressed: onRetry,
                child: Text(retryText ?? 'Retry'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardError extends StatelessWidget {
  const _CardError({
    required this.isOffline,
    required this.onRetry,
    this.title,
    this.subtitle,
    this.retryText,
  });

  final bool isOffline;
  final VoidCallback onRetry;
  final String? title;
  final String? subtitle;
  final String? retryText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Dimens.padding.p16),
      decoration: BoxDecoration(
        color: context.color.grey50,
        borderRadius: BorderRadius.circular(Dimens.radius.r12),
        border: Border.all(color: context.color.outline),
      ),
      child: Row(
        children: [
          PhosphorIcon(
            isOffline ? PhosphorIcons.wifiSlash() : PhosphorIcons.warningCircle(),
            color: context.color.grey800,
          ),
          Gap(Dimens.spacing.sp12),
          Expanded(
            child: Text(
              subtitle ?? title ?? '',
              style: context.typo.bodyMedium.copyWith(
                color: context.color.grey800,
              ),
            ),
          ),
          Gap(Dimens.spacing.sp12),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: Dimens.padding.p12,
                vertical: Dimens.padding.p8,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimens.radius.r32),
                side: BorderSide(color: context.color.outline),
              ),
            ),
            child: Text(
              retryText ?? 'Refresh',
              style: context.typo.bodySmall.copyWith(
                color: context.color.blue700,
                fontWeight: AppFontWeights.semiBold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MinimalError extends StatelessWidget {
  const _MinimalError({
    required this.isOffline,
    this.title,
    this.subtitle,
  });

  final bool isOffline;
  final String? title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PhosphorIcon(
          isOffline ? PhosphorIcons.wifiSlash() : PhosphorIcons.warningCircle(),
          color: context.color.grey800,
          size: Dimens.size.s20,
        ),
        Gap(Dimens.spacing.sp12),
        Expanded(
          child: Text(
            subtitle ?? title ?? '',
            style: context.typo.bodyMedium.copyWith(
              color: context.color.grey800,
            ),
          ),
        ),
      ],
    );
  }
}
