// lib/features/lead/presentation/widgets/lead_detail_sheet/tabs/negociaciones_tab.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/lead/index_lead.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class NegociacionesTab extends StatefulWidget {
  final int leadId;
  // 2026-08-03 — migrado de idNumero a idContacto (T_LEAD.ID_CONTACTO).
  final int idContacto;
  final VoidCallback? onCerrar;

  const NegociacionesTab({
    super.key,
    required this.leadId,
    required this.idContacto,
    this.onCerrar,
  });

  @override
  State<NegociacionesTab> createState() => _NegociacionesTabState();
}

class _NegociacionesTabState extends State<NegociacionesTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Sin contacto no hay nada que buscar — el SP devolvería vacío igual.
    if (widget.idContacto > 0) {
      context.read<NegociacionesCubit>().cargarNegociaciones(
        widget.idContacto,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.idContacto == 0) return const _EstadoVacio();

    return BlocBuilder<NegociacionesCubit, NegociacionesState>(
      builder: (context, state) {
        return switch (state) {
          NegociacionesInitial() ||
          NegociacionesLoading() => const AppLoadingView(),
          NegociacionesError(:final mensaje) => AppErrorView(
            message: mensaje,
            onRetry: () => context
                .read<NegociacionesCubit>()
                .cargarNegociaciones(widget.idContacto),
          ),
          NegociacionesSuccess(:final negociaciones) => _ListaNegociaciones(
            negociaciones: negociaciones,
            leadId: widget.leadId,
            idContacto: widget.idContacto,
            onCerrar: widget.onCerrar,
          ),
        };
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Lista con header + cards + info banner
// ─────────────────────────────────────────────────────────────────────────────

enum _FiltroNeg { todas, activa, ganadas }

class _ListaNegociaciones extends StatefulWidget {
  final List<Negociacion> negociaciones;
  final int leadId;
  final int idContacto;
  final VoidCallback? onCerrar;

  const _ListaNegociaciones({
    required this.negociaciones,
    required this.leadId,
    required this.idContacto,
    this.onCerrar,
  });

  @override
  State<_ListaNegociaciones> createState() => _ListaNegociacionesState();
}

class _ListaNegociacionesState extends State<_ListaNegociaciones> {
  _FiltroNeg _filtro = _FiltroNeg.todas;

  // "Ganada" = negociación cerrada (idEstadoPadre '04') en el sub-estado
  // '05' — códigos de negocio, no confundir con el catálogo de etapas
  // genérico de AppSocialUtils.
  List<Negociacion> get _visibles => switch (_filtro) {
    _FiltroNeg.todas => widget.negociaciones,
    _FiltroNeg.activa => widget.negociaciones.where((n) => n.activo).toList(),
    _FiltroNeg.ganadas =>
      widget.negociaciones
          .where((n) => n.idEstado == '05' && n.idEstadoPadre == '04')
          .toList(),
  };

  String get _mensajeVacioFiltro => switch (_filtro) {
    _FiltroNeg.activa => 'No hay negociaciones activas.',
    _FiltroNeg.ganadas => 'No hay negociaciones ganadas.',
    _FiltroNeg.todas => '',
  };

  // Deja el InfoLeadCubit compartido listo para crear una negociación nueva
  // del mismo contacto/número, navega a Editar/Crear lead y, si el usuario
  // cancela sin guardar, restaura la negociación que estaba activa antes.
  Future<void> _crearNegociacion() async {
    final cubit = context.read<InfoLeadCubit>();
    final estadoPrevio = cubit.state;
    final idLeadPrevio = estadoPrevio is InfoLeadSuccess
        ? estadoPrevio.negociacion.idLead
        : 0;

    cubit.prepararNuevaNegociacion();
    await context.goToEditarLead(
      idLead: 0,
      cubit: cubit,
      desdeConversacion: true,
    );

    final estadoActual = cubit.state;
    final sigueEnBlanco =
        estadoActual is InfoLeadSuccess && estadoActual.negociacion.idLead == 0;
    if (sigueEnBlanco && idLeadPrevio != 0) {
      cubit.load(idLeadPrevio);
    }
    if (mounted) {
      context.read<NegociacionesCubit>().cargarNegociaciones(widget.idContacto);
    }
  }

  // Crea una solicitud NUEVA (NUMSOL vacío) para esta negociación — el
  // wizard arranca en blanco (Solicitud.idSolicitud == '') y solo manda
  // idLead. El wizard (SolicitudCompletarView._cargarDetalle()) es quien
  // trae la negociación fresca por idLead (GetLeadDetalleUseCase) y siembra
  // los datos de contacto/cantidad/precio — este método ya no necesita
  // hacerlo antes de navegar. Mismo patrón que
  // ContactoNegociacionCard._generarSolicitud() (Seguimiento).
  void _generarSolicitud(Negociacion negociacion) {
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
        idLead: negociacion.idLead.toString(),
      ),
      modoEdicion: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.negociaciones.isEmpty) {
      return _EstadoVacio(onCrear: _crearNegociacion);
    }

    final visibles = _visibles;

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.xxl,
          ),
          children: [
            // ── Chips de filtro ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  const Spacer(),
                  _FiltroChip(
                    label: 'Todas',
                    seleccionado: _filtro == _FiltroNeg.todas,
                    onTap: () => setState(() => _filtro = _FiltroNeg.todas),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _FiltroChip(
                    label: 'Activa',
                    seleccionado: _filtro == _FiltroNeg.activa,
                    onTap: () => setState(() => _filtro = _FiltroNeg.activa),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _FiltroChip(
                    label: 'Ganadas',
                    seleccionado: _filtro == _FiltroNeg.ganadas,
                    onTap: () => setState(() => _filtro = _FiltroNeg.ganadas),
                  ),
                ],
              ),
            ),

            // ── Cards (o vacío del filtro activo) ───────────────────────────────────
            if (visibles.isEmpty)
              _EstadoVacioFiltro(mensaje: _mensajeVacioFiltro)
            else
              ...visibles.map(
                (negociacion) => NegociacionCard(
                  negociacion: negociacion,
                  leadId: widget.leadId,
                  onGenerarSolicitud: () => _generarSolicitud(negociacion),
                  onEdited: () => context
                      .read<NegociacionesCubit>()
                      .cargarNegociaciones(widget.idContacto),
                ),
              ),

            const SizedBox(height: AppSpacing.sm),
            CustomOutlinedButton(
              text: '+ Crear negociación',
              onPressed: _crearNegociacion,
            ),

            const SizedBox(height: AppSpacing.sm),

            // ── Info banner ───────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSizing.radiusMd),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    AppIcons.infoCircle,
                    size: AppSizing.iconSm,
                    color: AppColors.info,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      'La negociación seleccionada es la que se utiliza para actualizar el CRM y, en su caso, cerrar como ganada para generar una solicitud.',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Estado vacío de un filtro (Activa/Ganadas) — hay negociaciones, pero
// ninguna cae en el filtro seleccionado.
// ─────────────────────────────────────────────────────────────────────────────

class _EstadoVacioFiltro extends StatelessWidget {
  final String mensaje;
  const _EstadoVacioFiltro({required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Center(
        child: Text(
          mensaje,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Estado vacío
// ─────────────────────────────────────────────────────────────────────────────

class _EstadoVacio extends StatelessWidget {
  // Si viene, se muestra el botón "+ Crear negociación" — desde Conversaciones
  // también se puede crear la primera negociación de un contacto sin ninguna.
  final VoidCallback? onCrear;

  const _EstadoVacio({this.onCrear});

  @override
  Widget build(BuildContext context) {
    // Scroll: el panel de Conversaciones (ChatLeadPanel) da poca altura a la
    // pestaña — con el botón "+ Crear negociación" agregado, el Column fijo
    // desbordaba unos px. Con SingleChildScrollView nunca desborda.
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppSizing.iconXxl,
            height: AppSizing.iconXxl,
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(AppSizing.radiusXl),
            ),
            child: const Icon(
              AppIcons.negociacion,
              size: AppSizing.iconXl,
              color: AppColors.grey400,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Sin negociaciones',
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: AppTextStyles.weightSemiBold,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'Este contacto aún no tiene negociaciones registradas.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (onCrear != null) ...[
            const SizedBox(height: AppSpacing.sm),
            CustomOutlinedButton(
              text: '+ Crear negociación',
              onPressed: onCrear,
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chip de filtro compacto
// ─────────────────────────────────────────────────────────────────────────────

class _FiltroChip extends StatelessWidget {
  final String label;
  final bool seleccionado;
  final VoidCallback onTap;

  const _FiltroChip({
    required this.label,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: seleccionado
              ? color.withValues(alpha: 0.08)
              : AppColors.transparent,
          borderRadius: BorderRadius.circular(AppSizing.radiusCircular),
          border: Border.all(
            color: seleccionado ? color : AppColors.border,
            width: AppSizing.hairline,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: seleccionado ? color : AppColors.textSecondary,
            fontWeight: seleccionado
                ? AppTextStyles.weightSemiBold
                : AppTextStyles.weightRegular,
          ),
        ),
      ),
    );
  }
}
