import 'package:cleer/ui/agreements/agreements/widgets/agreement_card.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:cleer_ui/themes/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AgreementCardSkeletonList extends StatelessWidget {
  const AgreementCardSkeletonList({super.key, this.itemCount = 3});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < itemCount; i++) ...[
            AgreementCard(
              agreement: Agreement(
                id: '',
                shortCode: BoneMock.words(1),
                amount: 10000,
                currency: 'NGN',
                disbursementType: .oneTime,
                category: .physicalGoods,
                description: BoneMock.subtitle,
                initiatorRole: .sender,
                expectedReleaseDate: .now(),
              ),
            ),
            if (i < itemCount - 1) Gap(Dimens.spacing.sp16),
          ],
        ],
      ),
    );
  }
}
