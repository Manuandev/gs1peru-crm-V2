// lib/features/auth/presentation/widgets/login/login_layout.dart
//
// ✅ UN solo archivo reemplaza login_portrait.dart + login_landscape.dart
//
// PATRÓN:
// 1. El contenido (logo, campos, botones) se define UNA sola vez
//    en pequeños widgets privados (_LogoSection, _FormSection, etc.)
// 2. El layout (_PortraitLayout / _LandscapeLayout) solo los ORDENA
// 3. OrientationBuilder elige cuál layout usar

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/auth/index_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class LoginLayout extends StatelessWidget {
  final LoginFormController formController;
  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback onForgotPassword;
  final VoidCallback onGoogleSignIn;

  const LoginLayout({
    super.key,
    required this.formController,
    required this.isLoading,
    required this.onSubmit,
    required this.onForgotPassword,
    required this.onGoogleSignIn,
  });

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        // ── Secciones de contenido (iguales en ambas orientaciones) ──
        final logo = _LogoSection();
        final google = _GoogleSection(
          isLoading: isLoading,
          onGoogleSignIn: onGoogleSignIn,
        );
        final form = _FormSection(
          formController: formController,
          isLoading: isLoading,
          onSubmit: onSubmit,
          onForgotPassword: onForgotPassword,
        );

        if (orientation == Orientation.landscape) {
          return _LandscapeLayout(logo: logo, google: google, form: form);
        }

        return _PortraitLayout(logo: logo, google: google, form: form);
      },
    );
  }
}

// ============================================================
// LAYOUTS — solo ordenan las secciones
// ============================================================

class _PortraitLayout extends StatelessWidget {
  final Widget logo;
  final Widget google;
  final Widget form;

  const _PortraitLayout({
    required this.logo,
    required this.google,
    required this.form,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Center(
                child: Padding(
                  padding: ResponsiveHelper.screenPadding(context),
                  child: Card(
                    elevation: AppSizing.elevationHigh,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizing.radiusLg),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          logo,
                          const SizedBox(height: AppSpacing.md),
                          google,
                          const SizedBox(height: AppSpacing.md),
                          _Divider(),
                          const SizedBox(height: AppSpacing.md),
                          form,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LandscapeLayout extends StatelessWidget {
  final Widget logo;
  final Widget google;
  final Widget form;

  const _LandscapeLayout({
    required this.logo,
    required this.google,
    required this.form,
  });

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
          // ── Lado izquierdo: logo + google ──────────────────
          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  logo,
                  const SizedBox(height: AppSpacing.md),
                  google,
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
          ),
          const SizedBox(width: AppSpacing.lg),

          // ── Lado derecho: formulario ───────────────────────
          Expanded(
            flex: 6,
            child: SingleChildScrollView(
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
                  child: form,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SECCIONES DE CONTENIDO — definidas UNA sola vez
// ============================================================

class _LogoSection extends StatelessWidget {
  const _LogoSection();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final logoSize = (size.shortestSide * 0.35).clamp(80.0, 160.0);

    return Center(
      child: SizedBox(
        width: logoSize,
        height: logoSize,
        child: SvgPicture.asset(
          AppImages.logoTheme(context),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _GoogleSection extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onGoogleSignIn;

  const _GoogleSection({
    required this.isLoading,
    required this.onGoogleSignIn,
  });

  @override
  Widget build(BuildContext context) {
    return CustomGoogleButton(
      onPressed: isLoading ? null : onGoogleSignIn,
      isLoading: false,
    );
  }
}

class _FormSection extends StatelessWidget {
  final LoginFormController formController;
  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback onForgotPassword;

  const _FormSection({
    required this.formController,
    required this.isLoading,
    required this.onSubmit,
    required this.onForgotPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formController.formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Usuario ──────────────────────────────────────
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

          // ── Contraseña ───────────────────────────────────
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
              return null;
            },
          ),

          // ── Recordar sesión ──────────────────────────────
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

          // ── Botón login ───────────────────────────────────
          CustomPrimaryButton(
            text: 'INICIAR SESIÓN',
            onPressed: isLoading ? null : onSubmit,
            isLoading: isLoading,
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Olvidé contraseña ─────────────────────────────
          Center(
            child: CustomTextButton(
              text: '¿Olvidaste tu contraseña?',
              onPressed: isLoading ? null : onForgotPassword,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text('o continúa con'),
        ),
        Expanded(child: Divider()),
      ],
    );
  }
}