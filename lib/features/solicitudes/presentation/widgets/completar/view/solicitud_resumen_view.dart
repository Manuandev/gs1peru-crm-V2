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
    setState(() => _guardando = true);

    final result = await guardarBorradorCompleto(
      context,
      idLead: widget.solicitud.idLead,
      progreso: _progreso,
    );

    if (!mounted) return;
    _progreso.reset();
    setState(() => _guardando = false);

    if (result is! CrudOk) {
      mostrarResultadoGuardarSolicitud(context, result);
      return;
    }

    final numSol = context.read<SolicitudFormCubit>().state.numSol;
    Navigator.of(context).pop(); // sale del wizard
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
      progreso: _progreso,
    );

    if (!mounted) return;
    _progreso.reset();
    setState(() => _generando = false);

    if (result is CrudOk) {
      final comprobante =
          context.read<SolicitudFormCubit>().state.facturacion?.comprobante ??
          '';
      context.goToSolicitudGenerada(
        solicitud: widget.solicitud,
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
                    _SeccionSolicitante(
                      datos: formState.solicitante,
                      onEditar: () => widget.onEditarPaso(1),
                    ),
                    const _Separador(),
                    _SeccionParticipantes(
                      onVerTodos: () => widget.onEditarPaso(2),
                    ),
                    // "Facturación" solo aplica si hubo a quién facturar —
                    // si todos los participantes son invitados, el paso 3 se
                    // saltó y formState.facturacion queda null.
                    if (formState.facturacion != null) ...[
                      const _Separador(),
                      _SeccionFacturacion(
                        datos: formState.facturacion,
                        tipoPersonaLabel: formState.tipoPersonaLabel,
                        onEditar: () => widget.onEditarPaso(3),
                      ),
                    ],
                    const _Separador(),
                    const _SeccionResumenComercial(),
                    const _Separador(),
                    _SeccionDocumentosAdjuntos(
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

                        // Generar solicitud
                        SizedBox(
                          width: double.infinity,
                          child: CustomSecondaryButton(
                            text: 'Generar solicitud',
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

// ── Cabecera de seccion ───────────────────────────────────────────────────────

class _CabeceraSeccion extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final Widget? accion;

  const _CabeceraSeccion({
    required this.icono,
    required this.titulo,
    this.accion,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono, color: AppColors.primary, size: AppSizing.iconMd),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            titulo,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: AppTextStyles.weightBold,
            ),
          ),
        ),
        if (accion != null) accion!,
      ],
    );
  }
}

// ── Campo de dato ─────────────────────────────────────────────────────────────

class _CampoDato extends StatelessWidget {
  final IconData icono;
  final String label;
  final String valor;

  const _CampoDato({
    required this.icono,
    required this.label,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(
            icono,
            size: AppSizing.iconActionSm,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                valor,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: AppTextStyles.weightSemiBold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Boton Editar ──────────────────────────────────────────────────────────────

class _BotonEditar extends StatelessWidget {
  final VoidCallback onTap;

  const _BotonEditar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(AppIcons.edit, size: 13),
      label: const Text('Editar'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        minimumSize: Size.zero,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizing.radiusSm),
        ),
        textStyle: AppTextStyles.labelSmall.copyWith(
          fontWeight: AppTextStyles.weightMedium,
        ),
      ),
    );
  }
}

// ── Fila de dos campos ────────────────────────────────────────────────────────

class _FilaCampos extends StatelessWidget {
  final Widget izquierdo;
  final Widget derecho;

  const _FilaCampos({required this.izquierdo, required this.derecho});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: izquierdo),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: derecho),
      ],
    );
  }
}

// ── Seccion 1 — Solicitante ───────────────────────────────────────────────────

class _SeccionSolicitante extends StatelessWidget {
  final DatosSolicitante? datos;
  final VoidCallback onEditar;

  const _SeccionSolicitante({required this.onEditar, this.datos});

