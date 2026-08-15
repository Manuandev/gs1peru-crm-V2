// lib/features/solicitudes/presentation/widgets/completar/solicitud_participantes_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class SolicitudParticipantesView extends StatefulWidget {
  final Solicitud solicitud;
  final bool modoEdicion;
  // Avanza al paso 3 (Facturación) o al 4 (Resumen, si se saltó Facturación
  // por tener solo invitados) dentro del mismo SolicitudWizardView.
  final ValueChanged<int> onContinuar;
  // Retrocede al paso 1 (Solicitante) dentro del mismo SolicitudWizardView.
  // Solo el paso 1 tiene un botón "Cancelar" que sale del wizard — acá y en
  // los pasos 3/4 es "Atrás", un simple retroceso sin confirmación ni
  // pérdida de datos (todo lo tipeado sigue vivo en los cubits compartidos).
  final VoidCallback onAtras;

  const SolicitudParticipantesView({
    super.key,
    required this.solicitud,
    required this.modoEdicion,
    required this.onContinuar,
    required this.onAtras,
  });

  @override
  State<SolicitudParticipantesView> createState() =>
      _SolicitudParticipantesViewState();
}

class _SolicitudParticipantesViewState
    extends State<SolicitudParticipantesView> {
  // true mientras se guarda el borrador (botón "Guardar")
  bool _guardando = false;

  // Pasos del guardado (Guardar solicitud → Subiendo voucher/O.C.) para
  // el overlay de progreso — ver solicitud_progreso_guardado.dart.
  final SolicitudProgreso _progreso = SolicitudProgreso();

  @override
  void dispose() {
    _progreso.dispose();
    super.dispose();
  }

  // null si esta solicitud no viene de una negociación con precio ya
  // definido. Cuando sí viene, el importe sugerido ya no es
  // `precioBaseLead` (precio por unidad ANTES del descuento) — es el precio
  // total de la negociación (ya con el descuento aplicado) repartido entre
  // la cantidad esperada de participantes, sin IGV (el IGV se vuelve a
  // sumar en el total del footer, ver ResumenInversion). Ej.: precio total
  // 280, cantidad 2 → 140 c/u con IGV → 118.64 sin IGV. `precioBaseLead`
  // sigue existiendo, pero solo para avisoPrecioTotalNoCalza (ver
  // solicitud_guardar_helper.dart) — ya no para esto. El importe sigue
  // siendo editable siempre (ver
  // participante_form_sheet.dart), esto es solo una sugerencia inicial.
  //
  // Revert 2026-08-15 del revert del 2026-08-05 — ver
  // solicitudes/CLAUDE.md. El último participante esperado YA NO recibe
  // "lo que falta" en vez de la división simple: esa excepción existía para
  // que la SUMA de importes calzara exacto contra `precioTotalLead`, pero
  // desde el fix del 2026-08-14/15 (ResumenInversion/SeccionResumenComercial
  // y ahora también SolicitudRemoteDatasource.guardarSolicitud) el Importe
  // total ya no se calcula sumando Importe+IGV — se fija DIRECTO en
  // `precioTotalLead` cuando la solicitud está completa, sin importar cómo
  // sumen los importes individuales. Absorber el centavo en el Importe del
  // último participante ya no es necesario y contradice la regla de negocio
  // ya establecida en el resto del sistema ("el centavo se absorbe siempre
  // en el IGV, nunca en el Importe/Inversión") — ahora los N participantes
  // reciben la misma sugerencia, y cualquier centavo de diferencia lo
  // absorbe el IGV (agregado y del último Pagante), no el Importe.
  double? _importeFijo(BuildContext context) {
    final formState = context.read<SolicitudFormCubit>().state;
    final cantidadEsperada = formState.cantidadEsperada;
    if (cantidadEsperada == null || cantidadEsperada == 0) return null;

    final catalogState = context.read<CatalogsBloc>().state;
    final igvPorcentaje = catalogState is CatalogsLoaded
        ? catalogState.igvPorcentaje
        : 0.0;

    final totalSinIgv = formState.precioTotalLead / (1 + igvPorcentaje / 100);
    return totalSinIgv / cantidadEsperada;
  }

  void _abrirFormularioNuevo(BuildContext context) {
    mostrarFormularioParticipante(
      context,
      importeFijo: _importeFijo(context),
      onGuardar: (p) => context.read<ParticipantesCubit>().agregar(p),
    );
  }

  void _abrirFormularioEditar(
    BuildContext context,
    ParticipanteLocal participante,
  ) {
    mostrarFormularioParticipante(
      context,
      participante: participante,
      importeFijo: _importeFijo(context),
      onGuardar: (p) => context.read<ParticipantesCubit>().editar(p),
    );
  }

  Future<void> _confirmarEliminarTodos(BuildContext context) async {
    final cubit = context.read<ParticipantesCubit>();
    final confirmado = await context.showConfirmDialog(
      title: 'Eliminar participantes',
      message: '¿Deseas eliminar a todos los participantes?',
      confirmText: 'Eliminar',
      cancelText: 'Cancelar',
    );
    if (confirmado) cubit.eliminarTodos();
  }

  // "Siguiente" (2026-07-17, pedido de negocio): valida que haya al menos 1
  // participante y GUARDA de verdad (borrador) antes de avanzar — mismo
  // patrón que el paso 1, ver ese archivo. El botón "Guardar" del medio se
  // eliminó, "Siguiente" ya cumple esa función. Si TODOS los participantes
  // son invitados (sin costo), no hay a quién facturar — se salta el paso 3
  // directo al resumen. `esInvitado` viene del catálogo real
  // (CatalogsBloc.tiposParticipante) — nunca comparar ids hardcodeados
  // ('2'/'3') acá.
  //
  // OJO — en modo solo-ver (modoEdicion == false) no se valida ni se
  // guarda, es un recorrido de solo lectura — pero SÍ se sigue calculando
  // "soloInvitados" para decidir a qué paso saltar, incluso solo revisando.
  Future<void> _onContinuar(
    BuildContext context,
    ParticipantesState state,
  ) async {
    if (widget.modoEdicion) {
      if (_guardando) return;

      if (state.participantes.isEmpty) {
        AppSnackBar.error(
          context,
          'Agrega al menos un participante para continuar',
        );
        return;
      }

      // Nada cambió desde que se cargó esta solicitud — deja pasar directo
      // a la lógica de "saltar Facturación" de abajo, sin mostrar spinner
      // ni overlay de guardado (ver solicitudSinCambiosPendientes,
      // solicitud_guardar_helper.dart).
      if (!solicitudSinCambiosPendientes(context)) {
        setState(() => _guardando = true);

        final result = await guardarBorradorCompleto(
          context,
          idLead: widget.solicitud.idLead,
          pasoOrigen: '2',
          progreso: _progreso,
        );

        if (!mounted) return;
        _progreso.reset();
        setState(() => _guardando = false);

        if (result is! CrudOk) {
          mostrarResultadoGuardarSolicitud(context, result);
          return;
        }
      }

      // Aviso (no bloqueante) de que el precio base × cantidad − descuento
      // de la negociación de origen ya no calza con su precio total — movido
      // acá desde "Generar solicitud"/"Actualizar solicitud" (Resumen,
      // 2026-08-14): el usuario pidió que ese botón se limite a guardar/subir
      // archivos, sin validar nada — el momento correcto para avisar esto es
      // al avanzar de Participantes a Facturación, no al final del wizard.
      final avisoPrecio = avisoPrecioTotalNoCalza(
        context.read<SolicitudFormCubit>().state,
      );
      if (avisoPrecio != null) {
        AppSnackBar.warning(context, avisoPrecio);
      }
    }

    final catalogState = context.read<CatalogsBloc>().state;
    final tiposParticipante = catalogState is CatalogsLoaded
        ? catalogState.tiposParticipante
        : const <TipoParticipanteItem>[];

    final soloInvitados = state.participantes.every((p) {
      final tipo = tiposParticipante
          .where((t) => t.id == p.tipoParticipante)
          .firstOrNull;
      return tipo?.esInvitado ?? false;
    });
    widget.onContinuar(soloInvitados ? 4 : 3);
  }

  @override
  Widget build(BuildContext context) {
    final catalogState = context.watch<CatalogsBloc>().state;
    final igvPorcentaje = catalogState is CatalogsLoaded
        ? catalogState.igvPorcentaje
        : 0.0;
    final tiposParticipante = catalogState is CatalogsLoaded
        ? catalogState.tiposParticipante
        : const <TipoParticipanteItem>[];
    final monedas = catalogState is CatalogsLoaded
        ? catalogState.monedas
        : const <MonedaItem>[];
    // Cantidad exacta que exige la negociación de origen (null si esta
    // solicitud no viene de una) — se muestra junto al conteo actual para
    // que el asesor sepa cuánto le falta/sobra antes de generar. Solo
    // "Generar solicitud" exige que calcen exacto (ver
    // validarSolicitudParaGenerar en solicitud_guardar_helper.dart);
    // "Guardar" (borrador) deja pasar cualquier cantidad.
    final formState = context.watch<SolicitudFormCubit>().state;
    final cantidadEsperada = formState.cantidadEsperada;
    // Símbolo de la moneda ya fijada por la negociación de origen (ver
    // SolicitudFormState.idMonedaBloqueada) — null si esta solicitud no
    // viene de una negociación o si el catálogo aún no trae ese id.
    final idMonedaBloqueada = formState.idMonedaBloqueada;
    final monedaSimbolo = (idMonedaBloqueada != null && idMonedaBloqueada.isNotEmpty)
        ? monedas.where((m) => m.id == idMonedaBloqueada).firstOrNull?.simbolo
        : null;

    return BlocBuilder<ParticipantesCubit, ParticipantesState>(
      builder: (context, state) {
        final etiquetaParticipantes = state.participantes.length == 1
            ? 'participante'
            : 'participantes';
        return Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 12),

                // ── Encabezado sección participantes ───────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  AppIcons.users,
                                  color: AppColors.primary,
                                  size: AppSizing.iconMd,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  'Participantes',
                                  style: AppTextStyles.titleSmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: AppTextStyles.weightBold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Row(
                              children: [
                                const Icon(
                                  AppIcons.circuloRelleno,
                                  color: AppColors.success,
                                  size: 10,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  cantidadEsperada != null
                                      ? '${state.participantes.length} $etiquetaParticipantes · Máximo: $cantidadEsperada'
                                      : '${state.participantes.length} $etiquetaParticipantes',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Botones — ocultos por completo en modo solo-ver
                      // (modoEdicion == false, "Revisar solicitud"), no solo
                      // deshabilitados. Ver solicitudes/CLAUDE.md.
                      if (widget.modoEdicion)
                        Row(
                          children: [
                            BotonIconoSmall(
                              icono: AppIcons.add,
                              color: AppColors.primary,
                              enabled:
                                  !(cantidadEsperada != null &&
                                      state.participantes.length >=
                                          cantidadEsperada),
                              onTap: () => _abrirFormularioNuevo(context),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            BotonSeccionSmall(
                              icono: AppIcons.downloadFile,
                              label: 'Carga masiva',
                              enabled:
                                  !(cantidadEsperada != null &&
                                      state.participantes.length >=
                                          cantidadEsperada),
                              onTap: () => context.goToCargaMasivaParticipantes(
                                cubit: context.read<ParticipantesCubit>(),
                                cantidadEsperada: cantidadEsperada,
                                precioTotalLead: formState.precioTotalLead,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            BotonIconoSmall(
                              icono: AppIcons.delete,
                              color: AppColors.error,
                              onTap: state.participantes.isEmpty
                                  ? () {}
                                  : () => _confirmarEliminarTodos(context),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                // ── Lista de participantes ──────────────────────────────
                Expanded(
                  child: state.participantes.isEmpty
                      ? const AppEmptyView(
                          message: 'Sin participantes registrados',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          itemCount: state.participantes.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) {
                            final p = state.participantes[index];
                            final tipoCatalogo = tiposParticipante
                                .where((t) => t.id == p.tipoParticipante)
                                .firstOrNull;
                            final tipoLabel = tipoCatalogo?.nombre ?? '—';
                            return ParticipanteCard(
                              participante: p,
                              tipoParticipanteLabel: tipoLabel,
                              // Un Invitado no paga — la jefatura pidió que
                              // la cartilla muestre 0.00 para que no se
                              // confunda con lo que sí se factura (ver
                              // ParticipantesState.totalPagantes, que ya
                              // excluye a los Invitados del total). El
                              // importe real que haya puesto el asesor NO se
                              // toca — sigue guardado en
                              // ParticipanteLocal.importe tal cual, así que
                              // si luego se cambia el tipo de vuelta a
                              // Pagante, reaparece sin perderse.
                              esInvitado: tipoCatalogo?.esInvitado ?? false,
                              habilitado: widget.modoEdicion,
                              onEditar: () =>
                                  _abrirFormularioEditar(context, p),
                              onEliminar: () => context
                                  .read<ParticipantesCubit>()
                                  .eliminar(p.id),
                            );
                          },
                        ),
                ),

                // ── Resumen inversión ───────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  child: ResumenInversion(
                    total: state.totalPagantes(tiposParticipante),
                    igvPorcentaje: igvPorcentaje,
                    monedaSimbolo: monedaSimbolo,
                    precioTotalNegociacion: formState.precioTotalLead,
                    cantidadEsperada: cantidadEsperada,
                    cantidadActual: state.participantes.length,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),

                // ── Botones pie ─────────────────────────────────────────
                // "Siguiente" valida (al menos 1 participante) y guarda
                // (borrador) antes de avanzar — ya no hay botón "Guardar"
                // aparte. En modo solo-ver (modoEdicion == false) solo se
                // muestra "Siguiente", sin validar ni guardar — recorrido
                // de lectura.
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.sm,
                  ),
                  child: widget.modoEdicion
                      ? Row(
                          children: [
                            Expanded(
                              child: CustomSecondaryButton(
                                text: 'Atrás',
                                icon: AppIcons.back,
                                backgroundColor:
                                    AppColors.brandRaspberryAccessible,
                                onPressed: widget.onAtras,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: CustomPrimaryButton(
                                text: 'Siguiente →',
                                isLoading: _guardando,
                                onPressed: () => _onContinuar(context, state),
                              ),
                            ),
                          ],
                        )
                      : CustomPrimaryButton(
                          text: 'Continuar →',
                          onPressed: () => _onContinuar(context, state),
                        ),
                ),
              ],
            ),
            SolicitudProgresoOverlay(progreso: _progreso),
          ],
        );
      },
    );
  }
}
