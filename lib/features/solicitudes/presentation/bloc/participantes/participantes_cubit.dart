// lib/features/solicitudes/presentation/bloc/participantes/participantes_cubit.dart

import 'package:app_crm/index_dependencies.dart'; // Cubit, Equatable
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/presentation/bloc/form/solicitud_form_cubit.dart';

part 'participantes_state.dart';

class ParticipantesCubit extends Cubit<ParticipantesState> {
  int _nextId = 1;

  ParticipantesCubit() : super(const ParticipantesState(participantes: []));

  /// Reemplaza la lista completa con participantes traídos del backend
  /// (task 'DT') al entrar al wizard sobre una solicitud existente. Ajusta
  /// `_nextId` para que los ids nuevos (agregar) nunca choquen con los ya
  /// guardados — a diferencia de [agregar], respeta el id real de cada
  /// [ParticipanteLocal] en vez de reasignarlo. También siembra
  /// `participantesCargado` con esta misma lista — es la línea base contra
  /// la que se compara para saber si hubo cambios reales (ver
  /// `ParticipantesState.huboCambios`).
  void cargarParticipantes(List<ParticipanteLocal> lista) {
    final maxId = lista.fold(0, (max, p) => p.id > max ? p.id : max);
    _nextId = maxId + 1;
    emit(state.copyWith(participantes: lista, participantesCargado: lista));
  }

  void agregar(ParticipanteLocal participante) {
    final nuevo = participante.copyWith(id: _nextId++);
    emit(state.copyWith(participantes: [...state.participantes, nuevo]));
  }

  void editar(ParticipanteLocal participante) {
    final actualizados = state.participantes.map((p) {
      return p.id == participante.id ? participante : p;
    }).toList();
    emit(state.copyWith(participantes: actualizados));
  }

  /// Elimina y **renumera** el resto de la lista para que los ids sigan
  /// siendo un correlativo sin huecos (1, 2, 3...) — si se borra el
  /// participante `1` y queda el `2`, ese pasa a ser `1`. Ver
  /// solicitudes/CLAUDE.md ("Renumeración de ids al eliminar") por qué esto
  /// es seguro: la solicitud completa se reenvía en cada guardado (mismo
  /// patrón que ya usa el task 'AR' de archivos, que borra todo antes de
  /// volver a insertar), así que no hay ids "reales" del backend que
  /// preservar entre guardados.
  void eliminar(int id) {
    final restantes = state.participantes.where((p) => p.id != id).toList();
    emit(state.copyWith(participantes: _renumerar(restantes)));
  }

  void eliminarTodos() {
    _nextId = 1;
    emit(state.copyWith(participantes: const []));
  }

  /// Sincroniza `participantesCargado` a la lista ACTUAL — con esto,
  /// `ParticipantesState.huboCambios` vuelve a `false` hasta que el asesor
  /// agregue/edite/elimine algo de verdad. Se llama después de cada
  /// guardado exitoso (`guardarBorradorCompleto()`), mismo patrón que
  /// `SolicitudFormCubit.marcarSinCambios()`.
  void marcarSinCambios() =>
      emit(state.copyWith(participantesCargado: state.participantes));

  /// Reasigna ids `1..N` según el orden actual de la lista y ajusta
  /// `_nextId` para que el próximo [agregar] continúe el correlativo sin
  /// chocar ni dejar huecos.
  List<ParticipanteLocal> _renumerar(List<ParticipanteLocal> lista) {
    final renumerados = [
      for (var i = 0; i < lista.length; i++) lista[i].copyWith(id: i + 1),
    ];
    _nextId = renumerados.length + 1;
    return renumerados;
  }

  /// Refleja el switch "El solicitante será participante" (paso 1) en la
  /// lista de participantes: agrega/actualiza un registro marcado como
  /// [ParticipanteLocal.esSolicitante] con los datos ya capturados del
  /// solicitante, o lo retira si el switch se desactiva. Se llama al toque
  /// del switch (`_onSolicitanteParticipanteChanged`) y de nuevo en cada
  /// "Continuar"/"Guardar" del paso 1 — idempotente, nunca duplica.
  // [idTipoParticipantePagante] viene del catálogo real (CatalogsBloc.
  // tiposParticipante, el ítem con esInvitado == false) — el Cubit no tiene
  // BuildContext para leerlo solo, así que el caller (paso 1) lo resuelve y
  // lo pasa acá. Nunca hardcodear el id de "Pagante".
  //
  // [importeFijo] es el precio de la negociación de origen
  // (SolicitudFormState.precioBaseLead), si la hay — mismo valor que ya usa
  // "Nuevo participante" (ver participante_form_sheet.dart). Se resuelve UNA
  // sola vez (la primera vez que se crea este registro): en re-sincronizaciones
  // posteriores (volver al paso 1 y presionar "Continuar" de nuevo) se
  // preserva el `id` Y el `importe` que ya tenía — antes este método
  // regeneraba un `id` nuevo (`_nextId++`) y pisaba el importe a `0` en CADA
  // llamada, perdiendo el precio fijado y arriesgando filas duplicadas en el
  // backend (el `id` de `ParticipanteLocal` se manda tal cual como `ID` de
  // la fila al SP — ver solicitudes/CLAUDE.md).
  //
  // `anterior` cae a `participantesCargado` (además de la lista actual) —
  // necesario para el caso "apagar el switch y prenderlo de nuevo enseguida,
  // sin guardar en el medio": al apagarlo, el registro `esSolicitante` sale
  // de `participantes` (ver la rama de abajo) pero sigue en
  // `participantesCargado` (todavía no se guardó nada); sin este fallback,
  // prenderlo de nuevo generaría un `id` NUEVO en vez de recuperar el
  // original, y el resultado ya no compararía igual contra lo cargado
  // (`ParticipantesState.huboCambios` seguiría en `true` aunque el switch
  // haya vuelto a su estado original) — bug real reportado por el usuario,
  // 2026-07-24.
  void sincronizarSolicitante(
    DatosSolicitante datos, {
    required String idTipoParticipantePagante,
    double? importeFijo,
  }) {
    final anterior =
        state.participantes.where((p) => p.esSolicitante).firstOrNull ??
        state.participantesCargado.where((p) => p.esSolicitante).firstOrNull;
    final resto = state.participantes.where((p) => !p.esSolicitante).toList();

    if (!datos.solicitanteEsParticipante) {
      emit(state.copyWith(participantes: resto));
      return;
    }

    final solicitanteParticipante = ParticipanteLocal(
      id: anterior?.id ?? _nextId++,
      tipoDocId: datos.tipoDocId,
      tipoDoc: datos.tipoDocLabel,
      numDoc: datos.numDoc,
      nacionalidadId: datos.nacionalidadId,
      nacionalidad: datos.nacionalidad,
      nombres: datos.nombres,
      apellidoPaterno: datos.apellidoPaterno,
      apellidoMaterno: datos.apellidoMaterno,
      correo: datos.correo,
      cargo: datos.cargo,
      cargoId: datos.cargoId,
      celular: datos.celular,
      celularCodigoTelefono: datos.celularCodigoTelefono,
      tipoParticipante: idTipoParticipantePagante,
      importe: importeFijo ?? anterior?.importe ?? 0,
      esSolicitante: true,
    );

    emit(state.copyWith(participantes: [solicitanteParticipante, ...resto]));
  }
}
