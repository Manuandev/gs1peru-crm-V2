// lib/features/solicitudes/presentation/widgets/completar/solicitud_progreso_guardado.dart
//
// Overlay de progreso para "Guardar"/"Generar solicitud" — reusa
// AppProcessOverlay (core, mismo logo con resplandor + check animado que
// EditLeadPortrait/EditContactoSimplePortrait). El guardado real puede tener
// varios pasos (guardar la solicitud, subir voucher, subir O.C.) — mientras
// van corriendo, el overlay se queda en el estado "cargando" y SOLO cambia
// el mensaje de un paso a otro (nunca muestra un check intermedio); el
// check animado aparece recién cuando TODO terminó, vía mostrarExito().
// Usado por los 5 botones que disparan guardarSolicitudDesdeWizard +
// subirArchivosPendientes (ver solicitud_guardar_helper.dart y
// solicitudes/CLAUDE.md, "Stepper de progreso").

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';

enum SolicitudProgresoEstado { cargando, exito }

class SolicitudProgresoValor {
  final SolicitudProgresoEstado? estado; // null = overlay oculto
  final String mensaje;

  const SolicitudProgresoValor({this.estado, this.mensaje = ''});
}

/// Estado del guardado en curso — `estado == null` cuando no hay ningún
/// guardado en progreso (el overlay se oculta solo). Cada `State` que
/// dispara un guardado crea una instancia propia (`late final`) y la
/// descarta en `dispose()`.
class SolicitudProgreso extends ValueNotifier<SolicitudProgresoValor> {
  SolicitudProgreso() : super(const SolicitudProgresoValor());

  /// Arranca o cambia de paso — solo actualiza el mensaje mientras se queda
  /// en "cargando", nunca muestra un check intermedio entre pasos.
  void iniciarPaso(String texto) {
    value = SolicitudProgresoValor(
      estado: SolicitudProgresoEstado.cargando,
      mensaje: texto,
    );
  }

  /// Todo el flujo terminó con éxito (guardado + archivos, si había) — recién
  /// acá se muestra el check animado.
  void mostrarExito(String mensaje) {
    value = SolicitudProgresoValor(
      estado: SolicitudProgresoEstado.exito,
      mensaje: mensaje,
    );
  }

  void reset() => value = const SolicitudProgresoValor();
}

/// Overlay de pantalla completa — usar como último hijo de un `Stack`, igual
/// que `AppLoadingOverlay`/`AppProcessOverlay` — se oculta solo
/// (`SizedBox.shrink`) mientras `progreso.value.estado` sea `null`.
class SolicitudProgresoOverlay extends StatelessWidget {
  final SolicitudProgreso progreso;

  const SolicitudProgresoOverlay({super.key, required this.progreso});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SolicitudProgresoValor>(
      valueListenable: progreso,
      builder: (context, valor, _) {
        if (valor.estado == null) return const SizedBox.shrink();
        return AppProcessOverlay(
          status: valor.estado == SolicitudProgresoEstado.cargando
              ? AppProcessStatus.cargando
              : AppProcessStatus.exito,
          loadingMessage: valor.mensaje,
          successMessage: valor.mensaje,
        );
      },
    );
  }
}
