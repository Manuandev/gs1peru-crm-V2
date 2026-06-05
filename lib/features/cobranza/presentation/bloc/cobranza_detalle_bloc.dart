// lib/features/cobranza/presentation/bloc/cobranza_detalle_bloc.dart

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaDetalleBloc
    extends Bloc<CobranzaDetalleEvent, CobranzaDetalleState> {
  CobranzaDetalleBloc() : super(const CobranzaDetalleInitial()) {
    on<CobranzaDetalleStarted>(_onStarted);
  }

  Future<void> _onStarted(
    CobranzaDetalleStarted event,
    Emitter<CobranzaDetalleState> emit,
  ) async {
    emit(const CobranzaDetalleLoading());
    await Future.delayed(const Duration(milliseconds: 400));

    // TODO: reemplazar con llamada real a BD usando event.idCobranza
    // final result = await _api.postSafe(ApiConstants.urlCobranzasLst, body);
    emit(CobranzaDetalleSuccess(_mockDetalle(event.idCobranza)));
  }

  CobranzaDetalle _mockDetalle(int idCobranza) => CobranzaDetalle(
        idCobranza: idCobranza,
        nombre: 'Lina Sachi',
        apellido: 'Minaya Guzman',
        oportunidad: 'Curso Demand planning & Forecasting',
        ejecutivo: 'Julio Flores',
        montoTotal: 711.45,
        idEstado: 'PD',
        estado: 'Pend. documento',
        idCondicion: 'C',
        condicion: 'Contado',
        fechaSolicitud: '14/05/2026',
        tipoComprobante: 'Boleta',
        correo: 'lina.minaya@gmail.com',
        celular: '+51 987 654 321',
        observacion: 'Cliente solicitó boleta. Coordinar envío por correo.',
        historial: const [
          HistorialCobranza(
            idTipo: 'registro',
            titulo: 'Solicitud registrada',
            descripcion: 'La solicitud fue registrada en el sistema.',
            fecha: '14/05/2026',
            hora: '09:15 a.m.',
            ejecutivo: 'Julio Flores',
          ),
          HistorialCobranza(
            idTipo: 'estado',
            titulo: 'Pendiente de documento',
            descripcion:
                'Se está gestionando la emisión de la boleta/factura.',
            fecha: '14/05/2026',
            hora: '11:32 a.m.',
            ejecutivo: 'Julio Flores',
          ),
          HistorialCobranza(
            idTipo: 'recordatorio',
            titulo: 'Recordatorio enviado',
            descripcion: 'Se envió recordatorio al cliente por WhatsApp.',
            fecha: '15/05/2026',
            hora: '04:48 p.m.',
            ejecutivo: 'Julio Flores',
          ),
        ],
      );
}
