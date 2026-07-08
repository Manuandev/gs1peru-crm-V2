// lib/features/lead/presentation/bloc/info_lead/info_lead_cubit.dart
//
// Estado reactivo de UNA Negociacion — nada de Contacto ni Numero acá
// (favorito/bloqueado/expirado/cerrado son de número, no de negociación;
// las pantallas que los necesiten los leen de su propia fuente — ej. Chat).

import 'dart:async';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class InfoLeadCubit extends Cubit<InfoLeadState> {
  final GetInfoUseCase _getInfo;
  final UpdateLeadEstadoUseCase _updateEstado;
  final UpdateLeadInfoUseCase _updateInfo;
  // Opcional: solo se inyecta cuando se carga un lead por idLead (contexto de edición).
  // En el contexto de chat se deja null; load(idNumero) usa el SP de WhatsApp.
  final GetLeadDetalleUseCase? _getLeadDetalle;
  // Opcional: solo se inyecta en Seguimiento ("Ver detalle" del contacto,
  // ContactoDetallePage) — task 'DN', ancla en idNumero en vez de idLead.
  final GetLeadDetallePorNumeroUseCase? _getLeadDetallePorNumero;

  final _successController = StreamController<String>.broadcast();
  Stream<String> get successes => _successController.stream;

  final _errorController = StreamController<String>.broadcast();
  Stream<String> get errores => _errorController.stream;

  int? _idLead;
  StreamSubscription<LeadUpdate>? _updateSub;

  InfoLeadCubit(
    this._getInfo,
    this._updateEstado,
    this._updateInfo, [
    this._getLeadDetalle,
    this._getLeadDetallePorNumero,
  ]) : super(const InfoLeadInitial()) {
    _updateSub = LeadUpdateNotifier.instance.stream.listen((update) {
      final s = state;
      if (s is InfoLeadSuccess &&
          s.negociacion.idLead == update.idLead &&
          _idLead != null) {
        load(_idLead!);
      }
    });
  }

  @override
  Future<void> close() {
    _updateSub?.cancel();
    _successController.close();
    _errorController.close();
    return super.close();
  }

  // Inicializa desde la entidad Chat ya cargada en lista — sin llamada a API.
  void seed(Chat chat) {
    if (isClosed) return;
    emit(InfoLeadSuccess(_negociacionDesdeChat(chat)));

    // Si el chat tiene lead, se enriquece en segundo plano con el detalle
    // real (task 'DT') — trae fechaCreacion y demás datos que el SP de
    // chats no incluye. Si no tiene lead (idLead == 0), no se busca nada:
    // se queda vacío.
    if (chat.idLead > 0) {
      _enriquecerConDetalle(chat.idLead);
    }
  }

  // Trae el detalle completo del lead sin pasar por InfoLeadLoading — evita
  // el parpadeo de spinner sobre datos que ya se mostraron desde el seed.
  Future<void> _enriquecerConDetalle(int idLead) async {
    try {
      final detalle = await _getInfo(idLead);
      if (isClosed) return;
      final current = state;
      if (current is! InfoLeadSuccess || current.negociacion.idLead != idLead) {
        return;
      }
      emit(InfoLeadSuccess(detalle));
    } catch (_) {
      // Falla silenciosa — se queda con los datos ya seedeados desde el chat
    }
  }

  // Inicializa directamente desde una Negociacion ya cargada (ej. desde
  // EditLeadPage sin cubit compartido).
  void seedNegociacion(Negociacion negociacion) {
    if (isClosed) return;
    emit(InfoLeadSuccess(negociacion));
  }

  // Deja el cubit listo para crear una negociación NUEVA para el mismo
  // contacto/número (botón "Crear negociación" en NegociacionesTab) — sin
  // perder el contacto ya cargado. idLead en 0 hace que EditLeadPortrait
  // arranque en blanco y el SP de guardado la cree en vez de actualizarla.
  //
  // Si el usuario cancela sin guardar, el llamador debe restaurar el estado
  // anterior (ej. con `load(idLeadAnterior)`) — este método no lo hace solo,
  // porque no sabe si el idLead:0 resultante es "cancelado" o "recién creado
  // pero aún no confirmado por el switch de arriba".
  void prepararNuevaNegociacion() {
    if (isClosed || state is! InfoLeadSuccess) return;
    final actual = (state as InfoLeadSuccess).negociacion;
    emit(
      InfoLeadSuccess(
        Negociacion(
          idLead: 0,
          nombre: '',
          modalidad: '',
          cantidad: 0,
          precioBase: 0,
          descuento: 0,
          precio: 0,
          fechaHoraInteraccion: '',
          fechaHoraCreacion: '',
          idEstado: '',
          descripcionEstado: '',
          idEstadoPadre: '',
          descripcionEstadoPadre: '',
          idCampania: 0,
          nombreCampania: '',
          idOportunidad: 0,
          nombreOportunidad: '',
          idCanal: 0,
          descripcionCanal: '',
          idInteres: 0,
          descripcionInteres: '',
          activo: true,
          idNumero: actual.idNumero,
          prefijoPais: actual.prefijoPais,
          numero: actual.numero,
          nombres: actual.nombres,
          apellidoPaterno: actual.apellidoPaterno,
          apellidoMaterno: actual.apellidoMaterno,
          nombreEmpresa: actual.nombreEmpresa,
          correo: actual.correo,
        ),
      ),
    );
  }

  // Negociacion parcial armada desde el Chat ya cargado en lista — sin
  // cantidad/precioBase/descuento/precio/fechaHoraCreacion (Chat no los
  // trae); se completan al enriquecer con el detalle real (task 'DT').
  Negociacion _negociacionDesdeChat(Chat chat) {
    return Negociacion(
      idLead: chat.idLead,
      nombre: chat.nombres,
      modalidad: chat.modalidad,
      cantidad: 0,
      precioBase: 0,
      descuento: 0,
      precio: 0,
      fechaHoraInteraccion: chat.fechaHora,
      fechaHoraCreacion: chat.fechaHora,
      idEstado: chat.idEstado,
      descripcionEstado: chat.descEstado,
      idEstadoPadre: chat.idEstadoPadre,
      descripcionEstadoPadre: chat.descEstadoPadre,
      idCampania: chat.idCampania,
      nombreCampania: chat.nombreCampania,
      idOportunidad: chat.idOportunidad,
      nombreOportunidad: chat.nombreOportunidad,
      idCanal: chat.idCanal,
      descripcionCanal: chat.nombreCanal,
      idInteres: chat.idInteres,
      descripcionInteres: chat.nombreInteres,
      activo: true,
      idNumero: chat.idNumero,
      prefijoPais: chat.prefijoPais,
      numero: chat.numero,
      nombres: chat.nombres,
      apellidoPaterno: chat.apellidoPaterno ?? '',
      apellidoMaterno: chat.apellidoMaterno ?? '',
      nombreEmpresa: chat.nombreEmpresa,
      correo: chat.correo ?? '',
    );
  }

  /// Carga los datos de un lead específico por su ID.
  /// Usa urlLeadsLst task DT — para editar un lead puntual.
  /// Distinto de load(idNumero) que usa el SP de chats.
  Future<void> cargarPorIdLead(int idLead) async {
    if (isClosed) return;
    _idLead = idLead;
    emit(const InfoLeadLoading());
    try {
      final detalle = await _getLeadDetalle!(idLead);
      if (isClosed) return;
      emit(InfoLeadSuccess(detalle));
    } on AppException catch (e) {
      if (isClosed) return;
      emit(InfoLeadFailure(e.message));
    } catch (e, stackTrace) {
      addError(e, stackTrace);
      if (isClosed) return;
      emit(const InfoLeadFailure('Ocurrió un error inesperado.'));
    }
  }

  /// Carga el lead más reciente de un número — task 'DN'.
  /// Usa Seguimiento (ContactoDetallePage), que navega por idNumero en vez
  /// de idLead. Distinto de cargarPorIdLead(idLead), que trae un lead puntual.
  Future<void> cargarPorIdNumero(int idNumero) async {
    if (isClosed) return;
    emit(const InfoLeadLoading());
    try {
      final detalle = await _getLeadDetallePorNumero!(idNumero);
      if (isClosed) return;
      // El SP resuelve el lead más reciente del número — se guarda recién acá
      // porque hasta este punto no se sabía qué idLead venía.
      _idLead = detalle.idLead;
      emit(InfoLeadSuccess(detalle));
    } on AppException catch (e) {
      if (isClosed) return;
      emit(InfoLeadFailure(e.message));
    } catch (e, stackTrace) {
      addError(e, stackTrace);
      if (isClosed) return;
      emit(const InfoLeadFailure('Ocurrió un error inesperado.'));
    }
  }

  Future<void> load(int idLead) async {
    if (isClosed) return;
    _idLead = idLead;

    emit(const InfoLeadLoading());
    try {
      final negociacion = await _getInfo(idLead);
      if (isClosed) return;
      emit(InfoLeadSuccess(negociacion));
    } on AppException catch (e) {
      emit(InfoLeadFailure(e.message));
    } catch (e, stackTrace) {
      addError(e, stackTrace);
      emit(const InfoLeadFailure('Ocurrió un error inesperado.'));
    }
  }

  Future<void> updateEstado({
    required int idNumero,
    required String idEstado,
    required String estado,
  }) async {
    if (state is! InfoLeadSuccess) return;

    final s = state as InfoLeadSuccess;
    final snapshot = s.negociacion;
    final optimista = snapshot.copyWith(
      idEstado: idEstado,
      descripcionEstado: estado,
      fechaHoraInteraccion: DateTime.now().toString(),
    );

    emit(InfoLeadSuccess(optimista));

    try {
      final result = await _updateEstado(idNumero, idEstado);

      if (isClosed) return;

      switch (result) {
        case CrudOk(:final message):
          _successController.add(message);
          LeadUpdateNotifier.instance.notify(
            optimista.idLead,
            updatedLead: optimista,
          );
          break;
        case CrudAlert(:final message):
          _errorController.add(message);
        case CrudError(:final message):
          emit(InfoLeadSuccess(snapshot));
          _errorController.add(message);
        case CrudNoInternet():
          emit(InfoLeadSuccess(snapshot));
          _errorController.add('Sin conexión. Intenta de nuevo.');
        case CrudEmpty():
          emit(InfoLeadSuccess(snapshot));
          _errorController.add('Respuesta inesperada del servidor.');
      }
    } catch (e) {
      if (isClosed) return;
      emit(InfoLeadSuccess(snapshot));
      _errorController.add('No se pudo cambiar el estado. Intenta de nuevo.');
    }
  }

  // Actualiza solo campos de Negociacion — nombre/apellidos/correo del
  // contacto ya no se editan desde acá (son de solo lectura en el form).
  Future<void> updateLead({
    required int idNumero,
    String? idEstado,
    String? estado,
    String? idEstadoPadre,
    String? descripcionEstadoPadre,
    int? idCampania,
    String? campania,
    int? idEvento,
    String? evento,
    int? idCanal,
    String? canal,
    int? idInteres,
    String? interes,
    String? nombreLead,
    String? modalidad,
    int? cantidad,
    double? precioBase,
    double? descuento,
    double? precio,
    String? idMoneda,
  }) async {
    if (state is! InfoLeadSuccess) return;
    final s = state as InfoLeadSuccess;
    final current = s.negociacion;

    final updated = current.copyWith(
      idEstado: idEstado,
      descripcionEstado: estado,
      idEstadoPadre: idEstadoPadre,
      descripcionEstadoPadre: descripcionEstadoPadre,
      idCampania: idCampania,
      nombreCampania: campania,
      idOportunidad: idEvento,
      nombreOportunidad: evento,
      idCanal: idCanal,
      descripcionCanal: canal,
      idInteres: idInteres,
      descripcionInteres: interes,
      idMoneda: idMoneda,
      nombre: nombreLead,
      modalidad: modalidad,
      cantidad: cantidad,
      precioBase: precioBase,
      descuento: descuento,
      precio: precio,
      // El backend bumpea FC_USUARIO_M al guardar — sin esto, "Hace X" se
      // queda contando desde la última interacción vieja en vez de mostrar
      // que se acaba de tocar el lead ahora mismo.
      fechaHoraInteraccion: DateTime.now().toString(),
    );

    emit(InfoLeadSuccess(updated));

    try {
      final result = await _updateInfo(updated, idNumero);

      if (isClosed) return;

      switch (result) {
        case CrudOk(:final message, :final data):
          // Si el lead se acaba de crear (idLead venía en 0), el SP devuelve
          // el ID_LEAD real generado — sin esto el resto de la app (incluida
          // la lista de chats) se queda con idLead 0 para siempre.
          final idLeadNuevo = int.tryParse(data ?? '');
          final leadFinal = (idLeadNuevo != null && idLeadNuevo > 0)
              ? updated.copyWith(idLead: idLeadNuevo)
              : updated;
          if (leadFinal.idLead != updated.idLead) {
            emit(InfoLeadSuccess(leadFinal));
          }
          _successController.add(message);
          LeadUpdateNotifier.instance.notify(
            leadFinal.idLead,
            updatedLead: leadFinal,
          );
          break;
        case CrudAlert(:final message):
          _errorController.add(message);
        case CrudError(:final message):
          emit(InfoLeadSuccess(current));
          _errorController.add(message);
        case CrudNoInternet():
          emit(InfoLeadSuccess(current));
          _errorController.add('Sin conexión. Intenta de nuevo.');
        case CrudEmpty():
          emit(InfoLeadSuccess(current));
          _errorController.add('Respuesta inesperada del servidor.');
      }
    } catch (e) {
      if (isClosed) return;
      emit(InfoLeadSuccess(current));
      _errorController.add('No se pudo cambiar el estado. Intenta de nuevo.');
    }
  }
}
