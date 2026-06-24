// lib/features/auth/presentation/bloc/recuperar_clave/recuperar_clave_event.dart

import 'package:app_crm/index_dependencies.dart';

abstract class RecuperarClaveEvent extends Equatable {
  const RecuperarClaveEvent();

  @override
  List<Object?> get props => [];
}

/// El usuario presionó "Enviar" con su correo electrónico.
class RecuperarClaveSubmitted extends RecuperarClaveEvent {
  final String correo;

  const RecuperarClaveSubmitted(this.correo);

  @override
  List<Object?> get props => [correo];
}
