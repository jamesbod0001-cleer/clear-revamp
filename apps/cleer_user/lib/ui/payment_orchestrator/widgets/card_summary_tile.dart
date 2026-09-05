import 'package:cleer/config/assets.gen.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:cleer/domain/providers/flutterwave/flutterwave_provider.dart';
import 'package:cleer_ui/cleer_ui.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CardSummaryTile extends ConsumerWidget {
  const CardSummaryTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardMethods = ref.watch(cardMethodsProvider);
    final savedCard = cardMethods?.firstOrNull;
    final cardDetails = savedCard?.cardDetails;

    final network = cardDetails?.network ?? CardNetwork.unknown;
    final maskedNumber = cardDetails?.maskedNumber ?? '•••• •••• •••• Card';
    final cardHolderName = cardDetails?.cardHolderName;

    return Container(
      decoration: BoxDecoration(
        color: context.color.grayComponent,
        border: Border.all(color: context.color.outline),
        borderRadius: BorderRadius.circular(Dimens.radius.r8),
      ),
      padding: EdgeInsets.all(Dimens.padding.p12),
      child: Row(
        children: [
          _getCardIcon(network, context, width: Dimens.size.s40),
          Gap(Dimens.spacing.sp12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  maskedNumber,
                  style: context.typo.titleLarge
                      .copyWith(
                    color: context.color.grey800,
                  ),
                ),
                if (cardHolderName != null && cardHolderName.isNotEmpty) ...[
                  Gap(Dimens.spacing.sp4),
                  Text(
                    cardHolderName,
                    style: context.typo.bodyMedium
                        .copyWith(
                      fontWeight:
                      AppFontWeights.regular,
                      color: context.color.grey600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getCardIcon(
    CardNetwork network,
    BuildContext context, {
    double? width,
  }) {
    final double size = width ?? Dimens.size.s32;
    switch (network) {
      case CardNetwork.visa:
        return Assets.icons.visa.svg(width: size);
      case CardNetwork.mastercard:
        return Assets.icons.mastercard.svg(width: size);
      case CardNetwork.verve:
        return Assets.icons.verve.svg(width: size);
      case CardNetwork.americanExpress:
        return Assets.icons.americanExpress.svg(width: size);
      case CardNetwork.discover:
        return Assets.icons.discover.svg(width: size);
      case CardNetwork.unknown:
      default:
        return PhosphorIcon(
          PhosphorIcons.creditCard(),
          size: size,
          color: context.color.blue700,
        );
    }
  }
}
