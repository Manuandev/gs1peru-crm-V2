// lib/core/presentation/widgets/inputs/custom_email_field.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/constants/app_icons.dart';
import 'custom_text_field.dart';

/// CustomEmailField — Input de email con validación de formato incluida
///
/// PROPÓSITO:
/// - Encapsula teclado de email, capitalización none y autocorrect false
/// - Valida formato de email con expresión regular estándar
/// - Usa [AppIcons.email] como prefijo desde el catálogo centralizado
///
/// DEPENDENCIAS DEL SISTEMA DE DISEÑO:
/// - Íconos → [AppIcons.email]
/// - Colores → [AppColors.grey600]
///
/// USO CON VALIDADOR POR DEFECTO:
/// ```dart
/// CustomEmailField(
///   controller: _emailController,
///   onSubmitted: (_) => _focusPassword(),
/// )
/// ```
///
/// USO CON VALIDADOR CUSTOM:
/// ```dart
/// CustomEmailField(
///   label: 'Email corporativo',
///   hint: 'nombre@empresa.com',
///   controller: _emailController,
///   validator: (value) {
///     if (value?.endsWith('@empresa.com') != true) {
///       return 'Debe ser email corporativo';
///     }
///     return null;
///   },
/// )
/// ```
class CustomEmailField extends StatelessWidget {
  // Label flotante del campo (default: 'Email')
  final String? label;
  // Placeholder cuando está vacío (default: 'ejemplo@correo.com')
  final String? hint;
  // Controlador del texto
  final TextEditingController? controller;
  // Función de validación — si null, usa [defaultValidator]
  final String? Function(String?)? validator;
  // Callback al cambiar el texto
  final void Function(String)? onChanged;
  // Callback al presionar la acción del teclado
  final void Function(String)? onSubmitted;
  // Si el campo acepta interacción
  final bool enabled;
  // FocusNode para control externo del foco
  final FocusNode? focusNode;

  const CustomEmailField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.focusNode,
  });

  /// Validador de email por defecto.
  ///
  /// Verifica:
  /// 1. Que no esté vacío
  /// 2. Que tenga formato válido: usuario@dominio.ext
  static String? defaultValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'El email es requerido';
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) return 'Ingresa un email válido';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: label ?? 'Email',
      hint: hint ?? 'ejemplo@correo.com',
      controller: controller,
      validator: validator ?? defaultValidator,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      enabled: enabled,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autocorrect: false,
      textCapitalization: TextCapitalization.none,
      focusNode: focusNode,
      // ── PREFIJO: ícono de email ──────────────────────────────
      // AppIcons.email → centralizado en el catálogo de íconos
      prefixIcon: const Icon(AppIcons.email),
    );
  }
}
