// lib\core\network\websocket\signalr_service.dart

import 'dart:async';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/index_dependencies.dart';

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

  final _session = SessionService(); // ✅ sin IAuthRepository

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
  bool _isStopping = false;

  static const Duration _heartbeatInterval = Duration(seconds: 15);
  static const Duration _pingTimeout = Duration(seconds: 8);

  static const Duration _pauseBetweenCycles = Duration(minutes: 1);

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
        WakelockPlus.enable();
        _startHeartbeat();
        _startConnectivityMonitoring();
        await _registrarTokenFCM();
        return;
      } catch (_) {
        currentAttempt++;
        _reconnectAttempts++;
        _emitState(WebSocketConnectionState.reconnecting);

        if (currentAttempt < maxAttempts && _hasInternet) {
          // final delays = [300, 500];
          final delays = [500, 1000];
          await Future.delayed(
            Duration(milliseconds: delays[(currentAttempt - 1).clamp(0, 1)]),
          );
        }
      }
    }

    // Agotamos intentos del while — programar reconexión con backoff
    // _isConnecting = false;
    // _emitState(WebSocketConnectionState.disconnected);

    // if (_currentState != WebSocketConnectionState.manuallyClosed &&
    //     _hasInternet) {
    //   _scheduleReconnect();
    // }
    _isConnecting = false;

    if (_currentState == WebSocketConnectionState.manuallyClosed ||
        !_hasInternet) {
      _emitState(WebSocketConnectionState.disconnected);
      _startConnectivityMonitoring();
      return;
    }

    _scheduleCyclePause();
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
    WakelockPlus.disable();
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
      // debugPrint('MENSAJE ENVIADO: $message');
      _hubConnection!.invoke('OnMessage', args: <Object>[message]);
      return true;
    } catch (_) {
      _onUnexpectedDisconnect();
      return false;
    }
  }

  // ─── Construcción de conexión ─────────────────────────────────────────────

  HubConnection _buildConnection() {
    final user = _session.user!;

    // https://natcodee.net:9003/socket/?token=${$config.token}&tipoCliente=web&coduser=${$global.user.coduser}
    final connectionUrl =
        '${ApiConstants.urlWebSocket}'
        '?token=${user.token}'
        '&tipoCliente=mobile'
        '&coduser=${user.codUser}';

    return HubConnectionBuilder().withUrl(connectionUrl).build()
      ..serverTimeoutInMilliseconds =
          60000 // ← 60s antes de considerar caída
      ..keepAliveIntervalInMilliseconds = 10000; // ← ping nativo cada 10s
  }

  void _registerHubHandlers() {
    // Callback al cerrar la conexión inesperadamente
    _hubConnection!.onclose(({Exception? error}) async {
      // FIX: si el cierre fue intencional, no reconectar
      if (_isStopping) return;
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
    // debugPrint('MENSAJE RECIBIDO: $rawMessage');

    // Si llegó un mensaje, la conexión está viva
    if (!isConnected && _isHubConnected()) {
      _emitState(WebSocketConnectionState.connected);
    }
    _reconnectAttempts = 0;

    // Parsear y emitir al stream — las features escuchan aquí
    final WebSocketMessage? message = WebSocketMessageParser.parse(rawMessage);
    if (message != null) {
      MessageDispatcher.instance.dispatch(
        message,
      ); // 👈 un solo punto de entrada
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

  // ─── Pausa entre ciclos (1 minuto) ───────────────────────────────────────

  /// Llamado cuando un ciclo completo de [_attemptsPerCycle] intentos falla.
  /// Espera [_pauseBetweenCycles] y luego inicia un nuevo ciclo desde cero.
  void _scheduleCyclePause() {
    if (_currentState == WebSocketConnectionState.manuallyClosed) return;
    if (isConnected) return;

    _reconnectTimer?.cancel();


    // Emitir un estado que indique pausa larga (reconnecting sirve; si tienes
    // un estado específico como "waitingCycle" puedes usarlo aquí).
    _emitState(WebSocketConnectionState.reconnecting);

    _reconnectTimer = Timer(_pauseBetweenCycles, () async {
      if (_currentState == WebSocketConnectionState.manuallyClosed) return;
      if (isConnected) return;
      if (!_hasInternet) return;

      // Reiniciar contadores y comenzar un ciclo nuevo
      _reconnectAttempts = 0;
      _isConnecting = false;
      await connect();
    });
  }

  // ─── Reconexión con backoff exponencial (desconexión inesperada) ──────────

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
    _isStopping = true;

    if (_hubConnection != null) {
      try {
        // FIX: evita que stop() dispare onclose y programe una reconexión no deseada
        _isStopping = true;
        _hubConnection!.onclose(({Exception? error}) {});
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
        _isStopping = false;
      }
    }
  }

  void _onUnexpectedDisconnect() {
    _emitState(WebSocketConnectionState.disconnected);
    _stopHeartbeat();

    // FIX: cancelar timer pendiente para evitar dos flujos de reconexión en paralelo
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

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

  Future<void> _registrarTokenFCM() async {
    try {
      final token = await FirebaseNotificationService.instance.obtenerToken();
      if (token == null || token.isEmpty) return;
      _hubConnection?.invoke('RegistrarTokenFCM', args: <Object>[token]);
      // debugPrint('[FCM] Token registrado en hub');
    } catch (e) {
      // debugPrint('[FCM] Error registrando token en hub: $e');
    }
  }

  @override
  Future<void> limpiarTokenFCM() async {
    try {
      if (!_isHubConnected()) return;
      await _hubConnection?.invoke('LimpiarTokenFCM');
      // debugPrint('[FCM] Token desregistrado');
    } catch (e) {
      // debugPrint('[FCM] Error desregistrando token: $e');
    }
  }
}
