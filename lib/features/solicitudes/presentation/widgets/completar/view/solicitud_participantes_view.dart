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
  // sumar en el total del footer, ver _ResumenInversion). Ej.: precio total
  // 280, cantidad 2 → 140 c/u con IGV → 118.64 sin IGV. `precioBaseLead`
  // sigue existiendo, pero solo para avisoPrecioTotalNoCalza (ver
  // solicitud_guardar_helper.dart) — ya no para esto. El importe sigue
  // siendo editable siempre (ver
  // participante_form_sheet.dart), esto es solo una sugerencia inicial.
  //
  // Siempre es la misma división simple para TODOS los participantes,
  // incluido el último — ya no se le sugiere "lo que falta" para calzar
  // exacto con el total de la negociación (así era hasta el 2026-07-21).
  // Pedido de negocio, 2026-07-22: el importe nunca más se fuerza a calzar
  // contra ningún total — si el asesor edita el importe de otro
  // participante (ej. un descuento manual), eso NO debe empujarse hacia el
  // sugerido de uno nuevo. El centavo de redondeo que esto puede dejar
  // suelto ya no se absorbe acá — se absorbe en el IGV del último Pagante,
  // recién al completar el máximo de participantes (ver
  // ParticipantesState.igvPorParticipante).
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
                            _BotonIconoSmall(
                              icono: AppIcons.add,
                              color: AppColors.primary,
                              enabled:
                                  !(cantidadEsperada != null &&
                                      state.participantes.length >=
                                          cantidadEsperada),
                              onTap: () => _abrirFormularioNuevo(context),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            _BotonSeccionSmall(
                              icono: AppIcons.downloadFile,
                              label: 'Carga masiva',
                              enabled:
                                  !(cantidadEsperada != null &&
                                      state.participantes.length >=
                                          cantidadEsperada),
                              onTap: () => context.goToCargaMasivaParticipantes(
                                cubit: context.read<ParticipantesCubit>(),
                                cantidadEsperada: cantidadEsperada,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            _BotonIconoSmall(
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
                            return _ParticipanteCard(
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
                  child: _ResumenInversion(
                    total: state.totalPagantes(tiposParticipante),
                    igvPorcentaje: igvPorcentaje,
                    monedaSimbolo: monedaSimbolo,
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

// ── Card de participante ──────────────────────────────────────────────────────

class _ParticipanteCard extends StatelessWidget {
  final ParticipanteLocal participante;
  // Descripción real del catálogo (Pagante/Invitado/Invitado auspicio/
  // Online) — resuelta por el padre contra CatalogsBloc.tiposParticipante,
  // esta card no tiene acceso directo al catálogo. Se muestra para que el
  // asesor pueda verificar de un vistazo si los cálculos de la inversión
  // (que excluyen a los Invitados, ver ParticipantesState.totalPagantes)
  // están tomando el tipo correcto de cada participante.
  final String tipoParticipanteLabel;
  // Si es true, la cartilla muestra "0.00" en vez del importe real guardado
  // — un Invitado no paga, ver comentario en el itemBuilder que arma esta
  // card. El importe real (participante.importe) no se modifica, solo
  // cambia lo que se pinta acá.
  final bool esInvitado;
  final bool habilitado;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const _ParticipanteCard({
    required this.participante,
    required this.tipoParticipanteLabel,
    required this.esInvitado,
    required this.habilitado,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizing.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Acciones — ocultas por completo en modo solo-ver ────
          if (habilitado) ...[
            _AccionesCard(onEditar: onEditar, onEliminar: onEliminar),
            const SizedBox(width: AppSpacing.sm),
          ],

          // ── Info ──────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        participante.nombreCompleto,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: AppTextStyles.weightBold,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      esInvitado ? '0.00' : participante.importeFormateado,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: AppTextStyles.weightBold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                _FilaInfo(
                  label1: 'N° doc:',
                  valor1: participante.numDoc,
                  icono2: AppIcons.phone,
                  valor2: participante.celular,
                ),
                const SizedBox(height: AppSpacing.xxs),
                _FilaInfo(
                  label1: 'Nac.:',
                  valor1: participante.nacionalidad,
                  icono2: AppIcons.email,
                  valor2: participante.correo,
                ),
                const SizedBox(height: AppSpacing.xxs),
                _FilaInfo(
                  label1: 'Cargo:',
                  valor1: participante.cargo,
                  icono2: AppIcons.user,
                  valor2: tipoParticipanteLabel,
                ),
                // RichText(
                //   text: TextSpan(
                //     style: const TextStyle(fontSize: 10),
                //     children: [
                //       TextSpan(
                //         text: 'Cargo: ',
                //         style: TextStyle(
                //           color: AppColors.textSecondary,
                //           fontWeight: AppTextStyles.weightMedium,
                //         ),
                //       ),
                //       TextSpan(
                //         text: participante.cargo,
                //         style: TextStyle(
                //           color: AppColors.textPrimary,
                //           fontWeight: AppTextStyles.weightRegular,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Acciones del card ─────────────────────────────────────────────────────────

class _AccionesCard extends StatelessWidget {
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const _AccionesCard({required this.onEditar, required this.onEliminar});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 30,
          height: 30,
          child: IconButton(
            onPressed: onEditar,
            padding: EdgeInsets.zero,
            icon: const Icon(AppIcons.edit, size: 16, color: AppColors.primary),
          ),
        ),
        SizedBox(
          width: 30,
          height: 30,
          child: PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'eliminar') onEliminar();
            },
            padding: EdgeInsets.zero,
            icon: const Icon(
              AppIcons.moreHorizontal,
              size: 16,
              color: AppColors.textSecondary,
            ),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'eliminar',
                child: Row(
                  children: [
                    const Icon(
                      AppIcons.delete,
                      size: AppSizing.iconSm,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Eliminar',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Botón icono solo ──────────────────────────────────────────────────────────

class _BotonIconoSmall extends StatelessWidget {
  final IconData icono;
  final Color color;
  final VoidCallback onTap;
  final bool enabled;

  const _BotonIconoSmall({
    required this.icono,
    required this.color,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorEfectivo = enabled ? color : AppColors.textDisabled;
    return OutlinedButton(
      onPressed: enabled ? onTap : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: colorEfectivo,
        side: BorderSide(color: colorEfectivo),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizing.radiusSm),
        ),
      ),
      child: Icon(icono, size: 14),
    );
  }
}

// ── Fila de dos campos ────────────────────────────────────────────────────────

class _FilaInfo extends StatelessWidget {
  final String? label1;
  final IconData? icono2;
  final String valor1;
  final String valor2;

  const _FilaInfo({
    this.label1,
    required this.valor1,
    this.icono2,
    required this.valor2,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: _Campo(label: label1, valor: valor1),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: _Campo(icono: icono2, valor: valor2),
        ),
      ],
    );
  }
}

class _Campo extends StatelessWidget {
  final String? label;
  final IconData? icono;
  final String valor;

  const _Campo({this.label, this.icono, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icono != null) ...[
          Icon(icono, size: 11, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.xxs),
        ] else if (label != null)
          Text(
            '$label ',
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        Expanded(
          child: Text(
            valor,
            style: const TextStyle(fontSize: 10, color: AppColors.textPrimary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ── Resumen de inversión ──────────────────────────────────────────────────────

class _ResumenInversion extends StatelessWidget {
  // Suma de los importes de participantes PAGANTES únicamente (ver
  // ParticipantesState.totalPagantes — los Invitados no se cuentan, aunque
  // tengan su propio importe puesto, 2026-07-17). Desde el 2026-07-16 cada
  // importe ya es la BASE sin IGV (ver _importeFijo), así que `total` acá
  // ES la inversión directamente. El IGV se SUMA encima para el importe
  // total — revierte el fix del 2026-07-14 (donde el importe venía con IGV
  // incluido y había que extraerlo); con la nueva definición del importe,
  // sumar es lo correcto.
  final double total;
  final double igvPorcentaje;
  // Símbolo de la moneda fijada por la negociación de origen (ver
  // SolicitudFormState.idMonedaBloqueada) — null si esta solicitud no viene
  // de una negociación o el catálogo aún no la resuelve; en ese caso se
  // muestra el ícono genérico de siempre en vez del símbolo.
  final String? monedaSimbolo;

  const _ResumenInversion({
    required this.total,
    required this.igvPorcentaje,
    this.monedaSimbolo,
  });

  @override
  Widget build(BuildContext context) {
    final inversion = total;
    final igv = inversion * igvPorcentaje / 100;
    final importeTotal = inversion + igv;
    final igvLabel = igvPorcentaje % 1 == 0
        ? igvPorcentaje.toInt().toString()
        : igvPorcentaje.toStringAsFixed(1);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.ui1,
        borderRadius: BorderRadius.circular(AppSizing.radiusSm),
        border: Border.all(color: AppColors.ui3),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.ui2,
                shape: BoxShape.circle,
              ),
              child: (monedaSimbolo != null && monedaSimbolo!.isNotEmpty)
                  ? Center(
                      child: Text(
                        monedaSimbolo!,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: AppTextStyles.weightBold,
                        ),
                      ),
                    )
                  : const Icon(
                      AppIcons.pieChart,
                      color: AppColors.primary,
                      size: AppSizing.iconMd,
                    ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                _FilaMonto(
                  label: 'Inversión',
                  monto: inversion,
                  negrita: false,
                ),
                const Divider(height: 1, thickness: 0.5),
                _FilaMonto(
                  label: 'IGV ($igvLabel%)',
                  monto: igv,
                  negrita: false,
                ),
                const Divider(height: 1, thickness: 0.5),
                _FilaMonto(
                  label: 'Importe total',
                  monto: importeTotal,
                  negrita: true,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
    );
  }
}

class _FilaMonto extends StatelessWidget {
  final String label;
  final double monto;
  final bool negrita;

  const _FilaMonto({
    required this.label,
    required this.monto,
    required this.negrita,
  });

  @override
  Widget build(BuildContext context) {
    final estilo = AppTextStyles.bodySmall.copyWith(
      color: AppColors.textPrimary,
      fontWeight: negrita
          ? AppTextStyles.weightBold
          : AppTextStyles.weightRegular,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xs,
        horizontal: AppSpacing.xs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: estilo),
          Text(monto.toStringAsFixed(2), style: estilo),
        ],
      ),
    );
  }
}

// ── Botón pequeño de sección ──────────────────────────────────────────────────

class _BotonSeccionSmall extends StatelessWidget {
  final IconData icono;
  final String label;
  final VoidCallback onTap;
  final bool enabled;

  const _BotonSeccionSmall({
    required this.icono,
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = enabled ? AppColors.primary : AppColors.textDisabled;
    return OutlinedButton.icon(
      onPressed: enabled ? onTap : null,
      icon: Icon(icono, size: 14),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizing.radiusSm),
        ),
        textStyle: AppTextStyles.labelSmall.copyWith(
          fontWeight: AppTextStyles.weightSemiBold,
        ),
      ),
    );
  }
}
