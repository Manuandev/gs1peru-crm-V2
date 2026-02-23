// lib/core/database/models/user_model.dart
// ============================================================
// USER MODEL — Global para toda la app.
// Vive solo en MEMORIA mientras la app está activa.
// Nunca se persiste en SQLite.
// Lo usan todos los features que necesiten datos del usuario.
// ============================================================

import 'package:app_crm/core/constants/app_constants.dart';

class UserModel {
  final String userId;
  final String token;
  final String codUser;
  final String userApe;
  final String correoUser;
  final String telefono;
  final String celular;

  const UserModel({
    required this.userId,
    required this.token,
    required this.codUser,
    required this.userApe,
    required this.correoUser,
    required this.telefono,
    required this.celular,
  });

  factory UserModel.fromRawString(String raw) {
    final sections = raw.split(AppConstants.sepListas);

    // Todo: reactivar cuando el API tenga formato fijo
    // if (sections.length != 3) {
    //   throw FormatException(
    //     'UserModel.fromRawString: se esperaban 3 secciones, '
    //     'se recibieron ${sections.length}.',
    //   );
    // }

    // Si no hay secciones suficientes, la cadena es solo el token o está vacía
    final token = sections.isNotEmpty ? sections[0] : '';
    final data = sections.length > 1 ? sections[1].trim() : '';
    final status = sections.length > 2 ? sections[2] : '';

    // Todo: reactivar cuando el servidor sea consistente con el status
    if (status != 'OK') {
      throw FormatException(data);
    }

    final fields = data.isNotEmpty
        ? data.split(AppConstants.sepCampos)
        : <String>[];

    // Todo: reactivar cuando los campos del API sean estables
    // if (fields.length < AppConstants.apiFieldCount) {
    //   throw FormatException(
    //     'UserModel.fromRawString: se esperaban ${AppConstants.apiFieldCount} '
    //     'campos, se recibieron ${fields.length}.',
    //   );
    // }

    // Helper: devuelve el campo o '' si el índice no existe
    String f(int i) => i < fields.length ? fields[i].trim() : '';

    return UserModel(
      token: token,
      userId: token,
      codUser: f(0),
      userApe: f(1),
      telefono: f(2),
      correoUser: f(3),
      celular: f(4),
    );
  }

  // Helper de UI — nombre completo para mostrar en pantalla
  String get fullName => userApe.trim();
}
