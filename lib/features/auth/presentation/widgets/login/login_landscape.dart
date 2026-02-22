// lib/features/auth/presentation/widgets/login_landscape_card.dart

import 'package:app_crm/core/presentation/widgets/buttons/custom_google_button.dart';
import 'package:flutter/material.dart';
import 'package:app_crm/core/constants/app_breakpoints.dart';
import 'package:app_crm/core/constants/app_icons.dart';
import 'package:app_crm/core/constants/app_spacing.dart';
import 'package:app_crm/core/constants/app_text_styles.dart';
import 'package:app_crm/core/presentation/widgets/buttons/custom_primary_button.dart';
import 'package:app_crm/core/presentation/widgets/inputs/custom_password_field.dart';
import 'package:app_crm/core/presentation/widgets/inputs/custom_text_field.dart';
import 'package:app_crm/features/auth/presentation/controllers/login_form_controller.dart';

/// Layout completo de login para orientación **landscape** (horizontal).
///
/// ### FIX DEL OVERFLOW (BOTTOM OVERFLOWED BY X PIXELS)
/// El bug ocurría porque al aparecer el teclado software el viewport se
/// reduce, pero el contenido no tenía scroll → overflow.
/// Solución: cada columna usa [SingleChildScrollView] con
/// [physics: ClampingScrollPhysics()] para evitar el bounce de iOS que
/// se vería raro en un layout de dos columnas.
///
/// ESTRUCTURA:
/// ```
/// Row
/// ├── Expanded(flex:4) → columna decorativa (ícono + textos)  [scrollable]
/// └── Expanded(flex:6) → Card con el formulario               [scrollable]
/// ```
class LoginLandscape extends StatelessWidget {
  const LoginLandscape({
    super.key,
    required this.formController,
    required this.isLoading,
    required this.onSubmit,
    required this.onForgotPassword,
    required this.onGoogleSignIn,
  });

  final LoginFormController formController;
  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback onForgotPassword;
  final VoidCallback onGoogleSignIn;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── LADO IZQUIERDO DECORATIVO ──────────────────────────────────
          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              // FIX: permite scroll si el teclado achica el viewport
              physics: const ClampingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon(
                  //   AppIcons.lock,
                  //   size: AppSizing.iconXxl,
                  //   color: colorScheme.onPrimary,
                  // ),
                  // const SizedBox(height: AppSpacing.md),
                  Text(
                    'Iniciar Sesión',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: colorScheme.onPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Ingresa tus credenciales',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colorScheme.onPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  CustomGoogleButton(
                    onPressed: isLoading ? null : onGoogleSignIn,
                    isLoading: false, // Google tiene su propio loading
                  ),
                  // Center(
                  //   child: CustomTextButton(
                  //     text: '¿Olvidaste tu contraseña?',
                  //     onPressed: isLoading ? null : onForgotPassword,
                  //   ),
                  // ),
                ],
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.lg),
          Text(
            'O',
            style: AppTextStyles.headlineMedium.copyWith(
              color: colorScheme.onPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(width: AppSpacing.lg),
          // ── LADO DERECHO - CARD ────────────────────────────────────────
          Expanded(
            flex: 6,
            child: SingleChildScrollView(
              // FIX: permite scroll cuando el teclado sube el viewport
              physics: const ClampingScrollPhysics(),
              child: Card(
                elevation: AppSizing.elevationHigh,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizing.radiusLg),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                  child: Form(
                    // ⚠️ MISMO formKey que el portrait card.
                    // Sólo UN Form con esa key estará montado a la vez
                    // (porque OrientationBuilder reconstruye sólo uno).
                    key: formController.formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomTextField(
                          label: 'Usuario',
                          hint: 'Ingresa tu usuario',
                          controller: formController.usernameController,
                          enabled: !isLoading,
                          prefixIcon: const Icon(AppIcons.user),
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'El usuario es requerido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        CustomPasswordField(
                          label: 'Contraseña',
                          controller: formController.passwordController,
                          enabled: !isLoading,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => onSubmit(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'La contraseña es requerida';
                            }
                            // if (value.length < 6) {
                            //   return 'Mínimo 6 caracteres';
                            // }
                            return null;
                          },
                        ),
                        ValueListenableBuilder<bool>(
                          valueListenable:
                              formController.rememberSessionNotifier,
                          builder: (context, value, _) {
                            return Row(
                              children: [
                                Checkbox(
                                  value: value,
                                  onChanged: isLoading
                                      ? null
                                      : (v) {
                                          formController
                                                  .rememberSessionNotifier
                                                  .value =
                                              v ?? false;
                                        },
                                ),
                                const Text('Recordar sesión'),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        CustomPrimaryButton(
                          text: 'INICIAR SESIÓN',
                          onPressed: isLoading ? null : onSubmit,
                          isLoading: isLoading,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
