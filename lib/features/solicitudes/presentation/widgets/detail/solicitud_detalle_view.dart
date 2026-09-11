// lib/features/solicitudes/presentation/widgets/detail/solicitud_detalle_view.dart

import 'package:flutter/material.dart';

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class SolicitudDetalleView extends StatefulWidget {
  final Solicitud solicitud;
  // true cuando se navegó acá desde el botón "Validar" de la card
  // (SolicitudAccionTipo.sinValidar) — cambia el footer de botones, ver
  // BotonesDetalle y solicitudes/CLAUDE.md.
  final bool origenValidar;

  const SolicitudDetalleView({
    super.key,
    required this.solicitud,
    this.origenValidar = false,
  });

  @override
  State<SolicitudDetalleView> createState() => _SolicitudDetalleViewState();
}

class _SolicitudDetalleViewState extends State<SolicitudDetalleView> {
  // Progreso del borrado (spinner → check) — mismo widget que ya usa el
  // wizard para Guardar/Generar, ver
  // completar/solicitud_progreso_guardado.dart.
  final SolicitudProgreso _progreso = SolicitudProgreso();

  @override
  void dispose() {
    _progreso.dispose();
    super.dispose();
  }

  Future<void> _eliminarSolicitud(Solicitud solicitud) async {
    final confirmado = await context.showConfirmDialog(
      title: 'Eliminar solicitud',
      message:
          '¿Deseas eliminar esta solicitud? Esta acción no se puede deshacer.',
      confirmText: 'Eliminar',
      cancelText: 'Cancelar',
    );
    if (!confirmado || !mounted) return;

    _progreso.iniciarPaso('Eliminando solicitud...');
    final result = await EliminarSolicitudUseCase(
      context.read<SolicitudRepository>(),
    ).call(solicitud.idSolicitud);

    if (!mounted) return;

    if (result is CrudOk) {
      _progreso.mostrarExito('Solicitud eliminada correctamente');
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;
      _progreso.reset();
      // clearAndPush — igual que entrar de nuevo a la pantalla, la lista
      // se recarga fresca (no queda la solicitud eliminada en memoria).
      context.goToSolicitudes();
      return;
    }

    _progreso.reset();
    switch (result) {
      case CrudError(:final message):
        AppSnackBar.error(context, message);
      case CrudAlert(:final message):
        AppSnackBar.warning(context, message);
      case CrudNoInternet():
        AppSnackBar.error(context, 'Sin conexión a Internet.');
      case CrudEmpty():
        AppSnackBar.error(context, 'Respuesta inesperada del servidor.');
      case CrudOk():
        break; // ya se maneja arriba
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SolicitudDetalleBloc, SolicitudDetalleState>(
      builder: (context, state) {
        // Nunca se usa el Solicitud de navegación para pintar — puede venir
        // de una lista cacheada hace rato, o de un Solicitud "de paso" casi
        // vacío armado desde una Negociacion (ver NegociacionCard). Solo se
        // usa como último respaldo si el 'DV' no trajo la cabecera (SP
        // desplegado sin la sección [2]).
        final solicitudActual = state is SolicitudDetalleSuccess
            ? (state.solicitud ?? widget.solicitud)
            : widget.solicitud;

        return BasePage(
          onPop: () => context.goBack(),
          drawerSide: DrawerSide.none,
          bodyPadding: EdgeInsets.zero,
          titleWidget: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Detalle de solicitud'),
              Text(
                'Revisa la información y continúa con el proceso',
                style: AppTextStyles.labelSmall.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onPrimary.withValues(alpha: 0.85),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          appBarLeadingButtons: [
            IconButton(
              onPressed: () => context.goBack(),
              icon: Icon(
                AppIcons.back,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
          // Solo se puede eliminar mientras siga sin validar — una vez
          // validada, no se muestra el tacho (mismo criterio que la card).
          appBarTrailingButtons: solicitudActual.ibValidado
              ? null
              : [
                  IconButton(
                    onPressed: () => _eliminarSolicitud(solicitudActual),
                    icon: Icon(
                      AppIcons.delete,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
          body: Stack(
            children: [
              Column(
                children: [
                  // ── Indicador de pasos ─────────────────────────────
                  // Padding(
                  //   padding: const EdgeInsets.fromLTRB(
                  //     AppSpacing.md,
                  //     AppSpacing.sm,
                  //     AppSpacing.md,
                  //     0,
                  //   ),
                  //   child: const PasosIndicador(pasoActual: 1),
                  // ),

                  // ── Contenido scrollable ───────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.lg,
                      ),
                      child: Column(
                        children: [
                          SolicitudCard(
                            solicitud: solicitudActual,
                            mostrarBotones: false,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          switch (state) {
                            SolicitudDetalleLoading() ||
                            SolicitudDetalleInitial() => const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: AppSpacing.xl,
                              ),
                              child: AppLoadingView(),
                            ),
                            SolicitudDetalleError(:final mensaje) =>
                              AppErrorView(
                                message: mensaje,
                                onRetry: () =>
                                    context.read<SolicitudDetalleBloc>().add(
                                      SolicitudDetalleStarted(
                                        widget.solicitud.idSolicitud,
                                      ),
                                    ),
                              ),
                            SolicitudDetalleSuccess(:final detalle) => Column(
                              children: [
                                SeccionDatosParticipante(detalle: detalle),
                                const SizedBox(height: AppSpacing.sm),
                                SeccionDatosFacturacion(detalle: detalle),
                                const SizedBox(height: AppSpacing.sm),
                                SeccionHistorial(historial: detalle.historial),
                              ],
                            ),
                            _ => const SizedBox.shrink(),
                          },
                          const SizedBox(height: AppSpacing.lg),
                        ],
                      ),
                    ),
                  ),

                  // ── Botones de acción fijos al pie ─────────────────
                  BotonesDetalle(
                    solicitud: solicitudActual,
                    origenValidar: widget.origenValidar,
                  ),
                ],
              ),
              SolicitudProgresoOverlay(progreso: _progreso),
            ],
          ),
        );
      },
    );
  }
}
