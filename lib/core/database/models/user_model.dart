// lib/core/database/models/user_model.dart
// ============================================================
// USER MODEL — Global para toda la app.
// Vive solo en MEMORIA mientras la app está activa.
// Nunca se persiste en SQLite.
// Lo usan todos los features que necesiten datos del usuario.
// ============================================================

class UserModel {
  final String userId;
  final String username;
  final String token;
  final String codUser;
  final String userApe;
  final String tipoUser;
  final String cargUser;
  final String correoUser;
  final String telefono;
  final String anexo;
  final String celular;
  final String disponibilidad;
  final String idTipouser;

  const UserModel({
    required this.userId,
    required this.username,
    required this.token,
    required this.codUser,
    required this.userApe,
    required this.tipoUser,
    required this.cargUser,
    required this.correoUser,
    required this.telefono,
    required this.anexo,
    required this.celular,
    required this.disponibilidad,
    required this.idTipouser,
  });

  // Todo: ajusta los keys según la respuesta real de tu API
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['IdUsuario']?.toString() ?? '',
      username: json['COD_USER']?.toString() ?? '',
      token: json['Token']?.toString() ?? '',
      codUser: json['CodUser']?.toString() ?? '',
      userApe: json['USER_APE']?.toString() ?? '',
      tipoUser: json['TIPO_USER']?.toString() ?? '',
      cargUser: json['CARGUSER']?.toString() ?? '',
      correoUser: json['CORREO_USER']?.toString() ?? '',
      telefono: json['TELEFONO']?.toString() ?? '',
      anexo: json['ANEXO']?.toString() ?? '',
      celular: json['CELULAR']?.toString() ?? '',
      disponibilidad: json['DISPONIBILIDAD']?.toString() ?? '',
      idTipouser: json['ID_TIPOUSER']?.toString() ?? '',
    );
  }

  // Helper de UI — nombre completo para mostrar en pantalla
  String get fullName => '$username $userApe'.trim();
}
