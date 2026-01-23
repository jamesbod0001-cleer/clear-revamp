import 'package:cleer/config/assets.gen.dart';
import 'package:cleer/ui/agreements/create_agreement/models/agreement_type.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:cleer/ui/core/ui/buttons/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AgreementNumpadOverlay extends HookWidget {
  const AgreementNumpadOverlay({super.key, required this.type});

  final AgreementType type;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final amountText = useState('0');
    final double minimumAmount = 1000;

    void handleTap(String char) {
      final currentText = amountText.value;
      if (char == '.') {
        if (currentText.contains('.')) return;

        if (currentText.isEmpty) {
          amountText.value = '0.';
          return;
        }
      }

      if (currentText.length < 7) {
        amountText.value = currentText + char;
      }
    }

    void handleBackspace() {
      if (amountText.value.isNotEmpty) {
        amountText.value = amountText.value.substring(
          0,
          amountText.value.length - 1,
        );
      }
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Assets.images.onboardingBackground.provider(),
            fit: BoxFit.cover,
          ),
        ),
        padding: Dimens.mobile.edgeInsetsScreenHorizontal,
        child: SafeArea(
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
                    context.pop();
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
                    Gap(Dimens.spacing.sp35),
                    Text(
                      type.isSend ? l10n.sendFunds : l10n.requestFunds,
                      style: context.typo.headlineSmall.copyWith(
                        color: context.color.blue100,
                        fontWeight: AppFontWeights.bold,
                        height: 1,
                      ),
                    ),
                    Gap(Dimens.spacing.sp54),
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
                                      style: context.typo.headlineMedium
                                          .copyWith(
                                            color: context.color.blue100,
                                            fontSize: 40,
                                            height: 1.5,
                                            letterSpacing: 0,
                                          ),
                                    ),
                                    TextSpan(
                                      text: ' ',
                                      style: context.typo.headlineMedium,
                                    ),
                                    TextSpan(
                                      text: amountText.value.isEmpty
                                          ? '0'
                                          : NumberFormat('#,###.##').format(
                                              double.parse(amountText.value),
                                            ),
                                      style: context.typo.displayMedium
                                          .copyWith(
                                            color: context.color.blue700,
                                            height: 1.5,
                                            letterSpacing: 0,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Gap(Dimens.spacing.sp8),
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
                      onPressed: double.parse(amountText.value) > minimumAmount
                          ? () {}
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
    return GridView.builder(
      clipBehavior: .none,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: Dimens.spacing.sp20,
        mainAxisSpacing: 0,
      ),
      itemCount: keys.length,
      itemBuilder: (BuildContext context, int index) {
        final key = keys[index];

        return Material(
          clipBehavior: .antiAlias,
          color: context.color.transparent,
          child: InkWell(
            onTap: key == '<' ? onBackspace : () => onTap(key),
            borderRadius: .circular(Dimens.radius.r8),
            child: Center(
              child: Text(
                key,
                style: context.typo.headlineMedium.copyWith(
                  color: context.color.blue100,
                  height: 1.5,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
