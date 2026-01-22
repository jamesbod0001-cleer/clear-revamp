import 'package:cleer/config/assets.gen.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        toolbarHeight: Dimens.size.s126 - MediaQuery.of(context).padding.top,
        flexibleSpace: Container(
          height: Dimens.size.s126,
          alignment: .bottomCenter,
          padding: .symmetric(
            horizontal: Dimens.padding.p18,
            vertical: Dimens.padding.p22,
          ),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: Assets.images.appBarBackground.provider(),
              fit: BoxFit.cover,
            ),
          ),
          child: Row(
            children: [
              Text(
                l10n.cleer,
                style: context.typo.headlineMedium.copyWith(
                  color: context.color.background,
                  fontWeight: AppFontWeights.bold,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              child: Padding(
                padding: Dimens.mobile.edgeInsetsScreenHorizontal.copyWith(
                  top: Dimens.padding.p10,
                  bottom: MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  crossAxisAlignment: .start,
                  children: [Gap(Dimens.spacing.sp20)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
