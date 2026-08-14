// lib/features/solicitudes/presentation/widgets/completar/solicitud_resumen_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class SolicitudResumenView extends StatefulWidget {
  final Solicitud solicitud;
  final bool modoEdicion;
  // Salta a otro paso (1, 2 o 3) dentro del mismo SolicitudWizardView —
  // reemplaza el viejo Navigator.popUntil por nombre de ruta, ya que los
  // pasos dejaron de ser rutas separadas.
  final ValueChanged<int> onEditarPaso;
  // Retrocede al paso 3 (Facturación) dentro del mismo SolicitudWizardView.
  // Solo el paso 1 tiene un botón "Cancelar" que sale del wizard entero —
  // acá es "Atrás", un simple retroceso (ver solicitudes/CLAUDE.md).
  final VoidCallback onAtras;

  const SolicitudResumenView({
    super.key,
    required this.solicitud,
    required this.modoEdicion,
    required this.onEditarPaso,
    required this.onAtras,
  });

  @override
  State<SolicitudResumenView> createState() => _SolicitudResumenViewState();
}

class _SolicitudResumenViewState extends State<SolicitudResumenView> {
  // true si la solicitud YA EXISTÍA (tenía NUMSOL real) al abrirse el
  // wizard — se entró por "Validar"/"Editar ficha" desde la lista, no por
  // "Generar solicitud" desde una negociación. `widget.solicitud` es el
  // placeholder de navegación con el que se entró al wizard y NUNCA se
  // actualiza durante la sesión (ver comentario en _onGenerarSolicitud) —
  // por eso sigue reflejando el estado de ENTRADA aunque en el camino el
  // paso 1 ya haya guardado un borrador y `SolicitudFormCubit.state.numSol`
  // ya no esté vacío. Pedido de negocio 2026-08-13: si la solicitud ya
  // existía al entrar, el botón/mensajes finales dicen "Actualizar", no
  // "Generar" — sin importar que en el camino se haya guardado como
  // borrador (eso no cambia esta distinción).
  bool get _esSolicitudExistente => widget.solicitud.idSolicitud.isNotEmpty;

  // true mientras se guarda el borrador (botón "Guardar")
  bool _guardando = false;
  // true mientras se genera la solicitud final (botón "Generar solicitud")
  bool _generando = false;

  // Pasos del guardado (Guardando/Generando solicitud → Subiendo
  // voucher/O.C.) para el overlay de progreso — ver
  // solicitud_progreso_guardado.dart.
  final SolicitudProgreso _progreso = SolicitudProgreso();

  @override
  void dispose() {
    _progreso.dispose();
    super.dispose();
  }

