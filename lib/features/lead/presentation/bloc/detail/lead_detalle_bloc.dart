// lib/features/lead/presentation/bloc/detail/lead_detalle_bloc.dart

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class LeadDetalleBloc extends Bloc<LeadDetalleEvent, LeadDetalleState> {
  LeadDetalleBloc() : super(const LeadDetalleInitial()) {
    on<LeadDetalleStarted>(_onStarted);
  }

  Future<void> _onStarted(
    LeadDetalleStarted event,
    Emitter<LeadDetalleState> emit,
  ) async {
    emit(const LeadDetalleLoading());
    await Future.delayed(const Duration(milliseconds: 400));

    // TODO: reemplazar con llamada real a BD usando event.idLead
    final ahora = DateTime.now();
    emit(
      LeadDetalleSuccess(
        detalle: LeadDetalleCompleto(
          idLead: event.idLead,
          nombre: 'Daniela',
          apellido: 'Gómez',
          nombreEmpresa: 'Estudio Creativo',
          telefono: '+51 987 654 321',
          correo: 'daniela@estudiocreativo.com',
          idCanal: 7,
          canal: 'Web',
          interes: 'Community Manager',
          idEstado: '00',
          estado: 'Nuevo',
          fechaUltimaInteraccion:
              ahora.subtract(const Duration(minutes: 3)).toString(),
        ),
        comentarios: [
          ComentarioLead(
            id: 1,
            texto:
                'Le envié información del curso por WhatsApp. Está interesada en la siguiente fecha.',
            fechaHora:
                ahora.subtract(const Duration(minutes: 5)).toString(),
            autor: 'Agente CRM',
          ),
          ComentarioLead(
            id: 2,
            texto:
                'Se le hizo seguimiento, solicitó información de precios y horarios.',
            fechaHora:
                ahora.subtract(const Duration(minutes: 31)).toString(),
            autor: 'Agente CRM',
          ),
          ComentarioLead(
            id: 3,
            texto: 'Primera consulta por Instagram, interesada en el curso.',
            fechaHora: ahora
                .subtract(const Duration(days: 1, hours: 1, minutes: 15))
                .toString(),
            autor: 'Agente CRM',
          ),
        ],
      ),
    );
  }
}
