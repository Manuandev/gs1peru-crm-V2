// lib/features/lead/presentation/widgets/contacto_detalle/contacto_negociacion_card.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class ContactoNegociacionCard extends StatefulWidget {
  final Negociacion negociacion;

  const ContactoNegociacionCard({super.key, required this.negociacion});

  @override
  State<ContactoNegociacionCard> createState() =>
      _ContactoNegociacionCardState();
}

class _ContactoNegociacionCardState extends State<ContactoNegociacionCard> {
  // true mientras se trae el detalle fresco de la negociación (task 'DT')
  // antes de generar la solicitud — ver comentario de _generarSolicitud.
  bool _generandoSolicitud = false;

  Negociacion get negociacion => widget.negociacion;

  // Mismo código de negocio que ContactoNegociacionesTab/NegociacionesTab.
  bool get _esGanada =>
      negociacion.idEstado == '05' && negociacion.idEstadoPadre == '04';

  String _simbolo(BuildContext context) {
    final state = context.watch<CatalogsBloc>().state;
    if (state is! CatalogsLoaded) return 'S/';
    return state.monedas
            .where((m) => m.id == negociacion.idMoneda)
            .firstOrNull
            ?.simbolo ??
        'S/';
  }

  // OJO: no reusar el InfoLeadCubit de ContactoDetalleView acá. Llamar
  // cargarPorIdLead en ese mismo cubit emite InfoLeadLoading — y como
  // ContactoDetalleView escucha ese cubit, toda la pantalla (esta card
  // incluida) se reemplaza por el skeleton de carga a mitad de camino,
  // el BuildContext de la card se desmonta, y la navegación de abajo nunca
  // llega a dispararse. A diferencia de Conversaciones (un solo lead activo
  // por conversación), acá hay varios leads históricos — cada tap necesita
  // su propio InfoLeadCubit aislado, como en el resto de la app.
  void _irAEditar(BuildContext context) {
    context.goToEditarLead(idLead: negociacion.idLead);
  }

