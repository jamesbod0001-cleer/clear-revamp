import 'package:cleer_ui/enums/text_form_field_variant.dart';
import 'package:cleer_ui/l10n/generated/ui_localizations.dart';
import 'package:cleer_ui/themes/theme_utils.dart';
import 'package:cleer_ui/utils/formatters/nigerian_phone_formatter.dart';
import 'package:cleer_core/utils/constants.dart';
import 'package:cleer_core/utils/validators/phone_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:cleer_ui/themes/dimensions.dart';

class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    super.key,
    this.variant = TextFormFieldVariant.standard,
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

  final TextFormFieldVariant variant;

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
  FocusNode? _internalFocusNode;

  /// Returns the provided focus node if it exists, otherwise returns the internal one.
  FocusNode get _effectiveFocusNode => widget.focusNode ?? _internalFocusNode!;

  @override
  void initState() {
    super.initState();
    obscureText = widget.obscureText ?? widget.isPassword;

    // Initialize an internal FocusNode if one wasn't provided
    if (widget.focusNode == null) {
      _internalFocusNode = FocusNode();
    }

    // Listen for focus changes to trigger rebuilds for styling
    _effectiveFocusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _effectiveFocusNode.removeListener(_onFocusChanged);
    _internalFocusNode?.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {}); // Triggers a rebuild to update the fill opacity
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
    final isDark = widget.variant == TextFormFieldVariant.dark;
    final labelColor = isDark ? context.color.outline : context.color.grey600;

    return FormField<String>(
      key: widget.fieldKey,
      validator: widget.validator,
      initialValue: widget.controller?.text,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (FormFieldState<String> state) {
        // Determine dynamic fill color based on focus and content
        final hasContent = state.value?.isNotEmpty ?? false;
        final isFocused = _effectiveFocusNode.hasFocus;

        Color fillColor;
        if (isDark) {
          final isActive = isFocused || hasContent;
          fillColor = context.color.white.withValues(
            alpha: isActive ? 0.45 : 0.20,
          );
        } else {
          fillColor = context.color.grayComponent;
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.labelText != null || widget.label != null) ...[
              widget.label ??
                  Text(
                    widget.labelText!,
                    style: context.typo.bodyMedium.copyWith(color: labelColor),
                  ),
              Gap(Dimens.spacing.sp4),
            ],
            TextField(
              focusNode: _effectiveFocusNode,
              controller: widget.controller,
              onChanged: (value) => state.didChange(
                value,
              ), // didChange triggers the FormField builder to rebuild
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
                fillColor: fillColor,
                filled: true,
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
  const PhoneNumberTextFormField({
    super.key,
    this.variant = .standard,
    this.labelText,
    required this.controller,
  });

  final TextFormFieldVariant variant;
  final String? labelText;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = variant == TextFormFieldVariant.dark;

    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .start,
      children: [
        Text(
          labelText ?? UiLocalizations.of(context)!.phoneNumber,
          style: context.typo.bodyMedium.copyWith(
            color: isDark ? context.color.outline : context.color.grey600,
          ),
        ),
        Gap(Dimens.spacing.sp4),
        Row(
          mainAxisSize: .min,
          crossAxisAlignment: .start,
          children: [
            Material(
              borderRadius: BorderRadius.circular(Dimens.radius.r12),
              color: isDark
                  ? context.color.white.withValues(alpha: .20)
                  : context.color.grayComponent,
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
                variant: variant,
                controller: controller,
                textInputType: .phone,
                inputFormatters: [NigerianPhoneFormatter()],
                validator: (val) => nigerianPhoneValidator(
                  val,
                  errorRequired: UiLocalizations.of(
                    context,
                  )!.fieldRequired("phone number"),
                  errorInvalid: UiLocalizations.of(context)!.invalidPhoneNumber,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
