// lib/features/solicitudes/presentation/bloc/form/solicitud_form_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

part 'solicitud_form_state.dart';

class SolicitudFormCubit extends Cubit<SolicitudFormState> {
  SolicitudFormCubit() : super(const SolicitudFormState());

  /// 'Tipo de persona' (Jurídica/Natural) es un solo dato compartido por los
  /// pasos 1 y 3 del wizard — cambiarlo en cualquiera de los dos se refleja
  /// en el otro y en el resumen.
  void cambiarTipoPersona(String tipoPersona) =>
      emit(state.copyWith(tipoPersona: tipoPersona));

  void guardarSolicitante(DatosSolicitante datos) =>
      emit(state.copyWith(solicitante: datos));

  void guardarFacturacion(DatosFacturacion datos) =>
      emit(state.copyWith(facturacion: datos));

  /// Setea/actualiza el NUMSOL — llamado una vez al entrar al wizard (con
  /// el NUMSOL real si se edita una solicitud existente, o vacío si es
  /// creación) y de nuevo tras el primer guardado exitoso de una solicitud
  /// nueva, con el NUMSOL que generó el backend.
  void actualizarNumSol(String numSol) => emit(state.copyWith(numSol: numSol));
}
