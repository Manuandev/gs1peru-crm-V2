// lib/features/auth/presentation/widgets/login/login_view.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/auth/index_auth.dart';
import 'package:flutter/material.dart';

/// LoginView — rediseño completo con zona azul + ilustración + ola + zona blanca.
///
/// La lógica de negocio (BLoC, handlers) vive aquí.
/// Los sub-widgets de UI están extraídos a archivos en widgets/login/.
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final LoginFormController _formController;

  // TODO(backend): este valor vendrá de los parámetros generales traídos en
  // SplashBloc cuando se implemente la integración con el SP de configuración.
  // Por ahora se hardcodea para desarrollo. Cambiar el valor aquí para probar
  // los tres modos: ModoAutenticacion.soloGoogle | soloCredenciales | ambos
  final ModoAutenticacion _modoAutenticacion = ModoAutenticacion.ambos;

  @override
  void initState() {
    super.initState();
    _formController = LoginFormController();

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthUnauthenticated) {
      _formController.setInitialData(
        authState.prefillUsername,
        authState.prefillPassword,
      );
    }
  }

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (!_formController.validate()) return;
    context.read<LoginBloc>().add(
      LoginSubmitted(
        username: _formController.username,
        password: _formController.password,
        rememberSession: _formController.rememberSession,
      ),
    );
  }

  void _handleGoogleLogin() {
    context.read<LoginBloc>().add(const LoginWithGoogleSubmitted());
  }

  void _handleForgotPassword() {
    AppSnackBar.info(context, 'Contacta al administrador');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.surface,
      body: BlocConsumer<LoginBloc, LoginState>(
        listenWhen: (_, current) =>
            current is LoginSuccess || current is LoginFailure,
        buildWhen: (prev, curr) =>
            (prev is LoginLoading) != (curr is LoginLoading),
        listener: (context, state) {
          if (state is LoginSuccess) {
            AppSnackBar.success(context, '¡Bienvenido ${state.username}!');
            context.read<AuthBloc>().add(
              AuthLoginSuccess(userId: state.userId, username: state.username),
            );
          }
          if (state is LoginFailure) {
            AppSnackBar.error(context, state.message);
            _formController.clearPassword();
          }
        },
        builder: (context, state) {
          final esCargando = state is LoginLoading;
          return _CuerpoLogin(
            formController: _formController,
            esCargando: esCargando,
            modoAutenticacion: _modoAutenticacion,
            onLogin: _handleLogin,
            onGoogleLogin: _handleGoogleLogin,
            onForgotPassword: _handleForgotPassword,
          );
        },
      ),
    );
  }
}

// ============================================================
// CUERPO PRINCIPAL
// ============================================================

class _CuerpoLogin extends StatelessWidget {
  final LoginFormController formController;
  final bool esCargando;
  final ModoAutenticacion modoAutenticacion;
  final VoidCallback onLogin;
  final VoidCallback onGoogleLogin;
  final VoidCallback onForgotPassword;