  // Al guardar desde el Resumen (última pantalla del wizard) ya no hace
  // falta quedarse acá — se sale del wizard directo al detalle de la
  // solicitud recién guardada (nueva o editada), en vez de solo mostrar un
  // snackbar y dejar al asesor parado en el mismo paso.
  Future<void> _onGuardar() async {
    if (_guardando || _generando) return;

    // Nada cambió desde que se cargó esta solicitud — navega directo al
    // detalle sin mostrar spinner ni overlay de guardado (ver
    // solicitudSinCambiosPendientes, solicitud_guardar_helper.dart).
    if (!solicitudSinCambiosPendientes(context)) {
      setState(() => _guardando = true);

      final result = await guardarBorradorCompleto(
        context,
        idLead: widget.solicitud.idLead,
        pasoOrigen: '4',
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

    final numSol = context.read<SolicitudFormCubit>().state.numSol;

    // Si se entró por "Validar"/"Editar ficha" (ya existía un
    // SolicitudDetallePage vivo debajo del wizard, ver _esSolicitudExistente
    // arriba), no hace falta pedirle nada al backend para volver a pintar el
    // detalle — el wizard ya tiene en memoria exactamente lo que se acaba de
    // guardar. Se avisa por SolicitudUpdateNotifier (mismo patrón que
    // CobranzaUpdateNotifier, ver cobranza/CLAUDE.md) y se hace un pop
    // simple, sin volver a llamar getSolicitudDetalle()/getSolicitudes().
    if (_esSolicitudExistente && mounted) {
      final formState = context.read<SolicitudFormCubit>().state;
      final catalogState = context.read<CatalogsBloc>().state;
      final tiposParticipante = catalogState is CatalogsLoaded
          ? catalogState.tiposParticipante
          : const <TipoParticipanteItem>[];
      final idTipoDocRuc = catalogState is CatalogsLoaded
          ? catalogState.valoresDefecto.idTipoDocRuc
          : '';
      final igvPorcentaje = catalogState is CatalogsLoaded
          ? catalogState.igvPorcentaje
          : 0.0;
      final participantesState = context.read<ParticipantesCubit>().state;

      // Mismo cálculo que SeccionResumenComercial — precio pactado si la
      // solicitud está completa, si no Inversión + IGV redondeado.
      final inversion = participantesState.totalPagantes(tiposParticipante);
      final completo =
          formState.cantidadEsperada != null &&
          formState.cantidadEsperada! > 0 &&
          participantesState.participantes.length >=
              formState.cantidadEsperada! &&
          formState.precioTotalLead > 0;
      final montoTotal = completo
          ? formState.precioTotalLead
          : double.parse(
              (inversion + (inversion * igvPorcentaje / 100)).toStringAsFixed(
                2,
              ),
            );

      if (formState.solicitante != null) {
        SolicitudUpdateNotifier.instance.notify(
          SolicitudUpdate(
            numSol,
            solicitante: formState.solicitante!,
            facturacion: formState.facturacion,
            facturacionEsRuc:
                formState.facturacion?.tipoDocId == idTipoDocRuc,
            tipoPersona: formState.tipoPersona,
            montoTotal: montoTotal,
          ),
        );
      }

      Navigator.of(context).pop(); // sale del wizard, vuelve al Detalle vivo
      return;
    }

    Navigator.of(context).pop(); // sale del wizard

    // Bug real reportado por el usuario, 2026-07-30 — este método hacía
    // pop() + goToDetalleSolicitud() (push) sin más. Si el wizard se abrió
    // desde un Detalle ya existente ("Editar ficha"/"Validar"), el pop solo
    // sacaba el wizard y dejaba ese Detalle debajo — el push de acá metía
    // uno NUEVO encima, así que cada ciclo editar→guardar apilaba una
    // pantalla más. Con varios ciclos, el botón atrás terminaba mostrando
    // una cadena entera de Detalle en vez de volver a la lista. Se limpia
    // cualquier Detalle que haya quedado justo debajo del wizard (self-cura
    // también las pilas ya infladas de sesiones anteriores a este fix, no
    // solo evita que crezcan de acá en adelante) antes de empujar el
    // Detalle fresco — así la pila nunca crece más de un nivel de Detalle,
    // sin importar cuántas veces se repita el ciclo.
    //
    // Esta rama solo se alcanza cuando NO había un Detalle vivo debajo del
    // wizard (creación nueva desde "Generar solicitud", ver
    // _esSolicitudExistente arriba) — ahí sí hace falta el fetch, es la
    // primera vez que se ve el detalle de esta solicitud.
    if (!mounted) return;
    Navigator.of(
      context,
    ).popUntil((route) => route.settings.name != AppRoutes.detalleSolicitud);
    context.goToDetalleSolicitud(
      solicitud: widget.solicitud.copyWith(idSolicitud: numSol),
    );
  }

  // Guarda el CUD (IB_BORRADOR=0) y, solo si eso sale bien, sube voucher/OC
  // pendientes con el NUMSOL recién confirmado — recién ahí se considera
  // generada y navega a SolicitudGeneradaPage. Si el CUD falla o un archivo
  // no se pudo subir, se queda en Resumen mostrando el error (ver
  // generarSolicitudCompleta en solicitud_guardar_helper.dart).
  //
  // Toda la validación de campos obligatorios se hace acá, antes de llamar
  // al backend — "Continuar" de los pasos 1-3 ya no valida nada (ver
  // solicitudes/CLAUDE.md, 2026-07-16). Si algo falta, navega directo al
  // primer paso incompleto en vez de solo mostrar el error en Resumen.
  Future<void> _onGenerarSolicitud() async {
    if (_guardando || _generando) return;

    final validacion = validarSolicitudParaGenerar(context);
    if (validacion != null) {
      widget.onEditarPaso(validacion.paso);
      AppSnackBar.error(context, validacion.mensaje);
      return;
    }

    setState(() => _generando = true);

    final result = await generarSolicitudCompleta(
      context,
      idLead: widget.solicitud.idLead,
      esActualizacion: _esSolicitudExistente,
      progreso: _progreso,
    );

    if (!mounted) return;
    _progreso.reset();
    setState(() => _generando = false);

    if (result is CrudOk) {
      final comprobante =
          context.read<SolicitudFormCubit>().state.facturacion?.comprobante ??
          '';

      // widget.solicitud es el placeholder "de paso" con el que se entró al
      // wizard (idSolicitud/nombre/empresa/oportunidad/asesor vacíos al
      // crear desde una negociación — ver solicitudes/CLAUDE.md, "Solicitud
      // de navegación") — nunca se actualiza durante el wizard. Se trae la
      // lista real ('LS') y se busca por NUMSOL para mostrar los datos
      // frescos (nombre, empresa, oportunidad, estado, ejecutivo) en la
      // pantalla de confirmación, mismo patrón que SolicitudDetalleBloc.
      final numSol = context.read<SolicitudFormCubit>().state.numSol;
      Solicitud solicitudGenerada = widget.solicitud.copyWith(
        idSolicitud: numSol,
      );
      try {
        final lista = await GetSolicitudesUseCase(
          context.read<SolicitudRepository>(),
        ).call();
        final fresca = lista.where((s) => s.idSolicitud == numSol).firstOrNull;
        if (fresca != null) solicitudGenerada = fresca;
      } catch (_) {
        // Si falla, se muestra igual con el placeholder — no bloquea la
        // navegación, la solicitud ya se generó correctamente en el backend.
      }

      if (!mounted) return;
      context.goToSolicitudGenerada(
        solicitud: solicitudGenerada,
        comprobante: comprobante,
      );
    } else {
      mostrarResultadoGuardarSolicitud(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = context.watch<SolicitudFormCubit>().state;

    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SeccionSolicitante(
                      datos: formState.solicitante,
                      modoEdicion: widget.modoEdicion,
                      onEditar: () => widget.onEditarPaso(1),
                    ),
                    const _Separador(),
                    SeccionParticipantes(
                      onVerTodos: () => widget.onEditarPaso(2),
                    ),
                    // "Facturación" solo aplica si hubo a quién facturar —
                    // si todos los participantes son invitados, el paso 3 se
                    // saltó y formState.facturacion queda null.
                    if (formState.facturacion != null) ...[
                      const _Separador(),
                      SeccionFacturacion(
                        datos: formState.facturacion,
                        tipoPersonaLabel: formState.tipoPersonaLabel,
                        modoEdicion: widget.modoEdicion,
                        onEditar: () => widget.onEditarPaso(3),
                      ),
                    ],
                    const _Separador(),
                    const SeccionResumenComercial(),
                    const _Separador(),
                    SeccionDocumentosAdjuntos(
                      voucherNombre:
                          formState.solicitante?.archivoVoucherNombre ?? '',
                      ocNombre: formState.solicitante?.archivoOCNombre ?? '',
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            ),

            // ── Botones fijos al pie ───────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.modoEdicion
                    ? [
                        // Guardar borrador
                        SizedBox(
                          width: double.infinity,
                          child: CustomPrimaryButton(
                            text: 'Guardar',
                            icon: AppIcons.save,
                            isLoading: _guardando,
                            onPressed: _onGuardar,
                          ),
                        ),
                        const SizedBox(height: 5),

                        // Generar solicitud / Actualizar solicitud — ver
                        // _esSolicitudExistente.
                        SizedBox(
                          width: double.infinity,
                          child: CustomSecondaryButton(
                            text: _esSolicitudExistente
                                ? 'Actualizar solicitud'
                                : 'Generar solicitud',
                            icon: AppIcons.fileFactura,
                            isLoading: _generando,
                            onPressed: _onGenerarSolicitud,
                          ),
                        ),
                        const SizedBox(height: 5),
                        // Atrás
                        SizedBox(
                          width: double.infinity,
                          child: CustomSecondaryButton(
                            text: 'Atrás',
                            icon: AppIcons.back,
                            backgroundColor: AppColors.brandRaspberryAccessible,
                            onPressed: widget.onAtras,
                          ),
                        ),
                      ]
                    // Modo solo-ver — solo "Continuar", vuelve al detalle de la
                    // solicitud (mismo patrón que pasos 1-3, ver CLAUDE.md).
                    : [
                        SizedBox(
                          width: double.infinity,
                          child: CustomPrimaryButton(
                            text: 'Continuar',
                            onPressed: () => Navigator.of(context).popUntil(
                              ModalRoute.withName(AppRoutes.detalleSolicitud),
                            ),
                          ),
                        ),
                      ],
              ),
            ),
          ],
        ),
        SolicitudProgresoOverlay(progreso: _progreso),
      ],
    );
  }
}

// ── Separador entre secciones ─────────────────────────────────────────────────

class _Separador extends StatelessWidget {
  const _Separador();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Divider(height: 1, thickness: 1),
    );
  }
}
