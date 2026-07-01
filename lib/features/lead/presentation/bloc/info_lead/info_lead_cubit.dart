// lib/features/lead/presentation/bloc/info_lead/info_lead_cubit.dart

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
  ]) : super(const InfoLeadInitial()) {
    _updateSub = LeadUpdateNotifier.instance.stream.listen((update) {
      final s = state;
      if (s is InfoLeadSuccess &&
          s.lead.idLead == update.idLead &&
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
    emit(
      InfoLeadSuccess(
        _leadDesdeChat(chat),
        isBloqueado: chat.isBloqueado,
        isExpirado: chat.isExpirado,
        isCerrado: chat.isCerrado,
      ),
    );
  }

  // Inicializa directamente desde un Lead ya cargado (ej. desde EditLeadPage sin cubit compartido).
  void seedLead(Lead lead) {
    if (isClosed) return;
    emit(InfoLeadSuccess(lead));
  }

  Lead _leadDesdeChat(Chat chat) {
    return Lead(
      idLead: chat.idLead,
      idContacto: chat.idContacto,
      nombre: chat.nombres,
      apellidoPaterno: chat.apellidoPaterno ?? '',
      apellidoMaterno: chat.apellidoMaterno ?? '',
      nombreEmpresa: chat.nombreEmpresa,
      asesor: chat.asesor ?? '',
      fechaHora: chat.fechaHora,
      idNumero: chat.idNumero,
      prefijo: chat.prefijoPais,
      numero: chat.numero,
      isFavorito: chat.isFavorito,
      correo: '',
      idEstado: chat.idEstado,
      estado: chat.descEstado,
      idCampania: chat.idCampania,
      campania: chat.nombreCampania,
      idEvento: chat.idOportunidad,
      evento: chat.nombreOportunidad,
      idCanal: chat.idCanal,
      canal: chat.nombreCanal,
      idInteres: chat.idInteres,
      interes: chat.nombreInteres,
      modalidad: chat.modalidad,
      idEstadoPadre: chat.idEstadoPadre,
      descripcionEstadoPadre: chat.descEstadoPadre,
    );
  }

  /// Carga los datos de un lead específico por su ID.
  /// Usa urlLeadsLst task DT — para editar un lead puntual.
  /// Distinto de load(idNumero) que usa el SP de chats.
  Future<void> cargarPorIdLead(int idLead) async {
    if (isClosed) return;
    emit(const InfoLeadLoading());
    try {
      final detalle = await _getLeadDetalle!(idLead);
      if (isClosed) return;
      emit(InfoLeadSuccess(detalle.lead));
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

    // Preservar flags de conversación antes de entrar en loading
    final prev = state;
    final prevBloqueado = prev is InfoLeadSuccess ? prev.isBloqueado : false;
    final prevExpirado = prev is InfoLeadSuccess ? prev.isExpirado : false;
    final prevCerrado = prev is InfoLeadSuccess ? prev.isCerrado : false;

    emit(const InfoLeadLoading());
    try {
      final lead = await _getInfo(idLead);
      if (isClosed) return;
      emit(
        InfoLeadSuccess(
          lead,
          isBloqueado: prevBloqueado,
          isExpirado: prevExpirado,
          isCerrado: prevCerrado,
        ),
      );
    } on AppException catch (e) {
      emit(InfoLeadFailure(e.message));
    } catch (e, stackTrace) {
      addError(e, stackTrace);
      emit(const InfoLeadFailure('Ocurrió un error inesperado.'));
    }
  }

  void updateFavorito(bool value) {
    if (state is! InfoLeadSuccess) return;
    final s = state as InfoLeadSuccess;
    emit(
      InfoLeadSuccess(
        s.lead.copyWith(isFavorito: value),
        isBloqueado: s.isBloqueado,
        isExpirado: s.isExpirado,
        isCerrado: s.isCerrado,
      ),
    );
  }

  Future<void> updateEstado({
    required int idNumero,
    required String idEstado,
    required String estado,
  }) async {
    if (state is! InfoLeadSuccess) return;

    final s = state as InfoLeadSuccess;
    final snapshot = s.lead;

    emit(
      InfoLeadSuccess(
        snapshot.copyWith(idEstado: idEstado, estado: estado),
        isBloqueado: s.isBloqueado,
        isExpirado: s.isExpirado,
        isCerrado: s.isCerrado,
      ),
    );

    try {
      final result = await _updateEstado(idNumero, idEstado);

      if (isClosed) return;

      switch (result) {
        case CrudOk(:final message):
          _successController.add(message);
          break;
        case CrudAlert(:final message):
          _errorController.add(message);
        case CrudError(:final message):
          emit(
            InfoLeadSuccess(
              snapshot,
              isBloqueado: s.isBloqueado,
              isExpirado: s.isExpirado,
              isCerrado: s.isCerrado,
            ),
          );
          _errorController.add(message);
        case CrudNoInternet():
          emit(
            InfoLeadSuccess(
              snapshot,
              isBloqueado: s.isBloqueado,
              isExpirado: s.isExpirado,
              isCerrado: s.isCerrado,
            ),
          );
          _errorController.add('Sin conexión. Intenta de nuevo.');
        case CrudEmpty():
          emit(
            InfoLeadSuccess(
              snapshot,
              isBloqueado: s.isBloqueado,
              isExpirado: s.isExpirado,
              isCerrado: s.isCerrado,
            ),
          );
          _errorController.add('Respuesta inesperada del servidor.');
      }
    } catch (e) {
      if (isClosed) return;
      final current = state is InfoLeadSuccess ? (state as InfoLeadSuccess) : s;
      emit(
        InfoLeadSuccess(
          snapshot,
          isBloqueado: current.isBloqueado,
          isExpirado: current.isExpirado,
          isCerrado: current.isCerrado,
        ),
      );
      _errorController.add('No se pudo cambiar el estado. Intenta de nuevo.');
    }
  }

  Future<void> updateLead({
    String? idEstado,
    String? estado,
    String? idEstadoPadre,
    String? descripcionEstadoPadre,
    bool clearEstadoPadre = false,
    String? idSubEstado,
    String? subEstado,
    int? idCampania,
    String? campania,
    int? idEvento,
    String? evento,
    bool clearEvento = false,
    int? idCanal,
    String? canal,
    int? idInteres,
    String? interes,
    String? nombre,
    String? apellidoPaterno,
    String? apellidoMaterno,
    String? correo,
    int? cantidad,
    double? precioBase,
    double? descuento,
    double? precio,
    String empresaEditar = '',
    String correoEditar = '',
    String nuevasEmpresas = '',
    String nuevosCorreos = '',
    String nuevosPrefijos = '',
    String nuevosNumeros = '',
  }) async {
    if (state is! InfoLeadSuccess) return;
    final s = state as InfoLeadSuccess;
    final current = s.lead;

    final updated = current.copyWith(
      idEstado: idEstado,
      estado: estado,
      idEstadoPadre: idEstadoPadre,
      descripcionEstadoPadre: descripcionEstadoPadre,
      clearEstadoPadre: clearEstadoPadre,
      idSubEstado: idSubEstado,
      subEstado: subEstado,
      idCampania: idCampania,
      campania: campania,
      idEvento: idEvento,
      evento: evento,
      clearEvento: clearEvento,
      idCanal: idCanal,
      canal: canal,
      idInteres: idInteres,
      interes: interes,
      nombre: nombre,
      apellidoPaterno: apellidoPaterno,
      apellidoMaterno: apellidoMaterno,
      correo: correo,
      cantidad: cantidad,
      precioBase: precioBase,
      descuento: descuento,
      precio: precio,
    );

    emit(
      InfoLeadSuccess(
        updated,
        isBloqueado: s.isBloqueado,
        isExpirado: s.isExpirado,
        isCerrado: s.isCerrado,
      ),
    );

    try {
      final result = await _updateInfo(
        updated,
        empresaEditar: empresaEditar,
        correoEditar: correoEditar,
        nuevasEmpresas: nuevasEmpresas,
        nuevosCorreos: nuevosCorreos,
        nuevosPrefijos: nuevosPrefijos,
        nuevosNumeros: nuevosNumeros,
      );

      if (isClosed) return;

      switch (result) {
        case CrudOk(:final message):
          _successController.add(message);
          break;
        case CrudAlert(:final message):
          _errorController.add(message);
        case CrudError(:final message):
          emit(
            InfoLeadSuccess(
              current,
              isBloqueado: s.isBloqueado,
              isExpirado: s.isExpirado,
              isCerrado: s.isCerrado,
            ),
          );
          _errorController.add(message);
        case CrudNoInternet():
          emit(
            InfoLeadSuccess(
              current,
              isBloqueado: s.isBloqueado,
              isExpirado: s.isExpirado,
              isCerrado: s.isCerrado,
            ),
          );
          _errorController.add('Sin conexión. Intenta de nuevo.');
        case CrudEmpty():
          emit(
            InfoLeadSuccess(
              current,
              isBloqueado: s.isBloqueado,
              isExpirado: s.isExpirado,
              isCerrado: s.isCerrado,
            ),
          );
          _errorController.add('Respuesta inesperada del servidor.');
      }
    } catch (e) {
      if (isClosed) return;
      emit(
        InfoLeadSuccess(
          current,
          isBloqueado: s.isBloqueado,
          isExpirado: s.isExpirado,
          isCerrado: s.isCerrado,
        ),
      );
      _errorController.add('No se pudo cambiar el estado. Intenta de nuevo.');
    }
  }
}