  @override
  Widget build(BuildContext context) {
    final d = datos;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CabeceraSeccion(
          icono: AppIcons.user,
          titulo: '1. Solicitante',
          accion: _BotonEditar(onTap: onEditar),
        ),
        const SizedBox(height: AppSpacing.sm),
        _FilaCampos(
          izquierdo: _CampoDato(
            icono: AppIcons.user,
            label: 'Nombre completo',
            valor: d?.nombreCompleto ?? '—',
          ),
          derecho: _CampoDato(
            icono: AppIcons.email,
            label: 'Correo',
            valor: d?.correo ?? '—',
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _FilaCampos(
          izquierdo: _CampoDato(
            icono: AppIcons.documento,
            label: 'Documento',
            valor: d?.documento ?? '—',
          ),
          derecho: _CampoDato(
            icono: AppIcons.info,
            label: '¿Cómo se enteró del evento?',
            valor: d?.canalTexto ?? '—',
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _FilaCampos(
          izquierdo: _CampoDato(
            icono: AppIcons.business,
            label: 'Cargo',
            valor: d?.cargo ?? '—',
          ),
          derecho: _CampoDato(
            icono: AppIcons.phone,
            label: 'Celular',
            valor: d != null && d.celular.isNotEmpty
                ? '+${d.celularCodigoTelefono} ${d.celular}'
                : '—',
          ),
        ),
      ],
    );
  }
}

// ── Seccion 2 — Participantes ─────────────────────────────────────────────────

class _SeccionParticipantes extends StatelessWidget {
  final VoidCallback onVerTodos;

  const _SeccionParticipantes({required this.onVerTodos});

  @override
  Widget build(BuildContext context) {
    final participantes = context
        .watch<ParticipantesCubit>()
        .state
        .participantes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CabeceraSeccion(
          icono: AppIcons.users,
          titulo: '2. Participantes',
          accion: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizing.radiusCircular),
            ),
            child: Text(
              '${participantes.length} participante/s',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: AppTextStyles.weightSemiBold,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        if (participantes.isEmpty)
          Text(
            'Sin participantes registrados',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          )
        else ...[
          // Cabecera tabla
          _FilaTabla(
            numero: 'N°',
            nombre: 'Nombre completo',
            documento: 'Documento',
            cargo: 'Cargo',
            celular: 'Celular',
            esEncabezado: true,
          ),
          const Divider(height: AppSpacing.xs, thickness: 0.5),

          for (int i = 0; i < participantes.length; i++) ...[
            _FilaTabla(
              numero: '${i + 1}',
              nombre: participantes[i].nombreCompleto,
              documento: participantes[i].numDoc,
              cargo: participantes[i].cargo,
              celular: participantes[i].celular,
              esEncabezado: false,
            ),
            if (i < participantes.length - 1)
              const Divider(height: AppSpacing.xs, thickness: 0.3),
          ],
        ],

        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: onVerTodos,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ver los ${participantes.length} participantes',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: AppTextStyles.weightSemiBold,
                ),
              ),
              const SizedBox(width: AppSpacing.xxs),
              const Icon(
                AppIcons.chevronRight,
                color: AppColors.primary,
                size: AppSizing.iconActionSm,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilaTabla extends StatelessWidget {
  final String numero;
  final String nombre;
  final String documento;
  final String cargo;
  final String celular;
  final bool esEncabezado;

  const _FilaTabla({
    required this.numero,
    required this.nombre,
    required this.documento,
    required this.cargo,
    required this.celular,
    required this.esEncabezado,
  });

  @override
  Widget build(BuildContext context) {
    final estilo = esEncabezado
        ? AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: AppTextStyles.weightMedium,
          )
        : AppTextStyles.labelSmall.copyWith(color: AppColors.textPrimary);

    return Row(
      children: [
        SizedBox(width: 20, child: Text(numero, style: estilo)),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          flex: 5,
          child: Text(nombre, style: estilo, overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          flex: 3,
          child: Text(
            documento,
            style: estilo,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          flex: 3,
          child: Text(cargo, style: estilo, overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          flex: 3,
          child: Text(celular, style: estilo, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

// ── Seccion 3 — Facturacion ───────────────────────────────────────────────────

class _SeccionFacturacion extends StatelessWidget {
  final DatosFacturacion? datos;
  final String tipoPersonaLabel;
  final VoidCallback onEditar;

  const _SeccionFacturacion({
    required this.onEditar,
    required this.tipoPersonaLabel,
    this.datos,
  });

  @override
  Widget build(BuildContext context) {
    final d = datos;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CabeceraSeccion(
          icono: AppIcons.receipt,
          titulo: '3. Facturación',
          accion: _BotonEditar(onTap: onEditar),
        ),
        const SizedBox(height: AppSpacing.sm),
        _FilaCampos(
          izquierdo: _CampoDato(
            icono: AppIcons.documento,
            label: 'Tipo de solicitante',
            valor: tipoPersonaLabel,
          ),
          derecho: _CampoDato(
            icono: AppIcons.business,
            label: 'Razón social / Nombres',
            valor: d?.nombresRazon ?? '—',
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _FilaCampos(
          izquierdo: _CampoDato(
            icono: AppIcons.fileFactura,
            label: 'Comprobante',
            valor: d?.comprobante ?? '—',
          ),
          derecho: _CampoDato(
            icono: AppIcons.documento,
            label: 'Número de documento',
            valor: d?.numDoc ?? '—',
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _FilaCampos(
          izquierdo: _CampoDato(
            icono: AppIcons.language,
            label: 'País',
            valor: d?.pais ?? '—',
          ),
          derecho: _CampoDato(
            icono: AppIcons.email,
            label: 'Correo de envío de boleta',
            valor: d?.correo ?? '—',
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _FilaCampos(
          izquierdo: _CampoDato(
            icono: AppIcons.moneda,
            label: 'Moneda',
            valor: d?.moneda ?? '—',
          ),
          derecho: _CampoDato(
            icono: AppIcons.location,
            label: 'Dirección',
            valor: d?.direccion ?? '—',
          ),
        ),
      ],
    );
  }
}

// ── Seccion 4 — Resumen comercial ────────────────────────────────────────────

class _SeccionResumenComercial extends StatelessWidget {
  const _SeccionResumenComercial();

  @override
  Widget build(BuildContext context) {
    // Desde el 2026-07-16 cada importe de participante ya es la BASE sin
    // IGV (ver _importeFijo en solicitud_participantes_view.dart), así que
    // la suma de importes ES la inversión directamente — el IGV se SUMA
    // encima para el importe total (revierte el fix del 2026-07-14, donde
    // el importe venía con IGV incluido y había que extraerlo).
    final inversion = context.watch<ParticipantesCubit>().state.totalInversion;
    final catalogState = context.watch<CatalogsBloc>().state;
    final igvPorcentaje = catalogState is CatalogsLoaded
        ? catalogState.igvPorcentaje
        : 0.0;
    final igv = inversion * igvPorcentaje / 100;
    final importeTotal = inversion + igv;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _CabeceraSeccion(
          icono: AppIcons.moneda,
          titulo: 'Resumen comercial',
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            // Inversion
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Inversion',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    inversion.toStringAsFixed(2),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: AppTextStyles.weightSemiBold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 36,
              color: AppColors.border,
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            ),
            // IGV
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'IGV',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    igv.toStringAsFixed(2),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: AppTextStyles.weightSemiBold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 36,
              color: AppColors.border,
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            ),
            // Importe total
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(AppSizing.radiusSm),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Importe total',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      importeTotal.toStringAsFixed(2),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: AppTextStyles.weightBold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Seccion 5 — Documentos adjuntos ──────────────────────────────────────────

class _SeccionDocumentosAdjuntos extends StatelessWidget {
  final String voucherNombre;
  final String ocNombre;

  const _SeccionDocumentosAdjuntos({
    required this.voucherNombre,
    required this.ocNombre,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _CabeceraSeccion(
          icono: AppIcons.attach,
          titulo: 'Documentos adjuntos',
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _TarjetaArchivo(
                icono: AppIcons.pdf,
                colorIcono: AppColors.brandForest,
                label: 'Voucher adjunto',
                nombreArchivo: voucherNombre,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _TarjetaArchivo(
                icono: AppIcons.pdf,
                colorIcono: AppColors.brandRaspberryAccessible,
                label: 'O/C adjunta',
                nombreArchivo: ocNombre,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TarjetaArchivo extends StatelessWidget {
  final IconData icono;
  final Color colorIcono;
  final String label;
  final String nombreArchivo;

  const _TarjetaArchivo({
    required this.icono,
    required this.colorIcono,
    required this.label,
    required this.nombreArchivo,
  });

  @override
  Widget build(BuildContext context) {
    final tieneArchivo = nombreArchivo.isNotEmpty;
    final color = tieneArchivo ? colorIcono : AppColors.textDisabled;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppSizing.iconLg,
            height: AppSizing.iconLg,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppSizing.radiusSm),
            ),
            child: Icon(icono, color: color, size: AppSizing.iconMd),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  tieneArchivo ? nombreArchivo : 'Sin adjuntar',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: tieneArchivo
                        ? AppColors.textPrimary
                        : AppColors.textDisabled,
                    fontWeight: tieneArchivo
                        ? AppTextStyles.weightMedium
                        : AppTextStyles.weightRegular,
                  ),
                  maxLines: 2,
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
