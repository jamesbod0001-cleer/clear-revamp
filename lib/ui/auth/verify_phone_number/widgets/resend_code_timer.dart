import 'dart:async';

import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ResendCodeTimer extends ConsumerStatefulWidget {
  const ResendCodeTimer(this.startAt, {super.key, this.resendOtp});
  final Duration startAt;
  final VoidCallback? resendOtp;

  @override
  ConsumerState<ResendCodeTimer> createState() => _ResendOtpTimerState();
}

class _ResendOtpTimerState extends ConsumerState<ResendCodeTimer> {
  late Timer _timer;
  late Duration currentDuration;

  @override
  void initState() {
    super.initState();
    currentDuration = widget.startAt;
    startCountdown();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void subtractTime() {
    if (mounted) {
      setState(() {
        final seconds = currentDuration.inSeconds - 1;
        currentDuration = Duration(seconds: seconds);
        if (currentDuration.inSeconds <= 0) {
          _timer.cancel();
        }
      });
    }
  }

  void startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      subtractTime();
    });
  }

  void restart() {
    if (mounted) {
      setState(() {
        currentDuration = widget.startAt;
      });
      startCountdown();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: Dimens.spacing.sp4,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppLocalizations.of(context)!.didntReceiveOTP,
          style: context.typo.labelSmall.copyWith(color: context.color.grey600),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          child: currentDuration.inSeconds == 0
              ? GestureDetector(
                  onTap: () {
                    restart();
                    if (widget.resendOtp != null) {
                      widget.resendOtp!();
                    }
                  },
                  child: Text(
                    AppLocalizations.of(context)!.resend,
                    style: context.typo.labelSmall.copyWith(
                      color: context.color.green1000,
                    ),
                  ),
                )
              : Text(
                  "${currentDuration.inMinutes.toString().padLeft(2, '0')}:${(currentDuration.inSeconds % 60).toString().padLeft(2, '0')}",
                  style: context.typo.labelSmall,
                ),
        ),
      ],
    );
  }
}
