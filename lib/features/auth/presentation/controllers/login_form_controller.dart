// lib/features/auth/presentation/controllers/login_form_controller.dart

import 'package:flutter/material.dart';

/// Controlador de formulario de login.
///
/// Encapsula [FormKey], [TextEditingController]s y la lógica de validación.
/// Se pasa por referencia a los widgets hijos → sin prop drilling múltiple,
/// sin duplicar GlobalKey (que causaría el bug "Multiple widgets used the same GlobalKey").
///
/// CICLO DE VIDA:
/// - Instanciar en [_LoginViewState.initState] (o declarar como campo).
/// - Llamar [dispose] en [_LoginViewState.dispose].
///
/// USO:
/// ```dart
/// final _formCtrl = LoginFormController();
///
/// // Pasar a widgets hijos:
/// LoginPortraitCard(formController: _formCtrl, ...)
/// LoginLandscapeCard(formController: _formCtrl, ...)
///
/// // Validar + obtener valores:
/// if (_formCtrl.validate()) {
///   final username = _formCtrl.username; // ya hace trim()
///   final password = _formCtrl.password;
/// }
/// ```
class LoginFormController {
  LoginFormController();

  /// Key única del formulario.
  /// NUNCA crear dentro de un build() → causaría rebuild infinito.
  final formKey = GlobalKey<FormState>();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ValueNotifier<bool> rememberSessionNotifier = ValueNotifier(false);
  bool get rememberSession => rememberSessionNotifier.value;

  /// Texto del usuario (trimmed).
  String get username => usernameController.text.trim();

  /// Texto de la contraseña (sin trim, los espacios son válidos en passwords).
  String get password => passwordController.text;

  /// Valida el formulario y retorna true si todo es correcto.
  bool validate() => formKey.currentState?.validate() ?? false;

  /// Limpia ambos campos (útil tras un error de auth).
  void clearPassword() => passwordController.clear();

  /// Liberar recursos. Llamar en [State.dispose].
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    rememberSessionNotifier.dispose();
  }
}
