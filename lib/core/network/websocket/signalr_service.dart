import 'dart:async';

import 'package:app_crm/core/constants/api_constants.dart';
import 'package:app_crm/core/utils/string/string_utils.dart';
import 'package:app_crm/features/auth/domain/repositories/i_auth_repository.dart';

import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'i_signalr_service.dart';
import 'websocket_connection_state.dart';
import 'websocket_message.dart';
import 'websocket_message_parser.dart';

/// Implementación del servicio SignalR.
///
/// Responsabilidades de ESTA clase:
///   ✅ Manejar la conexión / reconexión / heartbeat
///   ✅ Monitorear la conectividad de red
///   ✅ Parsear mensajes y emitirlos al stream
///   ❌ NO contiene lógica de negocio (eso va en cada feature)
///   ❌ NO navega directamente
///   ❌ NO conoce BLoCs ni widgets
///
/// Cada feature se suscribe a [messageStream] y filtra por proceso:
/// ```dart
/// _signalRService.messageStream
///   .where((msg) => msg.process == 'LEAD')
///   .listen(_handleLeadMessage);
/// ```
class SignalRService implements ISignalRService {
  // ─── Singleton ────────────────────────────────────────────────────────────

  SignalRService._();
  static final SignalRService instance = SignalRService._();

  // ─── Dependencias ─────────────────────────────────────────────────────────

  late IAuthRepository _authRepository;

  /// Llama esto una sola vez al arrancar la app, antes de usar el servicio.
  void init(IAuthRepository authRepository) {
    _authRepository = authRepository;
  }

  // ─── Streams ──────────────────────────────────────────────────────────────

  final StreamController<WebSocketConnectionState> _connectionStateController =
      StreamController<WebSocketConnectionState>.broadcast();

  final StreamController<WebSocketMessage> _messageController =
      StreamController<WebSocketMessage>.broadcast();

  @override
  Stream<WebSocketConnectionState> get connectionStateStream =>
      _connectionStateController.stream;

  @override
  Stream<WebSocketMessage> get messageStream => _messageController.stream;

  // ─── Estado interno ───────────────────────────────────────────────────────

  HubConnection? _hubConnection;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;

  WebSocketConnectionState _currentState =
      WebSocketConnectionState.disconnected;

  int _reconnectAttempts = 0;
  bool _isConnecting = false;
  bool _hasInternet = true;

  static const Duration _heartbeatInterval = Duration(seconds: 15);
  static const Duration _pingTimeout = Duration(seconds: 3);

  // ─── Getters públicos ─────────────────────────────────────────────────────

  @override
  WebSocketConnectionState get currentState => _currentState;

  @override
  bool get isConnected =>
      _currentState == WebSocketConnectionState.connected && _isHubConnected();

  // ─── Ciclo de vida ────────────────────────────────────────────────────────

  @override
  Future<void> connect() async {
    // Guards de seguridad antes de conectar
    if (_authRepository.currentUser?.token == null) return;
    if (_isConnecting) return;
    if (_currentState == WebSocketConnectionState.manuallyClosed) return;
    if (!_hasInternet) return;
    if (isConnected) return;

    _isConnecting = true;
    _emitState(WebSocketConnectionState.connecting);

    const int maxAttempts = 2;
    int currentAttempt = 0;

    while (currentAttempt < maxAttempts &&
        !isConnected &&
        _currentState != WebSocketConnectionState.manuallyClosed &&
        _hasInternet) {
      try {
        await _stopCurrentConnection();
        _hubConnection = _buildConnection();
        _registerHubHandlers();

        final timeout = currentAttempt == 0
            ? const Duration(seconds: 3)
            : const Duration(seconds: 5);

        await _hubConnection!.start()?.timeout(
          timeout,
          onTimeout: () =>
              throw TimeoutException('Timeout ${timeout.inSeconds}s'),
        );

        if (!_isHubConnected()) {
          throw Exception('Hub no conectado después de start()');
        }

        // ✅ Conexión exitosa
        _reconnectAttempts = 0;
        _isConnecting = false;
        _emitState(WebSocketConnectionState.connected);
        _startHeartbeat();
        _startConnectivityMonitoring();
        return;
      } catch (_) {
        currentAttempt++;
        _reconnectAttempts++;
        _emitState(WebSocketConnectionState.reconnecting);

        if (currentAttempt < maxAttempts && _hasInternet) {
          final delays = [300, 500];
          await Future.delayed(
            Duration(milliseconds: delays[(currentAttempt - 1).clamp(0, 1)]),
          );
        }
      }
    }

    // Agotamos intentos del while — programar reconexión con backoff
    _isConnecting = false;
    _emitState(WebSocketConnectionState.disconnected);

    if (_currentState != WebSocketConnectionState.manuallyClosed &&
        _hasInternet) {
      _scheduleReconnect();
    }

    _startConnectivityMonitoring();
  }

  @override
  Future<void> forceReconnect() async {
    if (isConnected) return;

    // Esperar si hay una conexión en curso (máx 1 segundo)
    int wait = 0;
    while (_isConnecting && wait < 2) {
      await Future.delayed(const Duration(milliseconds: 500));
      wait++;
    }

    _isConnecting = false;
    await _stopCurrentConnection();
    _cancelAllTimers();

    await connect();
  }

  @override
  Future<void> reconnect() async {
    _emitState(WebSocketConnectionState.disconnected);
    await forceReconnect();
  }

  @override
  Future<void> close() async {
    _emitState(WebSocketConnectionState.manuallyClosed);
    _isConnecting = false;
    _reconnectAttempts = 0;

    _cancelAllTimers();
    await _connectivitySubscription?.cancel();
    _connectivitySubscription = null;

    await _stopCurrentConnection();
  }

