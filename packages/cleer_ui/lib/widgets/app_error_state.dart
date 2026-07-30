import 'package:cleer_ui/cleer_ui.dart';
import 'package:cleer_ui/generated/assets.gen.dart';
import 'package:cleer_ui/l10n/generated/ui_localizations.dart';
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
    this.message,
    this.retryText,
  });

  final bool isOffline;
  final VoidCallback onRetry;
  final AppErrorStateVariant variant;
  final String? message;
  final String? retryText;

  @override
  Widget build(BuildContext context) {
    return switch (variant) {
      AppErrorStateVariant.page => _PageError(
        isOffline: isOffline,
        onRetry: onRetry,
        message: message,
        retryText: retryText,
      ),
      AppErrorStateVariant.card => _CardError(
        isOffline: isOffline,
        onRetry: onRetry,
        message: message,
      ),
      AppErrorStateVariant.minimal => _MinimalError(
        isOffline: isOffline,
        message: message,
      ),
    };
  }
}

class _PageError extends StatelessWidget {
  const _PageError({
    required this.isOffline,
    required this.onRetry,
    this.message,
    this.retryText,
  });

  final bool isOffline;
  final VoidCallback onRetry;
  final String? message;
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
              isOffline
                  ? PhosphorIcons.cloudSlash(.bold)
                  : PhosphorIcons.warningCircle(),
              size: Dimens.size.s64,
              color: context.color.grey600,
            ),
            Gap(Dimens.spacing.sp8),
            Text(
              message ?? '',
              textAlign: TextAlign.center,
              style: context.typo.bodyLarge.copyWith(
                color: context.color.grey600,
              ),
            ),
            Gap(Dimens.spacing.sp24),
            PrimaryButton(
              onPressed: onRetry,
              minimumSize: Size(Dimens.size.s126, Dimens.size.s40),
              padding: .symmetric(vertical: Dimens.padding.p12),
              child: Text(retryText ?? UiLocalizations.of(context)!.retry),
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
    this.message,
  });

  final bool isOffline;
  final VoidCallback onRetry;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.padding.p12,
        vertical: Dimens.padding.p16,
      ),
      decoration: BoxDecoration(
        color: context.color.grayComponent,
        borderRadius: BorderRadius.circular(Dimens.radius.r8),
        border: Border.all(color: context.color.outline),
      ),
      child: Row(
        children: [
          PhosphorIcon(
            isOffline
                ? PhosphorIcons.cloudSlash(.bold)
                : PhosphorIcons.warningCircle(),
            color: context.color.grey800,
            size: Dimens.size.s24,
          ),
          Gap(Dimens.spacing.sp12),
          Expanded(
            child: Text(
              message ?? '',
              style: context.typo.bodyMedium.copyWith(
                fontWeight: AppFontWeights.regular,
                color: context.color.grey800,
              ),
            ),
          ),
          Gap(Dimens.spacing.sp8),
          GestureDetector(
            onTap: onRetry,
            child: Assets.images.refreshButton.image(
              height: Dimens.size.s26,
              frameBuilder:
                  (context, frameChild, frame, wasSynchronouslyLoaded) {
                    if (wasSynchronouslyLoaded || frame != null) {
                      return frameChild;
                    }
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: .circular(Dimens.radius.r40),
                        border: Border.all(
                          color: context.color.blue800.withValues(alpha: .40),
                        ),
                      ),
                      padding: .symmetric(
                        horizontal: Dimens.padding.p10,
                        vertical: Dimens.padding.p6,
                      ),
                      child: Text(
                        UiLocalizations.of(context)!.refresh,
                        style: context.typo.bodyMedium.copyWith(
                          height: 1,
                          color: context.color.blue800,
                        ),
                      ),
                    );
                  },
            ),
          ),
        ],
      ),
    );
  }
}

class _MinimalError extends StatelessWidget {
  const _MinimalError({required this.isOffline, this.message});

  final bool isOffline;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PhosphorIcon(
          isOffline
              ? PhosphorIcons.cloudSlash(.bold)
              : PhosphorIcons.warningCircle(),
          color: context.color.grey800,
          size: Dimens.size.s24,
        ),
        Gap(Dimens.spacing.sp12),
        Expanded(
          child: Text(
            message ?? '',
            style: context.typo.bodyMedium.copyWith(
              fontWeight: AppFontWeights.regular,
              color: context.color.grey800,
            ),
          ),
        ),
      ],
    );
  }
}
