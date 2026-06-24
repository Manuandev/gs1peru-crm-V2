// lib/features/lead/presentation/cubit/negociaciones/negociaciones_cubit.dart

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/lead/presentation/cubit/negociaciones/negociaciones_state.dart';

class NegociacionesCubit extends Cubit<NegociacionesState> {
  NegociacionesCubit() : super(const NegociacionesInitial());

  Future<void> cargarNegociaciones(int leadId) async {
    emit(const NegociacionesLoading());
    try {
      // TODO: final result = await _repository.getNegociaciones(leadId);
      await Future.delayed(const Duration(milliseconds: 500));
      emit(const NegociacionesSuccess(negociaciones: _datosFake));
    } catch (e) {
      emit(NegociacionesError(mensaje: e.toString()));
    }
  }
}

const _datosFake = [
  NegociacionFake(
    nombre: 'Excel Avanzado - Junio 2026',
    empresa: 'GS1 México',
    idCanal: 5,
    cantidad: 1,
    ultimaActualizacion: '19/05/2026',
    idEstado: '01',
    estado: 'En desarrollo',
    accion: AccionNegociacion.seleccionada,
  ),
  NegociacionFake(
    nombre: 'Power BI Intermedio',
    empresa: 'GS1 México',
    idCanal: 5,
    cantidad: 1,
    ultimaActualizacion: '16/05/2026',
    idEstado: '02',
    estado: 'Propuesta enviada',
    accion: AccionNegociacion.verPropuesta,
  ),
  NegociacionFake(
    nombre: 'Excel Avanzado Corporativo',
    empresa: 'GS1 México',
    idCanal: 5,
    cantidad: 3,
    ultimaActualizacion: '10/05/2026',
    idEstado: '11',
    estado: 'Ganada',
    accion: AccionNegociacion.generarSolicitud,
  ),
];
