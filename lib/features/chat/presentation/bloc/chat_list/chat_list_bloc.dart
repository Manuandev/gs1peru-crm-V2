// lib/features/chat/presentation/bloc/chat_list/chat_list_bloc.dart

import 'dart:async';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final GetChatsUseCase _getChats;
  List<Chat> _allChats = [];
  StreamSubscription<WebSocketMessage>? _messageSubscription;
  StreamSubscription<LeadUpdate>? _leadUpdateSubscription;

  String _lastSearchQuery = '';
  ChatListFiltro _filtroActivo = ChatListFiltro.todos;

  // Filtros avanzados del panel lateral
  String _filtroNombre = '';
  String _filtroEmpresa = '';
  String _filtroNumero = '';
  String _filtroOportunidadId = '';

  ChatListBloc(this._getChats) : super(const ChatListInitial()) {
    on<ChatListStarted>(_onStarted);
    on<ChatListRefreshed>(_onRefreshed);
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
      final lead = update.updatedLead as Lead?;
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
    _filtroOportunidadId = '';
    _emitFiltered(emit);
  }

  // ── Parche en memoria tras edición de lead ───────────────────────────────

  void _onLeadUpdated(ChatListLeadUpdated event, Emitter<ChatListState> emit) {
    final lead = event.lead;
    _allChats = _allChats.map((c) {
      if (c.idLead != lead.idLead) return c;
      return c.copyWith(
        idEstado: lead.idEstado,
        descEstado: lead.estado,
        idEstadoPadre: lead.idEstadoPadre ?? '',
        descEstadoPadre: lead.descripcionEstadoPadre ?? '',
        idCampania: lead.idCampania,
        nombreCampania: lead.campania,
        idOportunidad: lead.idEvento,
        nombreOportunidad: lead.evento,
        idCanal: lead.idCanal,
        nombreCanal: lead.canal,
        idInteres: lead.idInteres,
        nombreInteres: lead.interes,
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
        filtroOportunidadId: _filtroOportunidadId,
      ),
    );
  }

  ContadoresChat _calcularContadores(List<Chat> chats) {
    return ContadoresChat(
      sinResponder: chats.where((c) => c.direccionMensaje == 'CLI').length,
      derivadasPorIA: chats.where((c) => c.isDerivadoIA).length,
      conPropuesta: chats.where((c) => c.idEstadoEfectivo == '02').length,
      enCobranza: chats.where((c) => c.idEstado == '05').length,
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
          .where((c) => c.idEstadoEfectivo == '02')
          .length,
      ChatListFiltro.enCobranza: chats.where((c) => c.idEstado == '05').length,
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
        chats.where((c) => c.idEstadoEfectivo == '02').toList(),
      ChatListFiltro.enCobranza =>
        chats.where((c) => c.idEstado == '05').toList(),
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
    if (_filtroOportunidadId.isNotEmpty) {
      resultado = resultado
          .where((c) => c.idOportunidad.toString() == _filtroOportunidadId)
          .toList();
    }

    return resultado;
  }

  // ── WebSocket ────────────────────────────────────────────────────────────

  void _onIncomingMessageReceived(
    ChatListIncomingMessageReceived event,
    Emitter<ChatListState> emit,
  ) {
    if (state is! ChatListSuccess) return;

    switch (event.message.process) {
      case 'MENSAJE_WHATSAPP':
        _handleMensajeWhatsApp(event.message, emit);
      case 'UPDATE_PANTALLA_WHATSAPP':
        _handleUpdatePantalla(event.message, emit);
      case 'UPDATE_MENSAJE_WHATSAPP':
        _handleUpdateMensaje(event.message, emit);
      default:
        break;
    }
  }

  void _handleMensajeWhatsApp(
    WebSocketMessage message,
    Emitter<ChatListState> emit,
  ) {
    final payload = WhatsAppMessagePayload.fromMessage(message);
    if (payload == null) return;

    _updateChatInList(
      idNumero: payload.idNumero,
      mensaje: payload.mensaje,
      tipoMensaje: payload.tipoMensaje.isNotEmpty
          ? payload.tipoMensaje
          : 'text',
      estado: '',
      fechaHora: DateTime.now().toIso8601String(),
      direccionMensaje: 'CLI',
      idMensaje: payload.idTokenMeta,
      emit: emit,
    );
  }

  void _handleUpdatePantalla(
    WebSocketMessage message,
    Emitter<ChatListState> emit,
  ) {
    final payload = UpdatePantallaWhatsAppPayload.fromMessage(message);
    if (payload == null) return;

    _updateChatInList(
      idNumero: payload.idNumero,
      mensaje: payload.mensaje,
      tipoMensaje: payload.tipoMensaje.isNotEmpty
          ? payload.tipoMensaje
          : 'text',
      estado: 'sent',
      fechaHora: payload.hora.isNotEmpty
          ? payload.hora
          : DateTime.now().toIso8601String(),
      direccionMensaje: 'ASE',
      idMensaje: payload.idTokenMeta,
      emit: emit,
    );
  }

  void _handleUpdateMensaje(
    WebSocketMessage message,
    Emitter<ChatListState> emit,
  ) {
    final payload = UpdateMensajeWhatsAppPayload.fromMessage(message);
    if (payload == null) return;

    final chats = List<Chat>.from(_allChats);
    final idx = chats.indexWhere((c) => c.idNumero == payload.idNumero);
    if (idx == -1) return;

    if (chats[idx].idTokenMeta == payload.idMensaje) {
      chats[idx] = chats[idx].copyWith(estadoEntrega: payload.estado);
      _allChats = chats;
      _emitFiltered(emit);
    }
  }

  void _updateChatInList({
    required int idNumero,
    required String mensaje,
    required String tipoMensaje,
    required String estado,
    required String fechaHora,
    required String direccionMensaje,
    required String idMensaje,
    required Emitter<ChatListState> emit,
  }) {
    final chats = List<Chat>.from(_allChats);
    final idx = chats.indexWhere((c) => c.idNumero == idNumero);
    if (idx == -1) return;

    final updatedChat = chats[idx].copyWith(
      contenido: mensaje,
      tipo: tipoMensaje,
      estadoEntrega: estado,
      fechaHora: fechaHora,
      direccionMensaje: direccionMensaje,
      idTokenMeta: idMensaje,
    );

    chats.removeAt(idx);
    chats.insert(0, updatedChat);
    _allChats = chats;
    _emitFiltered(emit);
  }
}
