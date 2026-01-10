import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:cleer/utils/constants.dart';
import 'package:cleer/utils/validators/nigerian_phone_formatter.dart';
import 'package:cleer/utils/validators/phone_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';

class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    super.key,
    this.labelText,
    this.hintText,
    this.controller,
    this.validator,
    this.inputFormatters,
    this.maxLength,
    this.minLines = 1,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
    this.isPassword = false,
    this.textInputType,
  });

  final String? labelText;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int? minLines;
  final int? maxLines;
  final TextCapitalization textCapitalization;
  final bool isPassword;
  final TextInputType? textInputType;

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late bool obscureText;

  @override
  void initState() {
    obscureText = widget.isPassword;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: context.typo.bodyMedium.copyWith(
              color: context.color.grey600,
            ),
          ),
          Gap(Dimens.spacing.sp4),
        ],
        TextFormField(
          autovalidateMode: .onUserInteraction,
          controller: widget.controller,
          decoration: InputDecoration(
            errorMaxLines: 2,
            hintText: widget.hintText,
            suffixIcon: widget.isPassword
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        obscureText = !obscureText;
                      });
                    },
                    icon: PhosphorIcon(
                      obscureText
                          ? PhosphorIcons.eye(.duotone)
                          : PhosphorIcons.eyeClosed(.duotone),
                      color: context.color.blue700,
                    ),
                  )
                : null,
          ),
          keyboardType: widget.textInputType,
          textCapitalization: widget.textCapitalization,
          validator: widget.validator,
          inputFormatters: widget.inputFormatters,
          maxLength: widget.maxLength,
          minLines: widget.minLines,
          maxLines: widget.maxLines,
          obscureText: obscureText,
        ),
      ],
    );
  }
}

class PhoneNumberTextFormField extends StatelessWidget {
  const PhoneNumberTextFormField({super.key, required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .start,
      children: [
        Text(
          AppLocalizations.of(context)!.phoneNumber,
          style: context.typo.bodyMedium.copyWith(color: context.color.grey600),
        ),
        Gap(Dimens.spacing.sp4),
        Row(
          mainAxisSize: .min,
          crossAxisAlignment: .start,
          children: [
            Material(
              borderRadius: BorderRadius.circular(Dimens.radius.r12),
              color: context.color.grayComponent,
              child: SizedBox(
                height: Dimens.size.s48,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: Dimens.padding.p12),
                  child: Row(
                    mainAxisSize: .min,
                    children: [
                      Stack(
                        alignment: .center,
                        children: [
                          Material(
                            borderRadius: .circular(Dimens.radius.r2),
                            color: context.color.success,
                            child: SizedBox(
                              width: Dimens.spacing.sp20,
                              height: 13.75,
                            ),
                          ),
                          Material(
                            color: context.color.successLight,
                            child: SizedBox(width: 6.25, child: Text(kEmpty)),
                          ),
                        ],
                      ),
                      Gap(Dimens.spacing.sp4),
                      Text('+234', style: context.typo.bodyMedium),
                    ],
                  ),
                ),
              ),
            ),
            Gap(Dimens.spacing.sp4),
            Expanded(
              child: CustomTextFormField(
                controller: controller,
                textInputType: .phone,
                inputFormatters: [NigerianPhoneFormatter()],
                validator: (val) =>
                    nigerianPhoneValidator(val, AppLocalizations.of(context)!),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
