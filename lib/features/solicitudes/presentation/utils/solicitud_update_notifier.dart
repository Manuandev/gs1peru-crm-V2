// lib/features/solicitudes/presentation/utils/solicitud_update_notifier.dart

import 'dart:async';

import 'package:app_crm/features/solicitudes/presentation/bloc/form/solicitud_form_cubit.dart';

/// Payload que viaja por el notifier cada vez que se guarda el wizard sobre
/// una solicitud ya existente (entrada por "Validar"/"Editar ficha", con un
/// `SolicitudDetallePage` vivo debajo en el stack) — mismos datos que ya
/// tiene en memoria el wizard al terminar de guardar, sin volver a pedir
/// nada al backend.
class SolicitudUpdate {
  final String numSol;
  final DatosSolicitante solicitante;
  final DatosFacturacion? facturacion;
  // true si la facturación es con RUC (Factura/razón social) — false si es
  // con documento de persona natural (Boleta/nombre completo). Resuelto por
  // quien notifica (tiene acceso a CatalogsBloc.valoresDefecto.idTipoDocRuc),
  // el bloc que escucha no depende de ningún catálogo.
  final bool facturacionEsRuc;
  final String tipoPersona;
  // Importe total ya calculado (Inversión + IGV, mismo criterio que
  // SeccionResumenComercial) — evita que el bloc necesite CatalogsBloc para
  // recalcularlo.
  final double montoTotal;

  const SolicitudUpdate(
    this.numSol, {
    required this.solicitante,
    required this.facturacion,
    required this.facturacionEsRuc,
    required this.tipoPersona,
    required this.montoTotal,
  });
}

/// Bus de comunicación entre el wizard (`SolicitudResumenView`) y
/// `SolicitudDetalleBloc` — mismo patrón que `LeadUpdateNotifier`/
/// `CobranzaUpdateNotifier` (`core/utils/`), pero vive dentro de
/// `solicitudes/` porque el payload usa tipos propios del feature
/// (`DatosSolicitante`/`DatosFacturacion`) y hoy solo se consume acá.
class SolicitudUpdateNotifier {
  SolicitudUpdateNotifier._();
  static final instance = SolicitudUpdateNotifier._();

  final _controller = StreamController<SolicitudUpdate>.broadcast();
  Stream<SolicitudUpdate> get stream => _controller.stream;

  void notify(SolicitudUpdate update) {
    if (!_controller.isClosed) {
      _controller.add(update);
    }
  }
}
