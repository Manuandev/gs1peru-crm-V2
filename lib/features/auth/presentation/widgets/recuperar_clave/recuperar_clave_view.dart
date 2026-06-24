// lib/features/auth/presentation/widgets/recuperar_clave/recuperar_clave_view.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/auth/index_auth.dart';

/// RecuperarClaveView — pantalla "Olvidé mi clave".
///
/// Misma estructura visual que el login: zona azul con ilustración + cartilla
/// blanca flotante con el formulario de correo.
class RecuperarClaveView extends StatefulWidget {
  const RecuperarClaveView({super.key});

  @override
  State<RecuperarClaveView> createState() => _RecuperarClaveViewState();
}

class _RecuperarClaveViewState extends State<RecuperarClaveView> {
  final _correoController = TextEditingController();

  @override
  void dispose() {
    _correoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.primary,
      body: BlocConsumer<RecuperarClaveBloc, RecuperarClaveState>(
        listener: (context, state) {
          if (state is RecuperarClaveExito) {
            AppSnackBar.success(
              context,
              'Te enviamos tu usuario y clave al correo ingresado',
            );
            context.goToLogin();
          }
          if (state is RecuperarClaveError) {
            AppSnackBar.error(context, state.mensaje);
          }
        },
        builder: (context, state) {
          final estaCargando = state is RecuperarClaveCargando;
          return Column(
            children: [
              // ── Zona azul con ilustración ───────────────────────
              _ZonaAzulRecuperar(),

              // ── Cartilla blanca flotante ────────────────────────
              Expanded(
                child: Container(
                  color: AppColors.surface,
                  child: SingleChildScrollView(
                    clipBehavior: Clip.none,
                    physics: const ClampingScrollPhysics(),
                    child: Transform.translate(
                      offset: const Offset(0, -AppSpacing.xl),
                      child: _CartillaRecuperar(
                        correoController: _correoController,
                        estaCargando: estaCargando,
                        onEnviar: () => context
                            .read<RecuperarClaveBloc>()
                            .add(RecuperarClaveSubmitted(_correoController.text)),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================
// ZONA AZUL (header con botón back, logo, título e ilustración)
// ============================================================

class _ZonaAzulRecuperar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final alturaPantalla = MediaQuery.of(context).size.height;
    final alturaZona = (alturaPantalla * 0.42).clamp(220.0, 340.0);

    return ClipPath(
      clipper: const AuthOlaClipper(),
      child: Container(
        width: double.infinity,
        height: alturaZona,
        color: AppColors.primary,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.xxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Fila: botón back + logo ─────────────────────
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.goToLogin(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.white(0.20),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: const Icon(
                          AppIcons.back,
                          color: AppColors.textOnDark,
                          size: AppSizing.iconMd,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    SizedBox(
                      width: AppSizing.loginLogoSize,
                      height: AppSizing.loginLogoSize,
                      child: SvgPicture.asset(
                        AppImages.logoGs1PeruBlanco,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'CRM Perú',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.textOnDark,
                        fontWeight: AppTextStyles.weightSemiBold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                // ── Fila: título + ilustración ──────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Olvidé mi clave',
                            style: AppTextStyles.headlineLarge.copyWith(
                              color: AppColors.textOnDark,
                              fontWeight: AppTextStyles.weightBold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Ingresa tu correo y te enviaremos\ntu usuario y clave.',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.white(0.75),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const RecuperarClaveIlustracionWidget(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CARTILLA BLANCA FLOTANTE
// ============================================================

class _CartillaRecuperar extends StatelessWidget {
  final TextEditingController correoController;
  final bool estaCargando;
  final VoidCallback onEnviar;

  const _CartillaRecuperar({
    required this.correoController,
    required this.estaCargando,
    required this.onEnviar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSizing.authCardRadius),
          topRight: Radius.circular(AppSizing.authCardRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black(0.10),
            blurRadius: AppSizing.shadowBlurLg,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: Column(
        children: [
          // ── Ícono de sobre en círculo ───────────────────────────
          Container(
            width: AppSizing.iconXl + AppSpacing.md,
            height: AppSizing.iconXl + AppSpacing.md,
            decoration: BoxDecoration(
              color: AppColors.primaryWithOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              AppIcons.email,
              size: AppSizing.iconMd,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Título ─────────────────────────────────────────────
          Text(
            'Recuperar acceso',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: AppTextStyles.weightSemiBold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),

          // ── Subtítulo ──────────────────────────────────────────
          Text(
            'Ingresa tu correo y te enviaremos tu usuario y clave.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Campo correo ───────────────────────────────────────
          CustomTextField(
            label: 'Correo',
            hint: 'Ingresa tu correo electrónico',
            controller: correoController,
            enabled: !estaCargando,
            prefixIcon: const Icon(AppIcons.email),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onEnviar(),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Botón enviar ───────────────────────────────────────
          CustomPrimaryButton(
            text: 'Enviar',
            onPressed: estaCargando ? null : onEnviar,
            isLoading: estaCargando,
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Divisor ────────────────────────────────────────────
          const LoginDivisorWidget(),
          const SizedBox(height: AppSpacing.md),

          // ── Volver al inicio de sesión ─────────────────────────
          CustomTextButton(
            text: 'Volver al inicio de sesión',
            onPressed: () => context.goToLogin(),
            textColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
