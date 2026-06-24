// lib/features/lead/presentation/cubit/negociaciones/negociaciones_cubit.dart

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/lead/domain/entities/lead.dart';
import 'package:app_crm/features/lead/presentation/cubit/negociaciones/negociaciones_state.dart';

class NegociacionesCubit extends Cubit<NegociacionesState> {
  NegociacionesCubit() : super(const NegociacionesInitial());

  Future<void> cargarNegociaciones(int leadId) async {
    emit(const NegociacionesLoading());
    try {
      // TODO: reemplazar con SP real cuando esté disponible
      await Future.delayed(const Duration(milliseconds: 500));
      emit(const NegociacionesSuccess(negociaciones: _datosFake));
    } catch (e) {
      emit(NegociacionesError(mensaje: e.toString()));
    }
  }
}

// Datos de muestra mientras el SP de negociaciones no está implementado
const _datosFake = [
  Lead(
    idLead: 101,
    idContacto: 1,
    nombre: 'Excel Avanzado',
    apellido: '- Junio 2026',
    nombreEmpresa: 'GS1 México',
    asesor: '',
    fechaHora: '2026-05-19 00:00:00',
    idNumero: 1,
    prefijo: '+51',
    numero: '',
    isFavorito: false,
    correo: '',
    idEstado: '01',
    estado: 'En desarrollo',
    idCampania: 1,
    campania: '',
    idEvento: 1,
    evento: 'Excel Avanzado - Junio 2026',
    idCanal: 5,
    canal: 'Facebook',
    idInteres: 1,
    interes: '',
    ibChat: false,
    monto: 850.0,
  ),
  Lead(
    idLead: 102,
    idContacto: 1,
    nombre: 'Power BI',
    apellido: 'Intermedio',
    nombreEmpresa: 'GS1 México',
    asesor: '',
    fechaHora: '2026-05-16 00:00:00',
    idNumero: 1,
    prefijo: '+51',
    numero: '',
    isFavorito: false,
    correo: '',
    idEstado: '02',
    estado: 'Propuesta enviada',
    idCampania: 1,
    campania: '',
    idEvento: 2,
    evento: 'Power BI Intermedio',
    idCanal: 5,
    canal: 'Facebook',
    idInteres: 1,
    interes: '',
    ibChat: false,
    monto: 1200.0,
  ),
  Lead(
    idLead: 103,
    idContacto: 1,
    nombre: 'Excel Avanzado',
    apellido: 'Corporativo',
    nombreEmpresa: 'GS1 México',
    asesor: '',
    fechaHora: '2026-05-10 00:00:00',
    idNumero: 1,
    prefijo: '+51',
    numero: '',
    isFavorito: false,
    correo: '',
    idEstado: '11',
    estado: 'Ganada',
    idCampania: 1,
    campania: '',
    idEvento: 3,
    evento: 'Excel Avanzado Corporativo',
    idCanal: 5,
    canal: 'Facebook',
    idInteres: 1,
    interes: '',
    ibChat: false,
    monto: 2500.0,
  ),
];
