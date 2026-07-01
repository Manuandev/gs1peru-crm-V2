// lib/features/solicitudes/presentation/bloc/form/solicitud_form_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

part 'solicitud_form_state.dart';

class SolicitudFormCubit extends Cubit<SolicitudFormState> {
  SolicitudFormCubit() : super(const SolicitudFormState());

  void guardarSolicitante(DatosSolicitante datos) =>
      emit(state.copyWith(solicitante: datos));

  void guardarFacturacion(DatosFacturacion datos) =>
      emit(state.copyWith(facturacion: datos));
}