  // Crea una solicitud NUEVA (NUMSOL vacío) para esta negociación ganada —
  // el wizard arranca en blanco (Solicitud.idSolicitud == '') y solo manda
  // idLead, que CSV_SOLICITUD_CUD_APP usa para vincular la solicitud al
  // lead de origen en la rama de creación.
  //
  // `negociacion` acá viene de `NegociacionesCubit` (task 'LN', historial de
  // Seguimiento) — igual que en `negociaciones_tab.dart` (Conversaciones),
  // ese task NO trae nombres/apellidos/empresa/correo/celular/RUC. Antes de
  // navegar se trae un detalle fresco por `idLead` (task 'DT') y se usa ESE
  // objeto para todos los datos que siembran el wizard.
  Future<void> _generarSolicitud() async {
    if (_generandoSolicitud) return;
    setState(() => _generandoSolicitud = true);

    Negociacion detalle;
    try {
      detalle = await GetLeadDetalleUseCase(
        context.read<LeadRepository>(),
      ).call(negociacion.idLead);
    } catch (e) {
      if (!mounted) return;
      setState(() => _generandoSolicitud = false);
      AppSnackBar.error(context, 'No se pudo cargar la negociación: $e');
      return;
    }

    if (!mounted) return;
    setState(() => _generandoSolicitud = false);

    context.goToFichaCompletarSolicitud(
      solicitud: Solicitud(
        idSolicitud: '',
        nombre: '',
        apellidoPaterno: '',
        apellidoMaterno: '',
        nombreEmpresa: '',
        cargo: '',
        correo: '',
        telefono: '',
        tipoPersona: '',
        idCondicionPago: '',
        condicionPago: '',
        monto: 0,
        fechaCreacion: '',
        idOportunidad: 0,
        oportunidad: '',
        idCanal: 0,
        canal: '',
        idEstado: 0,
        estado: '',
        ibValidado: false,
        asesor: '',
        nombreAsesor: '',
        idLead: detalle.idLead.toString(),
      ),
      modoEdicion: true,
      cantidadNegociacion: detalle.cantidad,
      precioBaseNegociacion: detalle.precioBase,
      descuentoNegociacion: detalle.descuento,
      idMonedaNegociacion: detalle.idMoneda,
      precioTotalNegociacion: detalle.precio,
      nombresNegociacion: detalle.nombres,
      apellidoPaternoNegociacion: detalle.apellidoPaterno,
      apellidoMaternoNegociacion: detalle.apellidoMaterno,
      nombreEmpresaNegociacion: detalle.nombreEmpresa,
      correoNegociacion: detalle.correo,
      celularNegociacion: detalle.numero,
      celularCodigoTelefonoNegociacion: detalle.prefijoPais,
      rucNegociacion: detalle.ruc,
      cargoNegociacion: detalle.cargo,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorEstado = AppSocialUtils.colorEstado(
      negociacion.idEstadoEfectivo,
    );
    final simbolo = _simbolo(context);

    // Con solicitud ya generada, la negociación deja de ser editable — el
    // tap ya no navega a ningún lado (la info del lead ya se ve en la
    // pestaña Información de esta misma pantalla).
    final puedeEditar = negociacion.idLead != 0 && !negociacion.tieneSolicitud;

    return Stack(
      children: [
        GestureDetector(
          onTap: puedeEditar ? () => _irAEditar(context) : null,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizing.radiusMd),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: AppSizing.shadowBlurMd,
                  offset: const Offset(0, AppSizing.shadowOffsetCardY),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSizing.radiusMd),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: AppSizing.cardBorderEstadoAncho,
                      color: colorEstado,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Título + chip de estado + chevron ─────────────
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    negociacion.nombreOportunidad,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: AppTextStyles.weightBold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                AppSocialUtils.chipEstado(
                                  negociacion.idEstadoEfectivo,
                                  label: negociacion.estadoEfectivo,
                                  fontSize: AppTextStyles.sizeXs,
                                ),
                                const SizedBox(width: AppSpacing.xxs),
                                const Icon(
                                  AppIcons.forward,
                                  size: AppSizing.iconXs,
                                  color: AppColors.textDisabled,
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),

                            // ── Izquierda: fecha/canal — Derecha: montos ──────
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _IconLinea(
                                        icon: const Icon(
                                          AppIcons.calendar,
                                          size: AppSizing.iconSm,
                                          color: AppColors.textSecondary,
                                        ),
                                        texto: negociacion.fechaHoraInteraccion
                                            .formatDate(
                                              AppDateFormat.shortDate,
                                            ),
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      _IconLinea(
                                        icon: AppSocialUtils.widgetCanalById(
                                          negociacion.idCanal,
                                          size: AppSizing.iconSm,
                                        ),
                                        texto: negociacion.descripcionCanal,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _FilaValor(
                                        label: 'Cantidad',
                                        valor: NumberFormatUtils.fmtInt(
                                          negociacion.cantidad,
                                        ),
                                      ),
                                      _FilaValor(
                                        label: 'Precio base',
                                        valor: NumberFormatUtils.formatMoneda(
                                          simbolo,
                                          negociacion.precioBase,
                                        ),
                                      ),
                                      _FilaValor(
                                        label: 'Descuento',
                                        valor: negociacion.descuento > 0
                                            ? '- ${NumberFormatUtils.formatMoneda(simbolo, negociacion.descuento)}'
                                            : NumberFormatUtils.formatMoneda(
                                                simbolo,
                                                negociacion.descuento,
                                              ),
                                        valorColor: negociacion.descuento > 0
                                            ? AppColors.warning
                                            : null,
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: AppSpacing.xs,
                                        ),
                                        child: _DashedDivider(),
                                      ),
                                      _FilaValor(
                                        label: 'Costo final',
                                        valor: NumberFormatUtils.formatMoneda(
                                          simbolo,
                                          negociacion.precio,
                                        ),
                                        negrita: true,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            // Solo se ofrece generar solicitud cuando la
                            // negociación está ganada y todavía no tiene una
                            // — con solicitud ya generada este botón no se
                            // muestra (se gestiona desde Solicitudes).
                            if (!negociacion.tieneSolicitud &&
                                _esGanada) ...[
                              const SizedBox(height: AppSpacing.sm),
                              SizedBox(
                                width: double.infinity,
                                child: CustomPrimaryButton(
                                  text: 'Generar solicitud',
                                  icon: AppIcons.fileFactura,
                                  backgroundColor: AppColors.success,
                                  onPressed: _generarSolicitud,
                                  // Sin precio total definido no hay
                                  // cantidad/importe/moneda que bloquear en la
                                  // solicitud — no se puede generar todavía.
                                  isEnabled: negociacion.precio > 0,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_generandoSolicitud)
          const AppLoadingOverlay(message: 'Cargando negociación...'),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Ícono + texto en fila (fecha / canal)
// ─────────────────────────────────────────────────────────────────────────────

class _IconLinea extends StatelessWidget {
  final Widget icon;
  final String texto;

  const _IconLinea({required this.icon, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        icon,
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            texto.isEmpty ? '—' : texto,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Fila etiqueta / valor (cantidad, precio base, descuento, costo final)
// ─────────────────────────────────────────────────────────────────────────────

class _FilaValor extends StatelessWidget {
  final String label;
  final String valor;
  final Color? valorColor;
  final bool negrita;

  const _FilaValor({
    required this.label,
    required this.valor,
    this.valorColor,
    this.negrita = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            valor,
            style:
                (negrita ? AppTextStyles.bodySmall : AppTextStyles.labelSmall)
                    .copyWith(
                      fontWeight: negrita
                          ? AppTextStyles.weightBold
                          : AppTextStyles.weightMedium,
                      color: valorColor ?? AppColors.textPrimary,
                    ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Línea discontinua — separa el desglose del costo final. Armada con Row +
// Container (sin LayoutBuilder/CustomPaint) porque la card vive dentro de un
// IntrinsicHeight, que no sabe hacer dry layout de esos dos widgets.
// ─────────────────────────────────────────────────────────────────────────────

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  static const int _segmentos = 20;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_segmentos, (i) {
        return Expanded(
          child: Container(
            height: AppSizing.hairline,
            margin: EdgeInsets.only(
              right: i == _segmentos - 1 ? 0 : AppSpacing.xxs,
            ),
            color: AppColors.border,
          ),
        );
      }),
    );
  }
}
