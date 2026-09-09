// lib/features/chat/presentation/bloc/chat_list/chat_list_bloc.dart

import 'dart:async';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final GetChatsUseCase _getChats;
  final GetChatByIdChatCabUseCase _getChatByIdChatCab;
  List<Chat> _allChats = [];
  StreamSubscription<WebSocketMessage>? _messageSubscription;
  StreamSubscription<LeadUpdate>? _leadUpdateSubscription;

  String _lastSearchQuery = '';
  ChatListFiltro _filtroActivo = ChatListFiltro.todos;

  // idChatCab en proceso de inserción (WS + BD en camino, aún no en _allChats).
  // Sin esto, dos eventos del mismo chatCab que llegan mientras el primero
  // todavía está esperando la BD pasan el check "¿ya está en _allChats?" los
  // dos, porque ninguno terminó de insertar todavía — se duplica la tarjeta.
  final Set<int> _chatCabsEnInsercion = {};

  // Filtros avanzados del panel lateral
  String _filtroNombre = '';
  String _filtroEmpresa = '';
  String _filtroNumero = '';
  String _filtroCampaniaId = '';
  String _filtroOportunidadId = '';

  ChatListBloc(this._getChats, this._getChatByIdChatCab)
    : super(const ChatListInitial()) {
    on<ChatListStarted>(_onStarted);
    on<ChatListRefreshed>(_onRefreshed);
    on<ChatListReset>(_onReset);
    on<ChatListSilentRefreshed>(_onSilentRefreshed);
    on<ChatListSearched>(_onSearched);
    on<ChatListFiltered>(_onFiltered);
    on<ChatListFiltroAvanzadoAplicado>(_onFiltroAvanzadoAplicado);
    on<ChatListFiltroAvanzadoLimpiado>(_onFiltroAvanzadoLimpiado);
    on<ChatListIncomingMessageReceived>(_onIncomingMessageReceived);
    on<ChatListLeadUpdated>(_onLeadUpdated);

    _messageSubscription = MessageDispatcher.instance.stream.listen((message) {
      if (!isClosed) add(ChatListIncomingMessageReceived(message));
    });

    _leadUpdateSubscription = LeadUpdateNotifier.instance.stream.listen((
      update,
    ) {
      final lead = update.updatedLead as Negociacion?;
      if (!isClosed && lead != null) add(ChatListLeadUpdated(lead));
    });
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    _leadUpdateSubscription?.cancel();
    return super.close();
  }

  // ── Carga ────────────────────────────────────────────────────────────────

  Future<void> _onStarted(
    ChatListStarted event,
    Emitter<ChatListState> emit,
  ) async {
    emit(const ChatListLoading());
    await _loadData(emit);
  }

  Future<void> _onRefreshed(
    ChatListRefreshed event,
    Emitter<ChatListState> emit,
  ) async {
    emit(const ChatListLoading());
    await _loadData(emit);
  }

  /// Reingreso desde el menú: limpia chip + búsqueda + filtros del panel
  /// avanzado y recarga. El bloc es global, así que estos campos sobreviven
  /// al salir de la pantalla — sin esto, el filtro (ej. "En cobranza") seguía
  /// activo al volver a Conversaciones desde otra sección.
  Future<void> _onReset(
    ChatListReset event,
    Emitter<ChatListState> emit,
  ) async {
    _filtroActivo = ChatListFiltro.todos;
    _lastSearchQuery = '';
    _filtroNombre = '';
    _filtroEmpresa = '';
    _filtroNumero = '';
    _filtroCampaniaId = '';
    _filtroOportunidadId = '';
    emit(const ChatListLoading());
    await _loadData(emit);
  }

  Future<void> _onSilentRefreshed(
    ChatListSilentRefreshed event,
    Emitter<ChatListState> emit,
  ) async {
    try {
      final chatsFrescos = await _getChats();
      _allChats = _mergeConservandoMasReciente(chatsFrescos);
      _emitFiltered(emit);
    } catch (_) {
      // Falla silenciosa — mantiene el estado actual sin mostrar error
    }
  }

  /// Combina el listado fresco del servidor con el que ya está en memoria,
  /// conservando el lado con [Chat.fechaHora] más reciente por cada chat.
  ///
  /// Este refresh silencioso corre en paralelo (sin orden garantizado) con
  /// las confirmaciones que llegan por WebSocket (`UPDATE_PANTALLA_WHATSAPP`).
  /// Si el fetch tarda más y el SP de listado todavía no propagó el último
  /// mensaje, sobreescribir sin comparar revierte el "tiempo sin respuesta"
  /// a un valor viejo pese a que ya teníamos el dato correcto en memoria.
  List<Chat> _mergeConservandoMasReciente(List<Chat> chatsFrescos) {
    return chatsFrescos.map((fresco) {
      final actual = _buscarPorIdChatCab(fresco.idChatCab);
      if (actual == null) return fresco;

      final fechaActual = DateFormatter.parseDate(actual.fechaHora);
      final fechaFresca = DateFormatter.parseDate(fresco.fechaHora);
      final actualEsMasReciente =
          fechaActual != null &&
          (fechaFresca == null || fechaActual.isAfter(fechaFresca));

      if (!actualEsMasReciente) return fresco;

      return fresco.copyWith(
        fechaHora: actual.fechaHora,
        direccionMensaje: actual.direccionMensaje,
        tipoCliente: actual.tipoCliente,
        contenidoCliente: actual.contenidoCliente,
        archivoNombreCliente: actual.archivoNombreCliente,
        archivoTipoCliente: actual.archivoTipoCliente,
        fcUltimoMensajeCliente: actual.fcUltimoMensajeCliente,
      );
    }).toList();
  }

  Chat? _buscarPorIdChatCab(int idChatCab) {
    for (final c in _allChats) {
      if (c.idChatCab == idChatCab) return c;
    }
    return null;
  }

  Future<void> _loadData(Emitter<ChatListState> emit) async {
    try {
      _allChats = await _getChats();
      _emitFiltered(emit);
    } on AppException catch (e) {
      emit(ChatListError(e.message));
    } catch (e, stackTrace) {
      addError(e, stackTrace);
      emit(const ChatListError('Ocurrió un error inesperado.'));
    }
  }

  // ── Filtros ──────────────────────────────────────────────────────────────

  void _onSearched(ChatListSearched event, Emitter<ChatListState> emit) {
    _lastSearchQuery = event.query;
    _emitFiltered(emit);
  }

  void _onFiltered(ChatListFiltered event, Emitter<ChatListState> emit) {
    _filtroActivo = event.filtro;
    _emitFiltered(emit);
  }

  void _onFiltroAvanzadoAplicado(
    ChatListFiltroAvanzadoAplicado event,
    Emitter<ChatListState> emit,
  ) {
    _filtroNombre = event.nombre;
    _filtroEmpresa = event.empresa;
    _filtroNumero = event.numero;
    _filtroCampaniaId = event.campaniaId;
    _filtroOportunidadId = event.oportunidadId;
    _emitFiltered(emit);
  }

  void _onFiltroAvanzadoLimpiado(
    ChatListFiltroAvanzadoLimpiado event,
    Emitter<ChatListState> emit,
  ) {
    _filtroNombre = '';
    _filtroEmpresa = '';
    _filtroNumero = '';
    _filtroCampaniaId = '';
    _filtroOportunidadId = '';
    _emitFiltered(emit);
  }

  // ── Parche en memoria tras edición de lead ───────────────────────────────

  void _onLeadUpdated(ChatListLeadUpdated event, Emitter<ChatListState> emit) {
    final lead = event.negociacion;
    // Matchea por idNumero, no por idLead: al crear una negociación nueva
    // (idLead pasa de 0 al id real, o cambia a otra negociación del mismo
    // contacto), el número es lo único que no cambia entre el chat de la
    // lista y el lead recién guardado.
    _allChats = _allChats.map((c) {
      if (c.idNumero != lead.idNumero) return c;
      // Negociacion todavía usa el encoding viejo (idEstado = leaf,
      // idEstadoPadre = padre cuando hay subestado); Chat ya los tiene
      // separados, así que se traduce acá.
      final haySub = lead.idEstadoPadre.isNotEmpty;
      return c.copyWith(
        idLead: lead.idLead,
        modalidad: lead.modalidad,
        idEstado: lead.idEstadoEfectivo,
        descEstado: lead.estadoEfectivo,
        idSubestado: haySub ? lead.idEstado : '',
        descSubestado: haySub ? lead.descripcionEstado : '',
        idCampania: lead.idCampania,
        nombreCampania: lead.nombreCampania,
        idOportunidad: lead.idOportunidad,
        nombreOportunidad: lead.nombreOportunidad,
        idCanal: lead.idCanal,
        nombreCanal: lead.descripcionCanal,
        idInteres: lead.idInteres,
        nombreInteres: lead.descripcionInteres,
      );
    }).toList();
    _emitFiltered(emit);
  }

  // ── Emisión filtrada ─────────────────────────────────────────────────────

  void _emitFiltered(Emitter<ChatListState> emit) {
    // Contadores siempre calculados sobre la lista completa
    final contadores = _calcularContadores(_allChats);

    // Conteos por chip (también desde la lista completa)
    final conteos = _calcularConteos(_allChats);

    // Aplicar filtros en orden: chip → búsqueda → avanzados
    var resultado = _aplicarFiltroChip(List<Chat>.from(_allChats));
    resultado = _aplicarBusqueda(resultado);
    resultado = _aplicarFiltrosAvanzados(resultado);

    emit(
      ChatListSuccess(
        contadores: contadores,
        conversaciones: resultado,
        filtro: _filtroActivo,
        conteos: conteos,
        filtroNombre: _filtroNombre,
        filtroEmpresa: _filtroEmpresa,
        filtroNumero: _filtroNumero,
        filtroCampaniaId: _filtroCampaniaId,
        filtroOportunidadId: _filtroOportunidadId,
      ),
    );
  }

  /// "En cobranza" = negociación cerrada ganada: estado '04' + subestado '05'.
  /// Ahora que el SP trae estado y subestado por separado, la validación es
  /// directa. Antes se comparaba solo `idEstado == '05'` (el "leaf"), que
  /// dejaba pasar subestados '05' de otros padres — por eso salían chats con
  /// el chip "Nuevo" dentro de Cobranza.
  static bool _esEnCobranza(Chat c) =>
      c.idEstado == '04' && c.idSubestado == '05';

  ContadoresChat _calcularContadores(List<Chat> chats) {
    return ContadoresChat(
      sinResponder: chats.where((c) => c.direccionMensaje == 'CLI').length,
      derivadasPorIA: chats.where((c) => c.isDerivadoIA).length,
      conPropuesta: chats.where((c) => c.idEstado == '02').length,
      enCobranza: chats.where(_esEnCobranza).length,
    );
  }

  Map<ChatListFiltro, int> _calcularConteos(List<Chat> chats) {
    final ahora = DateTime.now();
    return {
      ChatListFiltro.todos: chats.length,
      ChatListFiltro.sinResponder: chats
          .where((c) => c.direccionMensaje == 'CLI')
          .length,
      ChatListFiltro.enDesarrollo: chats.where((c) {
        if (c.direccionMensaje == 'CLI') return false;
        final fecha = DateFormatter.parseDate(c.fechaHora);
        if (fecha == null) return false;
        return ahora.difference(fecha).inHours < 72;
      }).length,
      ChatListFiltro.conPropuesta: chats
          .where((c) => c.idEstado == '02')
          .length,
      ChatListFiltro.enCobranza: chats.where(_esEnCobranza).length,
    };
  }

  List<Chat> _aplicarFiltroChip(List<Chat> chats) {
    final ahora = DateTime.now();
    return switch (_filtroActivo) {
      ChatListFiltro.todos => chats,
      ChatListFiltro.sinResponder =>
        chats.where((c) => c.direccionMensaje == 'CLI').toList(),
      ChatListFiltro.enDesarrollo => chats.where((c) {
        if (c.direccionMensaje == 'CLI') return false;
        final fecha = DateFormatter.parseDate(c.fechaHora);
        if (fecha == null) return false;
        return ahora.difference(fecha).inHours < 72;
      }).toList(),
      ChatListFiltro.conPropuesta =>
        chats.where((c) => c.idEstado == '02').toList(),
      ChatListFiltro.enCobranza => chats.where(_esEnCobranza).toList(),
    };
  }

  List<Chat> _aplicarBusqueda(List<Chat> chats) {
    final q = _lastSearchQuery.toLowerCase().trim();
    if (q.isEmpty) return chats;
    return chats
        .where(
          (c) =>
              c.nombres.toLowerCase().contains(q) ||
              (c.apellidoPaterno?.toLowerCase().contains(q) ?? false) ||
              (c.apellidoMaterno?.toLowerCase().contains(q) ?? false) ||
              c.nombreEmpresa.toLowerCase().contains(q) ||
              c.nombreOportunidad.toLowerCase().contains(q) ||
              c.numero.contains(q),
        )
        .toList();
  }

  List<Chat> _aplicarFiltrosAvanzados(List<Chat> chats) {
    var resultado = chats;

    if (_filtroNombre.isNotEmpty) {
      final q = _filtroNombre.toLowerCase();
      resultado = resultado
          .where((c) => c.nombreCompleto.toLowerCase().contains(q))
          .toList();
    }
    if (_filtroEmpresa.isNotEmpty) {
      final q = _filtroEmpresa.toLowerCase();
      resultado = resultado
          .where((c) => c.nombreEmpresa.toLowerCase().contains(q))
          .toList();
    }
    if (_filtroNumero.isNotEmpty) {
      resultado = resultado
          .where((c) => c.numero.contains(_filtroNumero))
          .toList();
    }
    if (_filtroCampaniaId.isNotEmpty) {
      resultado = resultado
          .where((c) => c.idCampania.toString() == _filtroCampaniaId)
          .toList();
    }
    if (_filtroOportunidadId.isNotEmpty) {
      resultado = resultado
          .where((c) => c.idOportunidad.toString() == _filtroOportunidadId)
          .toList();
    }

    return resultado;
  }

  // ── WebSocket ────────────────────────────────────────────────────────────

  Future<void> _onIncomingMessageReceived(
    ChatListIncomingMessageReceived event,
    Emitter<ChatListState> emit,
  ) async {
    if (state is! ChatListSuccess) return;

    switch (event.message.process) {
      case 'MENSAJE_WHATSAPP':
        await _handleMensajeWhatsApp(event.message, emit);
      case 'UPDATE_PANTALLA_WHATSAPP':
        await _handleUpdatePantalla(event.message, emit);
      case 'NUEVO_LEAD_BOT':
        await _handleNuevoLeadBot(event.message, emit);
      default:
        break;
    }
  }

  Future<void> _handleMensajeWhatsApp(
    WebSocketMessage message,
    Emitter<ChatListState> emit,
  ) async {
    final payload = WhatsAppMessagePayload.fromMessage(message);
    if (payload == null) return;

    await _updateChatInList(
      idChatCab: payload.idChatCab,
      // Hora de recepción local — no la del payload, que llega desfasada
      // del momento real en que el mensaje fue procesado por el servidor.
      fechaHora: DateTime.now().toIso8601String(),
      direccionMensaje: 'CLI',
      emit: emit,
      tipoCliente: payload.tipoMensaje.isNotEmpty
          ? payload.tipoMensaje
          : 'text',
      contenidoCliente: payload.mensaje,
      archivoNombreCliente: _removeExt(payload.nomArchivo),
      archivoTipoCliente: _extractExt(payload.nomArchivo),
    );
  }

  Future<void> _handleUpdatePantalla(
    WebSocketMessage message,
    Emitter<ChatListState> emit,
  ) async {
    final payload = UpdatePantallaWhatsAppPayload.fromMessage(message);
    if (payload == null) return;

    await _updateChatInList(
      idChatCab: payload.idChatCab,
      fechaHora: payload.hora.isNotEmpty
          ? payload.hora
          : DateTime.now().toIso8601String(),
      direccionMensaje: 'ASE',
      emit: emit,
    );
  }

  /// Actualiza el chat de [idChatCab] en memoria. Si no existe todavía
  /// (conversación nueva que llegó por WebSocket antes de cualquier refresh),
  /// trae solo ese registro con [_getChatByIdChatCab] (task 'LU') en vez de
  /// refrescar la lista completa, y lo inserta al inicio.
  Future<void> _updateChatInList({
    required int idChatCab,
    required String fechaHora,
    required String direccionMensaje,
    required Emitter<ChatListState> emit,
    String? tipoCliente,
    String? contenidoCliente,
    String? archivoNombreCliente,
    String? archivoTipoCliente,
  }) async {
    final chats = List<Chat>.from(_allChats);
    final idx = chats.indexWhere((c) => c.idChatCab == idChatCab);

    if (idx == -1) {
      await _insertChatFromDbIfMissing(idChatCab, emit);
      return;
    }

    final updatedChat = chats[idx].copyWith(
      fechaHora: fechaHora,
      direccionMensaje: direccionMensaje,
      tipoCliente: tipoCliente,
      contenidoCliente: contenidoCliente,
      archivoNombreCliente: archivoNombreCliente,
      archivoTipoCliente: archivoTipoCliente,
      fcUltimoMensajeCliente: fechaHora,
    );

    chats.removeAt(idx);
    chats.insert(0, updatedChat);
    _allChats = chats;
    _emitFiltered(emit);
  }

  /// Trama NUEVO_LEAD_BOT — el bot creó un lead con conversación nueva.
  /// Si ya la tenemos en la lista no hace nada; si no, la trae de la BD
  /// igual que [_updateChatInList] cuando el chat todavía no existe.
  Future<void> _handleNuevoLeadBot(
    WebSocketMessage message,
    Emitter<ChatListState> emit,
  ) async {
    final payload = NuevoLeadBotPayload.fromMessage(message);
    if (payload == null) return;

    await _insertChatFromDbIfMissing(payload.idChatCab, emit);
  }

  /// Trae de la BD el chat de [idChatCab] (task 'LU') y lo inserta al
  /// inicio de la lista. Usado cuando el WebSocket avisa de una
  /// conversación que todavía no está en memoria.
  Future<void> _insertChatFromDbIfMissing(
    int idChatCab,
    Emitter<ChatListState> emit,
  ) async {
    // Ya está en la lista o ya hay otra inserción en camino para este mismo
    // chatCab — no hacer nada más, evita la tarjeta duplicada.
    if (_allChats.any((c) => c.idChatCab == idChatCab)) return;
    if (!_chatCabsEnInsercion.add(idChatCab)) return;

    try {
      final nuevoChat = await _getChatByIdChatCab(idChatCab);
      if (nuevoChat == null || isClosed) return;
      if (_allChats.any((c) => c.idChatCab == idChatCab)) return;
      _allChats = [nuevoChat, ..._allChats];
      _emitFiltered(emit);
    } catch (_) {
      // Falla silenciosa — el chat seguirá faltando hasta el próximo refresh
    } finally {
      _chatCabsEnInsercion.remove(idChatCab);
    }
  }

  static String _extractExt(String fileName) {
    if (fileName.isEmpty) return '';
    final dotIndex = fileName.lastIndexOf('.');
    return dotIndex != -1 ? fileName.substring(dotIndex) : '';
  }

  static String _removeExt(String fileName) {
    if (fileName.isEmpty) return '';
    final dotIndex = fileName.lastIndexOf('.');
    return dotIndex != -1 ? fileName.substring(0, dotIndex) : fileName;
  }
}
