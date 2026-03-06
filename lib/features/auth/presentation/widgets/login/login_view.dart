import 'package:app_crm/config/index_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_crm/features/auth/index_auth.dart';

/// LoginView — StatefulWidget que:
/// 1. Posee el LoginFormController (ciclo de vida controlado aquí).
/// 2. Escucha el LoginBloc y reacciona a sus estados.
/// 3. Delega el UI a LoginPortraitCard / LoginLandscapeCard.
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  /// Controlador único del formulario.
  /// GlobalKey compartida entre portrait y landscape (solo uno montado a la vez).
  late final LoginFormController _formController;

  @override
  void initState() {
    super.initState();
    _formController = LoginFormController();
  }

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }

  /// Valida el formulario y dispara el evento de login al LoginBloc.
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
    context.showSnackBar('Contacta al administrador');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BlocConsumer<LoginBloc, LoginState>(
        // Solo escucha estados finales para acciones
        listenWhen: (_, current) =>
            current is LoginSuccess || current is LoginFailure,

        listener: (context, state) {
          if (state is LoginSuccess) {
            // ✅ Notifica al AuthBloc → AppWidget navega al Home
            context.showSuccessSnack('¡Bienvenido ${state.username}!');
            context.read<AuthBloc>().add(
              AuthLoginSuccess(userId: state.userId, username: state.username),
            );
          }

          if (state is LoginFailure) {
            // ❌ Login fallido → mostrar error y limpiar contraseña
            context.showErrorSnack(state.message);
            _formController.clearPassword();
          }
        },

        builder: (context, state) {
          final isLoading = state is LoginLoading;

          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [colorScheme.primary, colorScheme.primaryContainer],
              ),
            ),
            child: SafeArea(
              child: OrientationBuilder(
                builder: (context, orientation) {
                  return LoginLayout(
                    formController: _formController,
                    isLoading: isLoading,
                    onSubmit: _handleLogin,
                    onForgotPassword: _handleForgotPassword,
                    onGoogleSignIn: _handleGoogleLogin,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
