// lib/features/auth/presentation/bloc/recuperar_clave/recuperar_clave_state.dart

import 'package:app_crm/index_dependencies.dart';

sealed class RecuperarClaveState extends Equatable {
  const RecuperarClaveState();
}

class RecuperarClaveInitial extends RecuperarClaveState {
  const RecuperarClaveInitial();

  @override
  List<Object> get props => [];
}

class RecuperarClaveCargando extends RecuperarClaveState {
  const RecuperarClaveCargando();

  @override
  List<Object> get props => [];
}

class RecuperarClaveExito extends RecuperarClaveState {
  const RecuperarClaveExito();

  @override
  List<Object> get props => [];
}

class RecuperarClaveError extends RecuperarClaveState {
  final String mensaje;

  const RecuperarClaveError(this.mensaje);

  @override
  List<Object> get props => [mensaje];
}
