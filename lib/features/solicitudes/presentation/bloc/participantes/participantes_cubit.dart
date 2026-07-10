// lib/features/solicitudes/presentation/bloc/participantes/participantes_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_crm/features/solicitudes/presentation/bloc/form/solicitud_form_cubit.dart';

part 'participantes_state.dart';

class ParticipantesCubit extends Cubit<ParticipantesState> {
  int _nextId = 1;

  ParticipantesCubit() : super(const ParticipantesState(participantes: []));

  void agregar(ParticipanteLocal participante) {
    final nuevo = participante.copyWith(id: _nextId++);
    emit(state.copyWith(
      participantes: [...state.participantes, nuevo],
    ));
  }

  void editar(ParticipanteLocal participante) {
    final actualizados = state.participantes.map((p) {
      return p.id == participante.id ? participante : p;
    }).toList();
    emit(state.copyWith(participantes: actualizados));
  }

  void eliminar(int id) {
    emit(state.copyWith(
      participantes: state.participantes.where((p) => p.id != id).toList(),
    ));
  }

  void eliminarTodos() {
    emit(state.copyWith(participantes: const []));
  }

  /// Refleja el switch "El solicitante será participante" (paso 1) en la
  /// lista de participantes: agrega/actualiza un registro marcado como
  /// [ParticipanteLocal.esSolicitante] con los datos ya capturados del
  /// solicitante, o lo retira si el switch se desactiva. Se llama cada vez
  /// que se presiona "Continuar" en el paso 1 — idempotente, nunca duplica.
  void sincronizarSolicitante(DatosSolicitante datos) {
    final resto = state.participantes.where((p) => !p.esSolicitante).toList();

    if (!datos.solicitanteEsParticipante) {
      emit(state.copyWith(participantes: resto));
      return;
    }

    final solicitanteParticipante = ParticipanteLocal(
      id: _nextId++,
      tipoDoc: datos.tipoDocLabel,
      numDoc: datos.numDoc,
      nacionalidad: datos.nacionalidad,
      nombres: datos.nombres,
      apellidoPaterno: datos.apellidoPaterno,
      apellidoMaterno: datos.apellidoMaterno,
      correo: datos.correo,
      cargo: datos.cargo,
      celular: datos.celular,
      celularCodigoTelefono: datos.celularCodigoTelefono,
      tipoParticipante: 'Pagante',
      importe: 0,
      esSolicitante: true,
    );

    emit(state.copyWith(
      participantes: [solicitanteParticipante, ...resto],
    ));
  }
}
