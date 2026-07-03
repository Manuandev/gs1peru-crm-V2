// lib/features/auth/presentation/widgets/login/login_view.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/auth/index_auth.dart';
import 'package:flutter/material.dart';

/// LoginView — zona azul con ilustración + cartilla blanca flotante.
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

  // Viene de ConfiguracionService (grupo TLA), cargado en SplashBloc
  // apenas arranca la app — ver ConfiguracionRemoteDatasource (task 'CA').
  final TipoLoginApp _tipoLogin = ConfiguracionService().tipoLogin;

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
    context.goToRecuperarClave();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      // Fondo azul para que los bordes redondeados de la cartilla
      // muestren el color primario en las esquinas superiores.
      backgroundColor: AppColors.primary,
      body: BlocConsumer<LoginBloc, LoginState>(
        listenWhen: (_, current) =>
            current is LoginSuccess || current is LoginFailure,
        buildWhen: (prev, curr) =>
            (prev is LoginLoading) != (curr is LoginLoading),
        listener: (context, state) {
          if (state is LoginSuccess) {
            // AppSnackBar.success(context, '¡Bienvenido ${state.username}!');
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
            tipoLogin: _tipoLogin,
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
  final TipoLoginApp tipoLogin;
  final VoidCallback onLogin;
  final VoidCallback onGoogleLogin;
  final VoidCallback onForgotPassword;

  const _CuerpoLogin({
    required this.formController,
    required this.esCargando,
    required this.tipoLogin,
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

        // ── Cartilla blanca flotante — se monta AppSpacing.xl sobre la ola ──
        Expanded(
          child: Container(
            color: AppColors.surface,
            child: SingleChildScrollView(
              clipBehavior: Clip.none,
              physics: const ClampingScrollPhysics(),
              child: Transform.translate(
                offset: const Offset(0, -AppSpacing.xl),
                child: _CartillaBlanca(
                  formController: formController,
                  esCargando: esCargando,
                  tipoLogin: tipoLogin,
                  onLogin: onLogin,
                  onGoogleLogin: onGoogleLogin,
                  onForgotPassword: onForgotPassword,
                ),
              ),
            ),
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Lado izquierdo: logo + textos ──────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      Text(
                        'Bienvenido',
                        style: AppTextStyles.headlineLarge2.copyWith(
                          color: AppColors.textOnDark,
                          fontWeight: AppTextStyles.weightBold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
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
// CARTILLA BLANCA FLOTANTE
// ============================================================

class _CartillaBlanca extends StatelessWidget {
  final LoginFormController formController;
  final bool esCargando;
  final TipoLoginApp tipoLogin;
  final VoidCallback onLogin;
  final VoidCallback onGoogleLogin;
  final VoidCallback onForgotPassword;

  const _CartillaBlanca({
    required this.formController,
    required this.esCargando,
    required this.tipoLogin,
    required this.onLogin,
    required this.onGoogleLogin,
    required this.onForgotPassword,
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
        AppSpacing.lg,
      ),
      child: Column(
        children: [
          // ── Cabecera de la cartilla ─────────────────────────────
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

          // ── Botón Google ─────────────────────────────────────────
          if (tipoLogin.mostrarGoogle)
            CustomGoogleButton(
              onPressed: esCargando ? null : onGoogleLogin,
              isLoading: esCargando && tipoLogin == TipoLoginApp.google,
            ),

          // ── Divisor (solo cuando se muestran ambas opciones) ────
          if (tipoLogin.mostrarGoogle && tipoLogin.mostrarCredenciales) ...[
            const SizedBox(height: AppSpacing.md),
            const LoginDivisorWidget(),
            const SizedBox(height: AppSpacing.md),
          ],

          // ── Formulario de credenciales ───────────────────────────
          if (tipoLogin.mostrarCredenciales)
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