  const _CuerpoLogin({
    required this.formController,
    required this.esCargando,
    required this.modoAutenticacion,
    required this.onLogin,
    required this.onGoogleLogin,
    required this.onForgotPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Zona azul con ilustración y ola ────────────────────────
        _ZonaAzul(),

        // ── Zona blanca con formulario ─────────────────────────────
        Expanded(
          child: _ZonaBlanca(
            formController: formController,
            esCargando: esCargando,
            modoAutenticacion: modoAutenticacion,
            onLogin: onLogin,
            onGoogleLogin: onGoogleLogin,
            onForgotPassword: onForgotPassword,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// ZONA AZUL (header con logo, título e ilustración)
// ============================================================

class _ZonaAzul extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final alturaPantalla = MediaQuery.of(context).size.height;
    // La zona azul ocupa ~42% de la pantalla con un mínimo razonable
    final alturaZona = (alturaPantalla * 0.42).clamp(220.0, 340.0);

    return ClipPath(
      clipper: const LoginOlaClipper(),
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Lado izquierdo: logo + textos ──────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo GS1 blanco + texto "CRM Perú"
                      Row(
                        children: [
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
                      // Título "Bienvenido"
                      Text(
                        'Bienvenido',
                        style: AppTextStyles.headlineLarge.copyWith(
                          color: AppColors.textOnDark,
                          fontWeight: AppTextStyles.weightBold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      // Subtítulo descriptivo
                      Text(
                        'Ingresa para gestionar conversaciones, prospectos y cobranzas.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.white(0.75),
                        ),
                      ),
                    ],
                  ),
                ),
                // ── Lado derecho: ilustración ───────────────────────
                const LoginIlustracionWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ZONA BLANCA (formulario según modo de autenticación)
// ============================================================

class _ZonaBlanca extends StatelessWidget {
  final LoginFormController formController;
  final bool esCargando;
  final ModoAutenticacion modoAutenticacion;
  final VoidCallback onLogin;
  final VoidCallback onGoogleLogin;
  final VoidCallback onForgotPassword;

  const _ZonaBlanca({
    required this.formController,
    required this.esCargando,
    required this.modoAutenticacion,
    required this.onLogin,
    required this.onGoogleLogin,
    required this.onForgotPassword,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: Column(
        children: [
          // ── Cabecera de la zona blanca ──────────────────────────
          Text(
            'Accede a tu cuenta',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Elige el método que prefieras para ingresar',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Botón Google (solo en soloGoogle y ambos) ───────────
          if (modoAutenticacion == ModoAutenticacion.soloGoogle ||
              modoAutenticacion == ModoAutenticacion.ambos)
            CustomGoogleButton(
              onPressed: esCargando ? null : onGoogleLogin,
              isLoading:
                  esCargando &&
                  modoAutenticacion == ModoAutenticacion.soloGoogle,
            ),

          // ── Divisor (solo en ambos) ─────────────────────────────
          if (modoAutenticacion == ModoAutenticacion.ambos) ...[
            const SizedBox(height: AppSpacing.md),
            const LoginDivisorWidget(),
            const SizedBox(height: AppSpacing.md),
          ],

          // ── Formulario de credenciales (soloCredenciales y ambos) ─
          if (modoAutenticacion == ModoAutenticacion.soloCredenciales ||
              modoAutenticacion == ModoAutenticacion.ambos)
            _FormularioCredenciales(
              formController: formController,
              esCargando: esCargando,
              onLogin: onLogin,
              onForgotPassword: onForgotPassword,
            ),
        ],
      ),
    );
  }
}

// ============================================================
// FORMULARIO DE CREDENCIALES
// ============================================================

class _FormularioCredenciales extends StatelessWidget {
  final LoginFormController formController;
  final bool esCargando;
  final VoidCallback onLogin;
  final VoidCallback onForgotPassword;

  const _FormularioCredenciales({
    required this.formController,
    required this.esCargando,
    required this.onLogin,
    required this.onForgotPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formController.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Campo usuario ─────────────────────────────────────
          CustomTextField(
            label: 'Usuario',
            hint: 'Ingresa tu usuario',
            controller: formController.usernameController,
            enabled: !esCargando,
            prefixIcon: const Icon(AppIcons.user),
            textInputAction: TextInputAction.next,
            isUpperCase: true,
            validator: (valor) {
              if (valor == null || valor.trim().isEmpty) {
                return 'El usuario es requerido';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Campo clave ───────────────────────────────────────
          CustomPasswordField(
            label: 'Clave',
            hint: 'Ingresa tu clave',
            controller: formController.passwordController,
            enabled: !esCargando,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onLogin(),
            validator: (valor) {
              if (valor == null || valor.isEmpty) {
                return 'La clave es requerida';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.xs),

          // ── Fila: recordar sesión + olvidé mi clave ───────────
          _FilaRecordarForgot(
            formController: formController,
            esCargando: esCargando,
            onForgotPassword: onForgotPassword,
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Botón ingresar ────────────────────────────────────
          CustomPrimaryButton(
            text: 'Ingresar',
            onPressed: esCargando ? null : onLogin,
            isLoading: esCargando,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// FILA RECORDAR SESIÓN + OLVIDÉ MI CLAVE
// ============================================================

class _FilaRecordarForgot extends StatelessWidget {
  final LoginFormController formController;
  final bool esCargando;
  final VoidCallback onForgotPassword;

  const _FilaRecordarForgot({
    required this.formController,
    required this.esCargando,
    required this.onForgotPassword,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: formController.rememberSessionNotifier,
      builder: (context, recordar, _) {
        return Row(
          children: [
            // Checkbox + etiqueta
            GestureDetector(
              onTap: esCargando
                  ? null
                  : () {
                      formController.rememberSessionNotifier.value = !recordar;
                    },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: recordar,
                    onChanged: esCargando
                        ? null
                        : (v) {
                            formController.rememberSessionNotifier.value =
                                v ?? false;
                          },
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  Text(
                    'Mantener sesión activa',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Enlace olvidé mi clave
            TextButton(
              onPressed: esCargando ? null : onForgotPassword,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Olvidé mi clave',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.secondary,
                  fontWeight: AppTextStyles.weightMedium,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
