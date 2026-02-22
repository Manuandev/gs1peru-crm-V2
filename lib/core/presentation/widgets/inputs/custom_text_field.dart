// lib/core/presentation/widgets/inputs/custom_text_field.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:app_crm/core/constants/app_breakpoints.dart';
import 'package:app_crm/core/constants/app_spacing.dart';

/// CustomTextField — Input de texto base reutilizable
///
/// PROPÓSITO:
/// - Encapsula la configuración visual estándar de todos los TextFormField de la app
/// - Garantiza que todos los inputs tengan el mismo look & feel
/// - Expone solo las propiedades que necesitan variar entre instancias
///
/// DEPENDENCIAS DEL SISTEMA DE DISEÑO:
/// - Colores   → [AppColors.border], [AppColors.borderFocused], [AppColors.borderError]
/// - Espaciado → [AppSpacing.md] para contentPadding
/// - Radios    → [AppSizing.radiusMd] para bordes redondeados
/// - Tipografía→ [AppTextStyles.inputText] para el texto que escribe el usuario
///
/// WIDGETS QUE LO EXTIENDEN:
/// - [CustomPasswordField] — agrega toggle de visibilidad
/// - [CustomEmailField]    — agrega validación de formato de email
///
/// USO BÁSICO:
/// ```dart
/// CustomTextField(
///   label: 'Nombre',
///   hint: 'Ej: Juan Pérez',
///   controller: _nameController,
///   validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
/// )
/// ```
///
/// USO CON ÍCONO Y ACCIÓN:
/// ```dart
/// CustomTextField(
///   label: 'Buscar',
///   prefixIcon: const Icon(AppIcons.search),
///   textInputAction: TextInputAction.search,
///   onSubmitted: (value) => _doSearch(value),
/// )
/// ```
class CustomTextField extends StatelessWidget {
  // Texto del label flotante (se mueve arriba al enfocar)
  final String? label;
  // Texto de ayuda dentro del campo cuando está vacío
  final String? hint;
  // Texto auxiliar debajo del campo (desaparece cuando hay error)
  final String? helperText;
  // Controlador del texto — conecta el campo con la lógica del formulario
  final TextEditingController? controller;
  // Función de validación. Devuelve `null` si es válido, o el mensaje de error.
  final String? Function(String?)? validator;
  // Callback al cambiar el texto (cada tecla pulsada)
  final void Function(String)? onChanged;
  // Callback al presionar la tecla de acción del teclado
  final void Function(String)? onSubmitted;
  // Tipo de teclado: text, number, emailAddress, phone, etc.
  final TextInputType? keyboardType;
  // Acción del botón de acción del teclado: next, done, search, etc.
  final TextInputAction? textInputAction;
  // Si el campo acepta interacción del usuario
  final bool enabled;
  // Si solo se puede leer (sin editar) — útil para campos de selección
  final bool readOnly;
  // Máximo de caracteres permitidos (muestra contador abajo)
  final int? maxLength;
  // Número máximo de líneas (1 = una sola línea)
  final int? maxLines;
  // Número mínimo de líneas (para áreas de texto expandibles)
  final int? minLines;
  // Widget al inicio del campo (ej: `Icon(AppIcons.user)`)
  final Widget? prefixIcon;
  // Widget al final del campo (ej: botón de toggle de contraseña)
  final Widget? suffixIcon;
  // Texto fijo al inicio (ej: '$' para monedas)
  final String? prefixText;
  // Texto fijo al final (ej: 'kg' para unidades)
  final String? suffixText;
  // Formateadores de entrada (ej: solo números, mayúsculas, etc.)
  final List<TextInputFormatter>? inputFormatters;
  // Si el texto se autocorrige automáticamente
  final bool autocorrect;
  // Capitalización automática del texto
  final TextCapitalization textCapitalization;
  // FocusNode para controlar el foco desde el padre
  final FocusNode? focusNode;
  // Si el texto se muestra oculto (contraseña) — úsalo vía [CustomPasswordField]
  final bool obscureText;

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
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final textColor = enabled
        ? theme.textTheme.bodyLarge?.color
        : theme.disabledColor;

    return TextFormField(
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
      inputFormatters: inputFormatters,
      autocorrect: autocorrect,
      textCapitalization: textCapitalization,
      focusNode: focusNode,
      obscureText: obscureText,

      // ── ESTILO DEL TEXTO INGRESADO ────────────────────────────
      // Se usa AppTextStyles.inputText (sin color) y se aplica el color
      // según el estado del campo (enabled / disabled).
      style: TextStyle(fontSize: 16, color: textColor),
      decoration: InputDecoration(
        // Textos del campo
        labelText: label,
        hintText: hint,
        helperText: helperText,

        // Íconos y decoradores
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        prefixText: prefixText,
        suffixText: suffixText,

        // ── FONDO ───
        // 🔹 Usamos el tema global
        filled: true,
        fillColor: enabled
            ? colorScheme.surface
            : colorScheme.surfaceContainerHighest,

        // ── PADDING INTERNO ────
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),

        // ── BORDES ───────────────
        // Borde normal
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizing.radiusMd),
          borderSide: BorderSide(color: colorScheme.outline),
        ),

        // Borde cuando está habilitado
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizing.radiusMd),
          borderSide: BorderSide(color: colorScheme.outline),
        ),

        // Borde cuando está enfocado
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizing.radiusMd),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),

        // Borde cuando hay error
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizing.radiusMd),
          borderSide: BorderSide(color: colorScheme.error),
        ),

        // Borde cuando está enfocado y hay error
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizing.radiusMd),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),

        // Borde cuando está deshabilitado
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizing.radiusMd),
          // ignore: deprecated_member_use
          borderSide: BorderSide(color: theme.disabledColor.withOpacity(0.4)),
        ),
      ),
    );
  }
}
