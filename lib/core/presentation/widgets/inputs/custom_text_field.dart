// lib/core/presentation/widgets/inputs/custom_text_field.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:app_crm/core/index_core.dart';

// ── Estilos compartidos compactos ─────────────────────────────────────────────

const _kLabelStyle = TextStyle(
  fontSize: AppTextStyles.sizeXs,
  color: AppColors.textSecondary,
);

const _kHintStyle = TextStyle(
  fontSize: AppTextStyles.sizeXs,
  color: AppColors.textDisabled,
);

const _kFloatingLabelStyle = TextStyle(
  fontSize: AppTextStyles.sizeXs,
  color: AppColors.primary,
  fontWeight: FontWeight.w600,
);

const _kContentPadding = EdgeInsets.symmetric(
  horizontal: AppSpacing.sm,
  vertical: AppSpacing.sm2,
);

// ── CustomTextField ───────────────────────────────────────────────────────────

class CustomTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool enabled;
  final bool readOnly;
  final int? maxLength;
  final int? maxLines;
  final int? minLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? prefixText;
  final String? suffixText;
  final List<TextInputFormatter>? inputFormatters;
  final bool autocorrect;
  final TextCapitalization textCapitalization;
  final FocusNode? focusNode;
  final bool obscureText;
  final bool isUpperCase;
  final VoidCallback? onTap;
  // Mantenido por compatibilidad — el estilo compacto es ahora el default
  final bool dense;

  const CustomTextField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.enabled = true,
    this.readOnly = false,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.inputFormatters,
    this.autocorrect = false,
    this.textCapitalization = TextCapitalization.none,
    this.focusNode,
    this.obscureText = false,
    this.isUpperCase = false,
    this.onTap,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final disabledColor = Theme.of(context).disabledColor;

    List<TextInputFormatter>? formatters = inputFormatters;
    if (isUpperCase) {
      final uppercaseFormatter = _UpperCaseTextFormatter();
      formatters = formatters != null
          ? [...formatters, uppercaseFormatter]
          : [uppercaseFormatter];
    }

    return TextFormField(
      onTap: onTap,
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      enabled: enabled,
      readOnly: readOnly,
      maxLength: maxLength,
      maxLines: maxLines,
      minLines: minLines,
      inputFormatters: formatters,
      autocorrect: autocorrect,
      textCapitalization: textCapitalization,
      focusNode: focusNode,
      obscureText: obscureText,
      // Oculta el contador "x/y" bajo el campo cuando hay maxLength — el
      // límite ya se aplica en silencio, no hace falta mostrarlo.
      buildCounter:
          (
            context, {
            required currentLength,
            required isFocused,
            maxLength,
          }) => null,
      style: AppTextStyles.inputTextCompact.copyWith(
        color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helperText,
        labelStyle: _kLabelStyle,
        hintStyle: _kHintStyle,
        floatingLabelStyle: _kFloatingLabelStyle,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        prefixText: prefixText,
        suffixText: suffixText,
        filled: true,
        fillColor: enabled
            ? colorScheme.surface
            : colorScheme.surfaceContainerHighest,
        isDense: true,
        contentPadding: _kContentPadding,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizing.radiusSm),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizing.radiusSm),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizing.radiusSm),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: AppSizing.borderFocusWidth,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizing.radiusSm),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizing.radiusSm),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: AppSizing.borderFocusWidth,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizing.radiusSm),
          // ignore: deprecated_member_use
          borderSide: BorderSide(color: disabledColor.withOpacity(0.4)),
        ),
      ),
    );
  }
}

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
