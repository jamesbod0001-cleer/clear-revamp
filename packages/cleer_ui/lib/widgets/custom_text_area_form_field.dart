import 'package:cleer_ui/enums/text_form_field_variant.dart';
import 'package:cleer_ui/themes/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:cleer_ui/themes/dimensions.dart';

class CustomTextAreaFormField extends StatefulWidget {
  const CustomTextAreaFormField({
    super.key,
    this.variant = TextFormFieldVariant.standard,
    this.labelText,
    this.label,
    this.hintText,
    this.controller,
    this.validator,
    this.minLines = 3,
    this.maxLines = 5,
    this.focusNode,
    this.footer,
  });

  final TextFormFieldVariant variant;
  final String? labelText;
  final Widget? label;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final int? minLines;
  final int? maxLines;
  final FocusNode? focusNode;
  final Widget? footer;

  @override
  State<CustomTextAreaFormField> createState() => _CustomTextAreaFormFieldState();
}

class _CustomTextAreaFormFieldState extends State<CustomTextAreaFormField> {
  FocusNode? _internalFocusNode;
  FocusNode get _effectiveFocusNode => widget.focusNode ?? _internalFocusNode!;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) _internalFocusNode = FocusNode();
    _effectiveFocusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _effectiveFocusNode.removeListener(_onFocusChanged);
    _internalFocusNode?.dispose();
    super.dispose();
  }

  void _onFocusChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final isDark = widget.variant == TextFormFieldVariant.dark;

    return FormField<String>(
      validator: widget.validator,
      initialValue: widget.controller?.text,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (FormFieldState<String> state) {
        final hasContent = state.value?.isNotEmpty ?? false;
        final isFocused = _effectiveFocusNode.hasFocus;

        final fillColor = isDark
            ? context.color.white.withValues(alpha: (isFocused || hasContent) ? 0.10 : 0.20)
            : context.color.grayComponent;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.labelText != null || widget.label != null) ...[
              widget.label ??
                  Text(
                    widget.labelText!,
                    style: context.typo.bodyMedium.copyWith(
                      color: isDark ? context.color.outline : context.color.grey600,
                    ),
                  ),
              Gap(Dimens.spacing.sp4),
            ],
            InputDecorator(
              isFocused: isFocused,
              isEmpty: !hasContent,
              decoration: InputDecoration(
                errorText: state.errorText,
                errorStyle: const TextStyle(fontSize: 0, height: 0),
                enabledBorder: state.hasError ? context.theme.inputDecorationTheme.errorBorder : null,
                focusedBorder: state.hasError ? context.theme.inputDecorationTheme.errorBorder : null,
                fillColor: fillColor,
                filled: true,
                contentPadding: EdgeInsets.zero,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    focusNode: _effectiveFocusNode,
                    controller: widget.controller,
                    onChanged: (value) => state.didChange(value),
                    maxLines: widget.maxLines,
                    minLines: widget.minLines,
                    textCapitalization: TextCapitalization.sentences,
                    keyboardType: TextInputType.multiline,
                    style: isDark ? TextStyle(color: context.color.white) : null,
                    decoration: InputDecoration(
                      // 1. Force structural collapse without inner spacing constraints
                      isCollapsed: true,
                      hintText: widget.hintText,
                      hintStyle: isDark ? context.typo.bodyMedium.copyWith(color: context.color.white.withValues(alpha: 0.5)) : null,

                      // 2. Kill all potential border injections from the global theme
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      filled:  false
                    ),
                  ),
                  if (widget.footer != null) ...[
                    // Gap(Dimens.spacing.sp8),
                    widget.footer!,
                  ],
                ],
              ),
            ),
            if (state.hasError) ...[
              Gap(Dimens.spacing.sp4),
              Row(
                children: [
                  PhosphorIcon(PhosphorIcons.warning(.bold), color: context.color.error, size: Dimens.size.s16),
                  Gap(Dimens.spacing.sp4),
                  Expanded(
                    child: Text(state.errorText ?? '', style: context.typo.bodyMedium.copyWith(color: context.color.error)),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}