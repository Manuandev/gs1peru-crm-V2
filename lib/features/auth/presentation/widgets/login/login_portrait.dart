// lib/features/auth/presentation/widgets/login_portrait_card.dart

import 'package:app_crm/core/presentation/widgets/buttons/custom_google_button.dart';
import 'package:flutter/material.dart';
import 'package:app_crm/core/constants/app_breakpoints.dart';
import 'package:app_crm/core/constants/app_icons.dart';
import 'package:app_crm/core/constants/app_spacing.dart';
import 'package:app_crm/core/constants/app_text_styles.dart';
import 'package:app_crm/core/presentation/widgets/buttons/custom_primary_button.dart';
import 'package:app_crm/core/presentation/widgets/buttons/custom_text_button.dart';
import 'package:app_crm/core/presentation/widgets/inputs/custom_password_field.dart';
import 'package:app_crm/core/presentation/widgets/inputs/custom_text_field.dart';
import 'package:app_crm/features/auth/presentation/controllers/login_form_controller.dart';

/// Card de login para orientación **portrait** (vertical).
///
/// Recibe un [LoginFormController] que contiene la [GlobalKey<FormState>]
/// y los [TextEditingController]s → sin duplicar keys, sin bugs de GlobalKey.
///
/// PARÁMETROS:
/// - [formController] → estado del formulario (key + controllers)
/// - [isLoading]      → deshabilita inputs y muestra spinner en botón
/// - [onSubmit]       → callback que dispara el evento al BLoC
/// - [onForgotPassword] → callback para "¿Olvidaste tu contraseña?"
class LoginPortrait extends StatelessWidget {
  const LoginPortrait({
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
    final size = MediaQuery.of(context).size;

    final isLandscape = size.width > size.height;
    final isSmallHeight = size.height < 500;
    final isTablet = size.width > 900;

    final compact = isLandscape && isSmallHeight;

    final double imageHeight = compact
        ? size.height * 0.25
        : isTablet
        ? size.height * 0.45
        : size.height * 0.35;

    return Card(
      elevation: AppSizing.elevationHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizing.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Form(
          key: formController.formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(
                'assets/images/logo_gs1.png',
                height: imageHeight,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Iniciar Sesión',
                style: AppTextStyles.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Ingresa tus credenciales',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              CustomGoogleButton(
                onPressed: isLoading ? null : onGoogleSignIn,
                isLoading:
                    false, // Google tiene su propio loading separado del form
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    child: Text('o continúa con'),
                  ),
                  Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: AppSpacing.md),
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
              const SizedBox(height: AppSpacing.md),
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
                valueListenable: formController.rememberSessionNotifier,
                builder: (context, value, _) {
                  return Row(
                    children: [
                      Checkbox(
                        value: value,
                        onChanged: isLoading
                            ? null
                            : (v) {
                                formController.rememberSessionNotifier.value =
                                    v ?? false;
                              },
                      ),
                      const Text('Recordar sesión'),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
              CustomPrimaryButton(
                text: 'INICIAR SESIÓN',
                onPressed: isLoading ? null : onSubmit,
                isLoading: isLoading,
              ),
              const SizedBox(height: AppSpacing.md),
              Center(
                child: CustomTextButton(
                  text: '¿Olvidaste tu contraseña?',
                  onPressed: isLoading ? null : onForgotPassword,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
