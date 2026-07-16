// lib/features/solicitudes/presentation/widgets/completar/solicitud_progreso_guardado.dart
//
// Overlay de progreso paso a paso para "Guardar"/"Generar solicitud" — cada
// paso (guardar/generar la solicitud, subir voucher, subir O.C.) aparece
// con spinner al iniciar y pasa a check al completarse; los pasos que no
// aplican (sin archivo adjunto) ni siquiera se agregan a la lista. Usado
// por los 5 botones que disparan guardarSolicitudDesdeWizard +
// subirArchivosPendientes (ver solicitud_guardar_helper.dart y
// solicitudes/CLAUDE.md, "Stepper de progreso").

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';

enum PasoProgresoEstado { cargando, listo }

class PasoProgresoItem {
  final String texto;
  final PasoProgresoEstado estado;

  const PasoProgresoItem(this.texto, this.estado);
}

/// Lista de pasos en curso — vacía cuando no hay ningún guardado en
/// progreso (el overlay se oculta solo). Cada `State` que dispara un
/// guardado crea una instancia propia (`late final`) y la descarta en
/// `dispose()`.
class SolicitudProgreso extends ValueNotifier<List<PasoProgresoItem>> {
  SolicitudProgreso() : super(const []);

  void iniciarPaso(String texto) {
    value = [...value, PasoProgresoItem(texto, PasoProgresoEstado.cargando)];
  }

  /// Marca el último paso agregado como listo (check) — se asume que los
  /// pasos se completan en el mismo orden en que se inician, nunca en
  /// paralelo (coincide con el flujo real: CUD, luego voucher, luego O.C.).
  void completarPasoActual() {
    if (value.isEmpty) return;
    final actualizados = [...value];
    actualizados[actualizados.length - 1] = PasoProgresoItem(
      actualizados.last.texto,
      PasoProgresoEstado.listo,
    );
    value = actualizados;
  }

  void reset() => value = const [];
}

/// Overlay de pantalla completa, mismo patrón visual que `AppLoadingOverlay`
/// (core) pero mostrando una lista de pasos en vez de un solo mensaje.
/// Usar como último hijo de un `Stack`, igual que `AppLoadingOverlay` —
/// se oculta solo (`SizedBox.shrink`) mientras `progreso.value` esté vacío.
class SolicitudProgresoOverlay extends StatelessWidget {
  final SolicitudProgreso progreso;

  const SolicitudProgresoOverlay({super.key, required this.progreso});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<PasoProgresoItem>>(
      valueListenable: progreso,
      builder: (context, pasos, _) {
        if (pasos.isEmpty) return const SizedBox.shrink();
        return Positioned.fill(
          child: Container(
            color: AppColors.black(0.4),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(minWidth: 240),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppSizing.radiusMd),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [for (final paso in pasos) _FilaPaso(paso: paso)],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FilaPaso extends StatelessWidget {
  final PasoProgresoItem paso;

  const _FilaPaso({required this.paso});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: AppSizing.iconMd,
            height: AppSizing.iconMd,
            child: paso.estado == PasoProgresoEstado.cargando
                ? const Padding(
                    padding: EdgeInsets.all(AppSpacing.xxs),
                    child: CircularProgressIndicator(
                      strokeWidth: AppSizing.spinnerStrokeSmall,
                    ),
                  )
                : const Icon(
                    AppIcons.checkCircle,
                    color: AppColors.success,
                    size: AppSizing.iconMd,
                  ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            paso.texto,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
