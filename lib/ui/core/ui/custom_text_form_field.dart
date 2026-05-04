import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:cleer/ui/core/utils/formatters/nigerian_phone_formatter.dart';
import 'package:cleer/utils/constants.dart';
import 'package:cleer/utils/validators/phone_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';

class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    super.key,
    this.fieldKey,
    this.labelText,
    this.label,
    this.hintText,
    this.controller,
    this.validator,
    this.inputFormatters,
    this.maxLength,
    this.minLines = 1,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
    this.isPassword = false,
    this.obscureText,
    this.textInputType,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.readOnly = false,
    this.focusNode,
  });

  final GlobalKey<FormFieldState>? fieldKey;

  final String? labelText;
  final Widget? label;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int? minLines;
  final int? maxLines;
  final TextCapitalization textCapitalization;
  final bool isPassword;
  final bool? obscureText;
  final TextInputType? textInputType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final bool readOnly;
  final FocusNode? focusNode;

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late bool obscureText;

  @override
  void initState() {
    obscureText = widget.obscureText ?? widget.isPassword;
    super.initState();
  }

  Widget? get suffixIcon =>
      widget.suffixIcon ??
      (widget.isPassword
          ? IconButton(
              onPressed: () => setState(() => obscureText = !obscureText),
              icon: PhosphorIcon(
                obscureText ? PhosphorIcons.eye() : PhosphorIcons.eyeClosed(),
                color: context.color.blue700,
              ),
            )
          : null);

  Widget? get prefixIcon => widget.prefixIcon;

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      key: widget.fieldKey,
      validator: widget.validator,
      initialValue: widget.controller?.text,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (FormFieldState<String> state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.labelText != null || widget.label != null) ...[
              widget.label ??
                  Text(
                    widget.labelText!,
                    style: context.typo.bodyMedium.copyWith(
                      color: context.color.grey600,
                    ),
                  ),
              Gap(Dimens.spacing.sp4),
            ],
            TextField(
              focusNode: widget.focusNode,
              controller: widget.controller,
              onChanged: (value) => state.didChange(value),
              onTap: widget.onTap,
              maxLines: widget.maxLines,
              minLines: widget.minLines,
              maxLength: widget.maxLength,
              textCapitalization: widget.textCapitalization,
              readOnly: widget.readOnly,
              decoration: InputDecoration(
                hintText: widget.hintText,
                errorText: state.errorText,
                errorStyle: const TextStyle(fontSize: 0, height: 0),
                enabledBorder: state.hasError
                    ? context.theme.inputDecorationTheme.errorBorder
                    : null,
                focusedBorder: state.hasError
                    ? context.theme.inputDecorationTheme.errorBorder
                    : null,
                prefix: prefixIcon,
                suffixIcon: suffixIcon,
              ),
              keyboardType: widget.textInputType,
              obscureText: obscureText,
              inputFormatters: widget.inputFormatters,
            ),
            if (state.hasError)
              Row(
                children: [
                  PhosphorIcon(
                    PhosphorIcons.warning(.bold),
                    color: context.color.error,
                    size: Dimens.size.s16,
                  ),
                  Gap(Dimens.spacing.sp4),
                  Expanded(
                    child: Text(
                      state.errorText ?? '',
                      style: context.typo.bodyMedium.copyWith(
                        color: context.color.error,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        );
      },
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
