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
  // Botón "X" que limpia el campo cuando tiene texto — mismo patrón que ya
  // usa CustomComboSearchField. Agregado 2026-07-22, disponible para
  // cualquier campo, pero **por ahora ningún campo de la app lo activa** —
  // pedido explícito del usuario: dejarlo listo pero apagado por defecto,
  // para habilitarlo manualmente campo por campo cuando se decida cuáles
  // lo necesitan. Para activarlo en un campo puntual, pasar
  // `mostrarBotonLimpiar: true` (requiere `controller` — sin uno no hay
  // texto que observar para saber cuándo mostrar el botón). Se ignora si
  // ya se pasó un `suffixIcon` propio (no se pisan entre sí).
  final bool mostrarBotonLimpiar;

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
    this.mostrarBotonLimpiar = false,
  });

  Widget? _buildSuffixIcon() {
    if (suffixIcon != null) return suffixIcon;
    if (!mostrarBotonLimpiar || controller == null) return null;

    return AnimatedBuilder(
      animation: controller!,
      builder: (_, _) => controller!.text.isEmpty
          ? const SizedBox.shrink()
          : GestureDetector(
              onTap: () {
                controller!.clear();
                onChanged?.call('');
              },
              child: const Icon(AppIcons.close, size: AppSizing.iconSm),
            ),
    );
  }

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
          (context, {required currentLength, required isFocused, maxLength}) =>
              null,
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
        suffixIcon: _buildSuffixIcon(),
        // Sin esto, Material reserva un área táctil mínima de 48x48 para
        // cada ícono sin importar su propio `size` — infla el campo por
        // encima del alto compacto (isDense) de los campos sin ícono, aunque
        // el ícono en sí sea chico. minHeight:0 deja que el alto lo defina
        // el contenido (igual que un campo sin ícono); minWidth chico (no 0)
        // le deja algo de aire al ícono para que no quede pegado al borde.
        prefixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 0),
        suffixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 0),
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
