import 'package:cleer/config/assets.gen.dart';
import 'package:cleer/routing/routes.dart';
import 'package:cleer/ui/agreements/create_agreement/models/agreement_type.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_ui/cleer_ui.dart';
import 'package:cleer_ui/widgets/buttons/primary_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AgreementNumpadOverlay extends HookWidget {
  const AgreementNumpadOverlay({
    super.key,
    required this.initialAmount,
    required this.type,
    required this.onSubmitted,
    this.isAutomaticallyOpened = false,
  });

  final String initialAmount;
  final AgreementType type;
  final Function(String) onSubmitted;

  final bool isAutomaticallyOpened;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final amountText = useState(initialAmount.isEmpty ? '0' : initialAmount);
    final double minimumAmount = 1500;

    void handleTap(String char) {
      amountText.value = NumpadLogic.handleTap(char, amountText.value);
    }

    void handleBackspace() {
      amountText.value = NumpadLogic.handleBackspace(amountText.value);
    }

    useEffect(() {
      if (!context.isMobile) {
        context.pop();
      }
      return null;
    }, [context.isMobile]);

    return PopScope(
      canPop: !isAutomaticallyOpened,
      onPopInvokedWithResult: (didPop, result) {
        // If didPop is true, the screen is already closing.
        if (didPop) return;

        if (kIsWeb) {
          context.pop();
        }
        HomeRoute().go(context);
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: Assets.images.onboardingBackground.provider(),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: Dimens.of(context).edgeInsetsScreenHorizontal,
              child: Stack(
                children: [
                  Positioned(
                    top: 29,
                    right: 0,
                    child: IconButton(
                      style: IconButton.styleFrom(
                        padding: EdgeInsets.all(Dimens.padding.p6),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        minimumSize: Size.zero,
                      ),
                      onPressed: () {
                        if (isAutomaticallyOpened) {
                          if (kIsWeb) {
                            context.pop();
                          }
                          HomeRoute().go(context);
                        } else {
                          context.pop();
                        }
                      },
                      icon: PhosphorIcon(
                        PhosphorIcons.x(.bold),
                        color: context.color.blue200,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Column(
                      mainAxisSize: .min,
                      crossAxisAlignment: .center,
                      children: [
                        Gap(Dimens.spacing.sp30),
                        Text(
                          type.isSend ? l10n.sendFunds : l10n.requestFunds,
                          style: context.typo.headlineSmall.copyWith(
                            color: context.color.blue100,
                          ),
                        ),
                        Gap(Dimens.spacing.sp32),
                        Material(
                          color: context.color.blue1100,
                          borderRadius: .circular(Dimens.radius.r8),
                          child: Padding(
                            padding: .symmetric(
                              vertical: Dimens.padding.p8,
                              horizontal: Dimens.padding.p12,
                            ),
                            child: Text(
                              l10n.enterAmountToSecure,
                              style: context.typo.bodyMedium.copyWith(
                                color: context.color.outline,
                              ),
                            ),
                          ),
                        ),
                        Gap(Dimens.spacing.sp35),
                        Expanded(
                          child: Column(
                            children: [
                              Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: l10n.nairaSign,
                                          style: context.typo.headlineLarge
                                              .copyWith(
                                                color: context.color.blue100,
                                              ),
                                        ),
                                        TextSpan(
                                          text: ' ',
                                          style: context.typo.headlineMedium,
                                        ),
                                        TextSpan(
                                          text: NumpadLogic.formatAmount(
                                            amountText.value,
                                          ),
                                          style: context.typo.displayMedium
                                              .copyWith(
                                                color: amountText.value == '0'
                                                    ? context.color.blue700
                                                    : context.color.blue100,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Gap(Dimens.spacing.sp4),
                              Material(
                                color: context.color.blue900,
                                borderRadius: .circular(Dimens.radius.r8),
                                child: Padding(
                                  padding: .symmetric(
                                    vertical: Dimens.padding.p4,
                                    horizontal: Dimens.padding.p6,
                                  ),
                                  child: Row(
                                    mainAxisSize: .min,
                                    children: [
                                      Text(
                                        "${l10n.minAmount}:",
                                        style: context.typo.bodySmall.copyWith(
                                          color: context.color.blue400,
                                        ),
                                      ),
                                      Gap(Dimens.spacing.sp4),
                                      Text(
                                        "${l10n.nairaSign}${NumberFormat('#,###.##').format(minimumAmount)}",
                                        style: context.typo.bodySmall.copyWith(
                                          color: context.color.blue400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Gap(Dimens.spacing.sp24),
                              Expanded(
                                child: _NumpadGrid(
                                  onTap: handleTap,
                                  onBackspace: handleBackspace,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Gap(Dimens.spacing.sp40),
                        PrimaryButton(
                          onPressed:
                              (amountText.value.isNotEmpty
                                      ? double.parse(amountText.value)
                                      : 0.0) >=
                                  minimumAmount
                              ? () {
                                  String finalValue = amountText.value;
                                  if (finalValue.endsWith('.')) {
                                    finalValue = finalValue.substring(
                                      0,
                                      finalValue.length - 1,
                                    );
                                  }
                                  onSubmitted.call(finalValue);
                                  context.pop();
                                }
                              : null,
                          child: Text(l10n.next),
                        ),
                        Gap(Dimens.spacing.sp20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AgreementNumpad extends HookWidget {
  const AgreementNumpad({
    super.key,
    required this.initialAmount,
    required this.type,
    required this.onChanged,
  });

  final String initialAmount;
  final AgreementType type;
  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final showNumpad = useState(false);

    final amountText = useState(initialAmount.isEmpty ? '0' : initialAmount);
    final double minimumAmount = 1500;

    void handleTap(String char) {
      amountText.value = NumpadLogic.handleTap(char, amountText.value);
    }

    void handleBackspace() {
      amountText.value = NumpadLogic.handleBackspace(amountText.value);
    }

    useEffect(() {
      amountText.value = initialAmount.isEmpty ? '0' : initialAmount;
      return null;
    }, [initialAmount]);

    useEffect(() {
      if ((amountText.value.isNotEmpty
              ? double.parse(amountText.value)
              : 0.0) >=
          minimumAmount) {
        String finalValue = amountText.value;
        if (finalValue.endsWith('.')) {
          finalValue = finalValue.substring(0, finalValue.length - 1);
        }
        onChanged.call(finalValue);
      }
      return null;
    }, [amountText.value]);

    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .stretch,
      children: [
        Container(
          padding: .all(Dimens.padding.p20),
          decoration: BoxDecoration(
            color: context.color.grayComponent,
            borderRadius: .circular(Dimens.radius.r8),
          ),
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .start,
            children: [
              Text(
                l10n.amountLabel,
                style: context.typo.bodySmall.copyWith(
                  color: context.color.grey600,
                ),
              ),
              Gap(Dimens.spacing.sp8),
              RichText(
                text: TextSpan(
                  style: context.typo.headlineLarge.copyWith(
                    color: context.color.grey500,
                  ),
                  children: [
                    TextSpan(text: l10n.nairaSign),
                    TextSpan(text: ' '),
                    TextSpan(text: NumpadLogic.formatAmount(amountText.value)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Gap(Dimens.spacing.sp12),
        AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          child: showNumpad.value
              ? Material(
                  color: context.color.background,
                  borderRadius: .circular(Dimens.radius.r8),
                  child: Padding(
                    padding: EdgeInsets.all(Dimens.padding.p8),
                    child: _NumpadGrid(
                      onTap: handleTap,
                      onBackspace: handleBackspace,
                    ),
                  ),
                )
              : InkWell(
                  onTap: () => showNumpad.value = true,
                  child: Material(
                    borderRadius: .circular(Dimens.radius.r8),
                    color: context.color.green150,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimens.padding.p8,
                        vertical: Dimens.padding.p4,
                      ),
                      child: Row(
                        mainAxisSize: .min,
                        children: [
                          PhosphorIcon(
                            PhosphorIcons.numpad(.duotone),
                            color: context.color.green900,
                            size: Dimens.size.s16,
                          ),
                          Gap(Dimens.spacing.sp6),
                          Text(
                            l10n.showNumpad,
                            style: context.typo.bodyMedium.copyWith(
                              fontWeight: AppFontWeights.regular,
                              color: context.color.green900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _NumpadGrid extends StatelessWidget {
  const _NumpadGrid({required this.onTap, required this.onBackspace});

  final ValueChanged<String> onTap;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    final List<String> keys = [
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '.',
      '0',
      '<',
    ];

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {

        // Use the actual height of the container to calculate the aspect ratio.
        // We have 4 rows of keys.
        // Width of one item is (maxWidth / 3)
        // Height of one item should be (maxHeight / 4) to fill the height exactly.
        // childAspectRatio = width / height
        final double calculatedRatioForMobile =
            (constraints.maxWidth / 3) / (constraints.maxHeight / 4);

        return GridView.builder(
          clipBehavior: Clip.none,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: context.isMobile ? calculatedRatioForMobile : 1.8,
            crossAxisSpacing: Dimens.spacing.sp20,
            mainAxisSpacing: 0,
          ),
          itemCount: keys.length,
          itemBuilder: (BuildContext context, int index) {
            final key = keys[index];

            return Material(
              clipBehavior: Clip.antiAlias,
              color: context.color.transparent,
              child: InkWell(
                onTap: key == '<' ? onBackspace : () => onTap(key),
                borderRadius: BorderRadius.circular(Dimens.radius.r8),
                child: Center(
                  child: Text(
                    key,
                    style: context.typo.headlineMedium.copyWith(
                      color: context.isMobile
                          ? context.color.blue100
                          : context.color.secondary,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class NumpadLogic {
  static String handleTap(
    String char,
    String currentText, {
    int maxDigits = 9,
  }) {
    if (char == '.') {
      if (currentText.contains('.')) return currentText;
      if (currentText.isEmpty) return '0.';
      return currentText + char;
    }

    if (char == '0' && currentText == '0') return currentText;

    if (currentText == '0' && char != '.') return char;

    // Limit to 2 decimal places
    if (currentText.contains('.')) {
      final parts = currentText.split('.');
      if (parts.length > 1 && parts[1].length >= 2) {
        return currentText;
      }
    }

    // Overall length limit (excluding formatting)
    if (currentText.replaceAll('.', '').length < maxDigits) {
      return currentText + char;
    }

    return currentText;
  }

  static String handleBackspace(String currentText) {
    if (currentText.isEmpty || currentText == '0') return '0';
    final newText = currentText.substring(0, currentText.length - 1);
    return newText.isEmpty ? '0' : newText;
  }

  static String formatAmount(String rawAmount) {
    if (rawAmount.isEmpty || rawAmount == '0') return '0';

    try {
      // Handle decimal part separately to preserve trailing zeros
      if (rawAmount.contains('.')) {
        final parts = rawAmount.split('.');
        final integerPart = parts[0];
        final decimalPart = parts.length > 1 ? parts[1] : '';

        final formattedInteger = NumberFormat(
          '#,###',
        ).format(integerPart.isEmpty ? 0 : int.parse(integerPart));

        return '$formattedInteger.$decimalPart';
      }

      return NumberFormat('#,###').format(double.parse(rawAmount));
    } catch (e) {
      return rawAmount;
    }
  }
}
