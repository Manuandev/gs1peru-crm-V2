// lib/features/solicitudes/presentation/widgets/detail/solicitud_detalle_view.dart

import 'package:app_crm/config/router/navigation_extensions.dart';
import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class SolicitudDetalleView extends StatefulWidget {
  final Solicitud solicitud;
  // true cuando se navegó acá desde el botón "Validar" de la card
  // (SolicitudAccionTipo.sinValidar) — cambia el footer de botones, ver
  // _BotonesDetalle y solicitudes/CLAUDE.md.
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
      _progreso.completarPasoActual();
      await Future.delayed(const Duration(milliseconds: 500));
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
        // usa como último respaldo si la solicitud ya no aparece en la
        // lista recién traída (caso raro).
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
              const Text('Detalle de Solicitud'),
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                      0,
                    ),
                    child: const _PasosIndicador(pasoActual: 1),
                  ),

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
                                _SeccionDatosParticipante(detalle: detalle),
                                const SizedBox(height: AppSpacing.sm),
                                _SeccionDatosFacturacion(detalle: detalle),
                                const SizedBox(height: AppSpacing.sm),
                                _SeccionHistorial(historial: detalle.historial),
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
                  _BotonesDetalle(
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

// ── Indicador de pasos ────────────────────────────────────────────────────────

class _PasosIndicador extends StatelessWidget {
  final int pasoActual;

  const _PasosIndicador({required this.pasoActual});

  static const _etiquetas = ['Completar', 'Validar', 'Adjuntar', 'Cobranza'];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < _etiquetas.length; i++)
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // Línea izquierda — transparente en el primer paso
                      Expanded(
                        child: Container(
                          height: 2,
                          color: i > 0
                              ? (i <= pasoActual
                                    ? AppColors.primary
                                    : AppColors.border)
                              : Colors.transparent,
                        ),
                      ),
                      _CirculoPaso(
                        numero: i + 1,
                        activo: (i + 1) == pasoActual,
                        completado: (i + 1) < pasoActual,
                      ),
                      // Línea derecha — transparente en el último paso
                      Expanded(
                        child: Container(
                          height: 2,
                          color: i < _etiquetas.length - 1
                              ? ((i + 1) <= pasoActual
                                    ? AppColors.primary
                                    : AppColors.border)
                              : Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    _etiquetas[i],
                    style: AppTextStyles.labelSmall.copyWith(
                      color: (i + 1) <= pasoActual
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight: (i + 1) == pasoActual
                          ? AppTextStyles.weightSemiBold
                          : AppTextStyles.weightRegular,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CirculoPaso extends StatelessWidget {
  final int numero;
  final bool activo;
  final bool completado;

  const _CirculoPaso({
    required this.numero,
    required this.activo,
    required this.completado,
  });

  @override
  Widget build(BuildContext context) {
    final bool destacado = activo || completado;
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: destacado ? AppColors.primary : AppColors.surface,
        border: Border.all(
          color: destacado ? AppColors.primary : AppColors.border,
          width: 1.5,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$numero',
          style: AppTextStyles.labelSmall.copyWith(
            color: destacado ? AppColors.textOnDark : AppColors.textSecondary,
            fontWeight: AppTextStyles.weightBold,
          ),
        ),
      ),
    );
  }
}

// ── Sección genérica reutilizable ─────────────────────────────────────────────

class _SeccionCard extends StatelessWidget {
  final Color colorIcono;
  final IconData icono;
  final String titulo;
  final List<Widget> children;

  const _SeccionCard({
    required this.colorIcono,
    required this.icono,
    required this.titulo,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizing.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: AppSizing.shadowBlurXs,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colorIcono.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icono,
                  color: colorIcono,
                  size: AppSizing.iconActionSm,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                titulo,
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: AppTextStyles.weightBold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...children,
        ],
      ),
    );
  }
}

// ── Fila etiqueta / valor ─────────────────────────────────────────────────────

class _FilaInfo extends StatelessWidget {
  final String etiqueta;
  final String valor;
  final bool mostrarDivisor;

  const _FilaInfo({
    required this.etiqueta,
    required this.valor,
    this.mostrarDivisor = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 130,
                child: Text(
                  etiqueta,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  valor,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: AppTextStyles.weightMedium,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (mostrarDivisor)
          const Divider(color: AppColors.border, height: 1, thickness: 1),
      ],
    );
  }
}

// ── Datos del participante ────────────────────────────────────────────────────

class _SeccionDatosParticipante extends StatelessWidget {
  final SolicitudDetalle detalle;

  const _SeccionDatosParticipante({required this.detalle});

  @override
  Widget build(BuildContext context) {
    // El SP trae el id crudo de TipoDocumentoItem (SYSTABEXTER02 CODTABLA=
    // 'F01') — se resuelve a abreviatura ("DNI"/"CE"/"RUC"...) contra el
    // mismo catálogo que ya usa el wizard, no viene resuelto del backend.
    final catalogState = context.watch<CatalogsBloc>().state;
    final tiposDocumento = catalogState is CatalogsLoaded
        ? catalogState.tiposDocumento
        : const <TipoDocumentoItem>[];
    final tipoDoc = tiposDocumento
        .where((t) => t.id == detalle.tipoDocumentoId)
        .firstOrNull;

    return _SeccionCard(
      colorIcono: AppColors.primary,
      icono: AppIcons.user,
      titulo: 'Datos del participante',
      children: [
        _FilaInfo(etiqueta: 'Correo', valor: detalle.correo),
        _FilaInfo(etiqueta: 'Celular', valor: detalle.celular),
        _FilaInfo(
          etiqueta: 'Documento',
          valor: '${tipoDoc?.abreviatura ?? ''} ${detalle.numDoc}'.trim(),
        ),
        _FilaInfo(
          etiqueta: 'Cargo',
          valor: detalle.cargo,
          mostrarDivisor: false,
        ),
      ],
    );
  }
}

