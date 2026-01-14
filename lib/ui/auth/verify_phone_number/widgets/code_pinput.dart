import 'package:cleer/ui/auth/verify_phone_number/view_model/verify_phone_number_view_model.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:pinput/pinput.dart';

class CodePinput extends ConsumerStatefulWidget {
  const CodePinput({
    super.key,
    this.otpLength = 6,
    this.onCompleted,
    this.controller,
  });

  final int otpLength;
  final Function(String?)? onCompleted;
  final TextEditingController? controller;

  @override
  ConsumerState<CodePinput> createState() => _OtpPinputState();
}

class _OtpPinputState extends ConsumerState<CodePinput> {
  @override
  Widget build(BuildContext context) {
    final PinTheme focusedPinTheme = PinTheme(
      width: Dimens.size.s60,
      height: Dimens.size.s60,
      textStyle: context.typo.bodyLarge,
      decoration: BoxDecoration(
        color: context.color.grayComponent,
        border: Border.all(color: context.color.blue400, width: Dimens.size.s2),
        borderRadius: BorderRadius.circular(Dimens.radius.r10),
      ),
    );
    final PinTheme errorPinTheme = PinTheme(
      width: Dimens.size.s60,
      height: Dimens.size.s60,
      textStyle: context.typo.bodyLarge,
      decoration: BoxDecoration(
        color: context.color.grayComponent,
        border: Border.all(color: context.color.error),
        borderRadius: BorderRadius.circular(Dimens.radius.r10),
      ),
    );
    final PinTheme defaultPinTheme = PinTheme(
      width: Dimens.size.s60,
      height: Dimens.size.s60,
      textStyle: context.typo.bodyLarge,
      decoration: BoxDecoration(
        color: context.color.grayComponent,
        border: Border.all(color: context.color.outline),
        borderRadius: BorderRadius.circular(Dimens.radius.r10),
      ),
    );
    return Pinput(
      controller: widget.controller,
      length: widget.otpLength,
      validator: (value) {
        if (value == null ||
            value.isEmpty ||
            value.length != widget.otpLength) {
          return 'AppLocalizations.of(context)!.invalidOTPCodePleaseTryAgain';
        }
        return null;
      },
      forceErrorState: ref.watch(verifyPhoneNumberViewModelProvider).hasError,
      errorText: AppLocalizations.of(context)!.expiredCodeExceptionMessage,
      errorTextStyle: context.typo.bodySmall.copyWith(
        color: context.color.error,
      ),
      errorBuilder: (errorText, pin) {
        return Padding(
          padding: EdgeInsets.only(top: Dimens.padding.p12),
          child: Row(
            mainAxisAlignment: .center,
            children: [
              PhosphorIcon(
                PhosphorIcons.warning(.bold),
                color: context.color.error,
                size: Dimens.size.s16,
              ),
              Gap(Dimens.spacing.sp4),
              Text(
                errorText ?? '',
                style: context.typo.bodyMedium.copyWith(
                  color: context.color.error,
                ),
              ),
            ],
          ),
        );
      },
      onChanged: (value) {
        if (value.length != widget.otpLength) {
          debugPrint('In here');
          // ref.read(verifyEmailAddressViewModelProvider.notifier).setOtp(kEmpty);
        }
      },
      focusedPinTheme: focusedPinTheme,
      errorPinTheme: errorPinTheme,
      defaultPinTheme: defaultPinTheme,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      cursor: Column(
        mainAxisAlignment: .center,
        children: [
          Container(
            width: Dimens.size.s24,
            height: Dimens.size.s6,
            decoration: BoxDecoration(
              border: Border.all(color: context.color.outline),
              color: context.color.grey200,
            ),
          ),
        ],
      ),
      onCompleted: widget.onCompleted,
    );
  }
}
