// lib/features/solicitudes/presentation/bloc/participantes/participantes_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

part 'participantes_state.dart';

class ParticipantesCubit extends Cubit<ParticipantesState> {
  int _nextId = 1;

  ParticipantesCubit()
      : super(
          ParticipantesState(
            participantes: [
              ParticipanteLocal(
                id: 1,
                tipoDoc: 'PASAPORTE',
                numDoc: '057588685',
                nombre: 'JOSE EDUARDO POSADA PEÑA',
                celular: '503-76713284',
                nacionalidad: 'SALVADOREÑA/O/A',
                correo: 'eduardoposada20041998@gmail.com',
                cargo: 'ADC JR.',
                tipoPago: 'Pagante',
                precio: 137.53,
              ),
              ParticipanteLocal(
                id: 2,
                tipoDoc: 'PASAPORTE',
                numDoc: '054476059',
                nombre: 'RODRIGO ALEJANDRO MAGAÑA BLANCO',
                celular: '503-79150391',
                nacionalidad: 'SALVADOREÑA/O/A',
                correo: 'rodrigomagana96@gmail.com',
                cargo: 'GERENTE REGIONAL CATEGORÍAS',
                tipoPago: 'Pagante',
                precio: 137.53,
              ),
              ParticipanteLocal(
                id: 3,
                tipoDoc: 'PASAPORTE',
                numDoc: '053880352',
                nombre: 'JOSUE ELISEO AMAYA RIVERA',
                celular: '503-71077672',
                nacionalidad: 'SALVADOREÑA/O/A',
                correo: 'josueamaya1996@gmail.com',
                cargo: 'ADC JR.',
                tipoPago: 'Pagante',
                precio: 137.53,
              ),
              ParticipanteLocal(
                id: 4,
                tipoDoc: 'DNI',
                numDoc: '74521896',
                nombre: 'MARIA FERNANDA LOPEZ QUISPE',
                celular: '51-987654321',
                nacionalidad: 'PERUANO/A',
                correo: 'mflopez@empresa.com',
                cargo: 'COORDINADORA COMERCIAL',
                tipoPago: 'Cortesía',
                precio: 0.0,
              ),
              ParticipanteLocal(
                id: 5,
                tipoDoc: 'DNI',
                numDoc: '69834512',
                nombre: 'CARLOS ANTONIO HERRERA VEGA',
                celular: '51-912345678',
                nacionalidad: 'PERUANO/A',
                correo: 'cherrera@empresa.pe',
                cargo: 'JEFE DE LOGÍSTICA',
                tipoPago: 'Pagante',
                precio: 137.53,
              ),
            ],
          ),
        ) {
    _nextId = 6;
  }

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
}
