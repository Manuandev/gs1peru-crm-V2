// lib/core/network/interceptors/update_required_interceptor.dart
//
// Corta cualquier llamada CUD (guardar/crear/actualizar) cuando hay una
// actualización de la app pendiente — pedido explícito del jefe del
// usuario: "no se va a poder guardar hasta que actualice, ni siquiera
// mandarlo a la base de datos". Se detecta por convención de nombre de ruta
// del proyecto (LST = lectura, CUD = create/update/delete, ver
// core/CLAUDE.md → ApiConstants) — cualquier endpoint nuevo que siga
// llamándose "...Cud..." queda cubierto automáticamente, sin tocar este
// archivo.
//
// No cubre envío de WhatsApp ni subida de multimedia — esos van por
// SignalR o por endpoints con otro nombre (SendMessageWhatsApp,
// GuardarMultimediaWhatsApp), fuera de este interceptor a propósito (ver
// auth/CLAUDE.md).
//
// El AppException queda igual que cualquier otro error de red — cada
// pantalla ya lo muestra solo con su propio AppSnackBar.error(...) vía
// ApiError/CrudError, sin necesidad de tocar ningún botón "Guardar" uno
// por uno.

import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';

class UpdateRequiredInterceptor extends Interceptor {
  static const _mensaje =
      'Hay una actualización disponible. No es posible guardar cambios '
      'hasta actualizar la aplicación. Reinicia la app para actualizarla.';

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_esLlamadaCud(options.path)) return handler.next(options);

    final pendiente = await AppUpdateService().obtenerPendiente();
    if (pendiente == null) return handler.next(options);

    handler.reject(
      DioException(
        requestOptions: options,
        error: const AppException(_mensaje),
        type: DioExceptionType.cancel,
      ),
    );
  }

  bool _esLlamadaCud(String path) => path.toLowerCase().contains('cud');
}