// ── Datos de facturación ──────────────────────────────────────────────────────

class _SeccionDatosFacturacion extends StatelessWidget {
  final SolicitudDetalle detalle;

  const _SeccionDatosFacturacion({required this.detalle});

  @override
  Widget build(BuildContext context) {
    return _SeccionCard(
      colorIcono: AppColors.purple,
      icono: AppIcons.receipt,
      titulo: 'Datos de facturación',
      children: [
        _FilaInfo(
          etiqueta: 'Tipo de comprobante',
          valor: detalle.facTipoComprobante,
        ),
        _FilaInfo(etiqueta: 'Razón social', valor: detalle.facRazonSocial),
        _FilaInfo(etiqueta: 'RUC', valor: detalle.facRuc),
        _FilaInfo(
          etiqueta: 'Dirección fiscal',
          valor: detalle.facDireccion,
          mostrarDivisor: false,
        ),
      ],
    );
  }
}

// ── Historial ─────────────────────────────────────────────────────────────────

class _SeccionHistorial extends StatelessWidget {
  final List<HistorialSolicitud> historial;

  const _SeccionHistorial({required this.historial});

  @override
  Widget build(BuildContext context) {
    if (historial.isEmpty) {
      return _SeccionCard(
        colorIcono: AppColors.warning,
        icono: AppIcons.time,
        titulo: 'Historial',
        children: const [
          _FilaInfo(
            etiqueta: '',
            valor: 'Todavía no hay movimientos registrados.',
            mostrarDivisor: false,
          ),
        ],
      );
    }

    return _SeccionCard(
      colorIcono: AppColors.warning,
      icono: AppIcons.time,
      titulo: 'Historial',
      children: [
        for (int i = 0; i < historial.length; i++)
          _EntradaHistorial(
            fecha: historial[i].fecha.formatDate(AppDateFormat.shortDate),
            hora: historial[i].fecha.formatDate(AppDateFormat.hourMinute),
            titulo: historial[i].titulo,
            descripcion: historial[i].descripcion,
            activo: i == 0,
            esUltimo: i == historial.length - 1,
          ),
      ],
    );
  }
}

class _EntradaHistorial extends StatelessWidget {
  final String fecha;
  final String hora;
  final String titulo;
  final String descripcion;
  final bool activo;
  final bool esUltimo;

  const _EntradaHistorial({
    required this.fecha,
    required this.hora,
    required this.titulo,
    required this.descripcion,
    required this.activo,
    required this.esUltimo,
  });

  @override
  Widget build(BuildContext context) {
    final Color colorDot = activo ? AppColors.warning : AppColors.border;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Columna: punto + línea vertical
        SizedBox(
          width: 16,
          child: Column(
            children: [
              const SizedBox(height: 3),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: colorDot,
                  shape: BoxShape.circle,
                ),
              ),
              if (!esUltimo)
                Container(
                  width: 2,
                  height: 52,
                  margin: const EdgeInsets.only(top: 3),
                  color: AppColors.border,
                ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),

        // Contenido del evento
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: esUltimo ? 0 : AppSpacing.xs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      fecha,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      hora,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  titulo,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: AppTextStyles.weightSemiBold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  descripcion,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Botones de acción al pie ──────────────────────────────────────────────────

class _BotonesDetalle extends StatelessWidget {
  final Solicitud solicitud;
  // true si se entró desde el botón "Validar" de la card — en ese caso el
  // botón de editar SIEMPRE se muestra (con el texto "Validar" en vez de
  // "Editar ficha", mismo mecanismo — abre el wizard en modoEdicion:true),
  // sin importar Solicitud.puedeEditar. Si se entró por "Ver", se sigue
  // usando puedeEditar (idEstado == 0) como antes.
  final bool origenValidar;

  const _BotonesDetalle({required this.solicitud, this.origenValidar = false});

  @override
  Widget build(BuildContext context) {
    final mostrarEditar = origenValidar || solicitud.puedeEditar;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (mostrarEditar) ...[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.goToFichaCompletarSolicitud(
                  solicitud: solicitud,
                  modoEdicion: true,
                ),
                icon: const Icon(AppIcons.edit, size: AppSizing.iconActionSm),
                label: Text(origenValidar ? 'Validar' : 'Editar ficha'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.border),
                  minimumSize: const Size.fromHeight(AppSizing.buttonHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizing.radiusMd),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: FilledButton.icon(
              onPressed: () => context.goToFichaCompletarSolicitud(
                solicitud: solicitud,
                modoEdicion: false,
              ),
              icon: const Icon(
                AppIcons.visibility,
                size: AppSizing.iconActionSm,
              ),
              label: const Text('Revisar solicitud'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnDark,
                minimumSize: const Size.fromHeight(AppSizing.buttonHeight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizing.radiusMd),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