  @override
  Future<void> reset() async {
    await close();
    _emitState(WebSocketConnectionState.disconnected);
  }

  @override
  Future<void> dispose() async {
    await close();
    await _connectionStateController.close();
    await _messageController.close();
  }

  // ─── Envío de mensajes ────────────────────────────────────────────────────

  @override
  bool sendMessage(String message) {
    if (!_isHubConnected()) {
      _onUnexpectedDisconnect();
      return false;
    }

    try {
      _hubConnection!.invoke('OnMessage', args: <Object>[message]);
      return true;
    } catch (_) {
      _onUnexpectedDisconnect();
      return false;
    }
  }

  // ─── Construcción de conexión ─────────────────────────────────────────────

  HubConnection _buildConnection() {
    final user = _authRepository.currentUser!;

    final connectionUrl =
        '${ApiConstants.urlWebSocket}'
        '?clientType=mobile'
        '&token=${user.token}'
        '&client=${convertStringToHex(user.codUser)}';

    return HubConnectionBuilder().withUrl(connectionUrl).build();
  }

  void _registerHubHandlers() {
    // Callback al cerrar la conexión inesperadamente
    _hubConnection!.onclose(({Exception? error}) async {
      if (_currentState == WebSocketConnectionState.manuallyClosed) return;

      _stopHeartbeat();
      _emitState(WebSocketConnectionState.disconnected);
      _isConnecting = false;

      if (_hasInternet) {
        _scheduleReconnect();
      }
    });

    // ─── Receptor de mensajes ─────────────────────────────────────────────
    // Este handler solo parsea y emite al stream.
    // La lógica de negocio vive en los handlers de cada feature.
    _hubConnection!.on('broadcastMessage', (rawMessage) {
      _handleIncomingMessage(rawMessage);
    });
  }

  // ─── Manejo de mensajes ───────────────────────────────────────────────────

  void _handleIncomingMessage(dynamic rawMessage) {
    // Si llegó un mensaje, la conexión está viva
    if (!isConnected && _isHubConnected()) {
      _emitState(WebSocketConnectionState.connected);
    }
    _reconnectAttempts = 0;

    // Parsear y emitir al stream — las features escuchan aquí
    final WebSocketMessage? message = WebSocketMessageParser.parse(rawMessage);
    if (message != null && !_messageController.isClosed) {
      _messageController.add(message);
    }
  }

  // ─── Heartbeat ────────────────────────────────────────────────────────────

  void _startHeartbeat() {
    _stopHeartbeat();

    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) async {
      if (!_isHubConnected() || !_hasInternet) {
        _stopHeartbeat();
        _onUnexpectedDisconnect();
        return;
      }

      try {
        await _hubConnection!
            .invoke('Ping')
            .timeout(
              _pingTimeout,
              onTimeout: () => throw TimeoutException('Ping timeout'),
            );
      } catch (_) {
        _stopHeartbeat();
        _onUnexpectedDisconnect();
      }
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  // ─── Reconexión con backoff exponencial ──────────────────────────────────

  void _scheduleReconnect() {
    if (_currentState == WebSocketConnectionState.manuallyClosed) return;
    if (isConnected) return;

    _reconnectTimer?.cancel();

    // Backoff: 500ms → 1s → 2s → 5s → 10s
    const delays = [500, 1000, 2000, 5000, 10000];
    final waitMs = delays[(_reconnectAttempts - 1).clamp(0, delays.length - 1)];

    _emitState(WebSocketConnectionState.reconnecting);

    _reconnectTimer = Timer(Duration(milliseconds: waitMs), () async {
      if (_currentState != WebSocketConnectionState.manuallyClosed &&
          !isConnected) {
        _reconnectAttempts++;
        _isConnecting = false;
        await connect();
      }
    });
  }

  // ─── Conectividad de red ──────────────────────────────────────────────────

  void _startConnectivityMonitoring() {
    _connectivitySubscription?.cancel();

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      _handleConnectivityChange(results);
    });
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) async {
    final hasNetwork =
        results.isNotEmpty && !results.contains(ConnectivityResult.none);

    if (!hasNetwork) {
      _hasInternet = false;
      _cancelAllTimers();
      _stopHeartbeat();
      _emitState(WebSocketConnectionState.noInternet);
      await _stopCurrentConnection();
    } else {
      _hasInternet = true;

      if (!isConnected &&
          _currentState != WebSocketConnectionState.manuallyClosed &&
          !_isConnecting) {
        _reconnectAttempts = 0;
        await forceReconnect();
      }
    }
  }

  // ─── Helpers privados ─────────────────────────────────────────────────────

  bool _isHubConnected() {
    return _hubConnection != null &&
        _hubConnection!.state == HubConnectionState.Connected;
  }

  Future<void> _stopCurrentConnection() async {
    if (_hubConnection != null) {
      try {
        if (_hubConnection!.state == HubConnectionState.Connected ||
            _hubConnection!.state == HubConnectionState.Connecting) {
          await _hubConnection!.stop().timeout(
            const Duration(seconds: 2),
            onTimeout: () {},
          );
        }
      } catch (_) {
      } finally {
        _hubConnection = null;
      }
    }
  }

  void _onUnexpectedDisconnect() {
    _emitState(WebSocketConnectionState.disconnected);
    _stopHeartbeat();

    if (_hasInternet &&
        _currentState != WebSocketConnectionState.manuallyClosed &&
        !_isConnecting) {
      _isConnecting = false;
      connect();
    }
  }

  void _emitState(WebSocketConnectionState state) {
    if (_currentState == state) return; // Evitar emitir el mismo estado
    _currentState = state;
    if (!_connectionStateController.isClosed) {
      _connectionStateController.add(state);
    }
  }

  void _cancelAllTimers() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }
}
