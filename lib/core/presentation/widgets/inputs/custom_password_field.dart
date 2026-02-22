// lib/core/presentation/widgets/inputs/custom_password_field.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/constants/app_icons.dart';
import 'custom_text_field.dart';

/// CustomPasswordField — Input de contraseña con toggle de visibilidad
///
/// PROPÓSITO:
/// - Encapsula el comportamiento de mostrar/ocultar contraseña
/// - Usa [AppIcons.lock] como prefijo y [AppIcons.visibility] / [AppIcons.visibilityOff]
///   como botón de toggle — todos desde el catálogo centralizado [AppIcons]
/// - Delega el estilo visual a [CustomTextField]
///
/// DEPENDENCIAS DEL SISTEMA DE DISEÑO:
/// - Íconos → [AppIcons.lock], [AppIcons.visibility], [AppIcons.visibilityOff]
/// - Colores → [AppColors.grey600] para íconos en estado normal
///
/// USO BÁSICO:
/// ```dart
/// CustomPasswordField(
///   label: 'Contraseña',
///   controller: _passwordController,
/// )
/// ```
///
/// CON VALIDACIÓN CUSTOM:
/// ```dart
/// CustomPasswordField(
///   label: 'Nueva contraseña',
///   helperText: 'Mínimo 8 caracteres',
///   controller: _newPasswordController,
///   validator: (value) {
///     if (value == null || value.length < 8) return 'Mínimo 8 caracteres';
///     return null;
///   },
/// )
/// ```
///
/// SIN BOTÓN DE TOGGLE (ej: confirmar contraseña):
/// ```dart
/// CustomPasswordField(
///   label: 'Confirmar contraseña',
///   showToggleButton: false,
///   controller: _confirmController,
/// )
/// ```
class CustomPasswordField extends StatefulWidget {
  // Label flotante del campo
  final String? label;
  // Placeholder cuando está vacío
  final String? hint;
  // Texto de ayuda debajo del campo
  final String? helperText;
  // Controlador del texto
  final TextEditingController? controller;
  // Función de validación — devuelve null si es válido
  final String? Function(String?)? validator;
  // Callback al cambiar el texto
  final void Function(String)? onChanged;
  // Callback al presionar la acción del teclado
  final void Function(String)? onSubmitted;
  // Acción del teclado virtual (default: done)
  final TextInputAction? textInputAction;
  // Si el campo acepta interacción
  final bool enabled;
  // Si se muestra el botón de toggle ojo/ocultar
  final bool showToggleButton;
  // FocusNode para control externo del foco
  final FocusNode? focusNode;

  const CustomPasswordField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.enabled = true,
    this.showToggleButton = true,
    this.focusNode,
  });

  @override
  State<CustomPasswordField> createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  /// Estado interno: true = texto oculto (•••), false = texto visible
  bool _obscureText = true;

  /// Alterna entre mostrar y ocultar el texto del campo
  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: widget.label ?? 'Contraseña',
      hint: widget.hint,
      helperText: widget.helperText,
      controller: widget.controller,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      textInputAction: widget.textInputAction ?? TextInputAction.done,
      enabled: widget.enabled,
      keyboardType: TextInputType.visiblePassword,
      autocorrect: false,
      focusNode: widget.focusNode,
      obscureText: _obscureText,

      // ── PREFIJO: ícono de candado ────────────────────────────
      // AppIcons.lock → centralizado en el catálogo de íconos
      prefixIcon: const Icon(AppIcons.lock),

      // ── SUFIJO: botón toggle de visibilidad ──────────────────
      // Muestra AppIcons.visibility cuando el texto está oculto (•••)
      // Muestra AppIcons.visibilityOff cuando el texto está visible
      suffixIcon: widget.showToggleButton
          ? IconButton(
              icon: Icon(
                _obscureText ? AppIcons.visibilityOff : AppIcons.visibility,
              ),
              onPressed: widget.enabled ? _toggleVisibility : null,
              tooltip: _obscureText
                  ? 'Mostrar contraseña'
                  : 'Ocultar contraseña',
            )
          : null,
    );
  }
}
