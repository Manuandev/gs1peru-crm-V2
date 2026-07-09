// lib/features/solicitudes/presentation/widgets/completar/solicitud_participantes_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';
import 'package:app_crm/features/solicitudes/presentation/widgets/completar/solicitud_pasos_indicador.dart';

class SolicitudParticipantesView extends StatelessWidget {
  final Solicitud solicitud;
  final bool modoEdicion;

  const SolicitudParticipantesView({
    super.key,
    required this.solicitud,
    required this.modoEdicion,
  });

  void _abrirFormularioNuevo(BuildContext context) {
    mostrarFormularioParticipante(
      context,
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ParticipantesCubit, ParticipantesState>(
      builder: (context, state) {
        return BasePage(
          onPop: () => context.goBack(),
          drawerSide: DrawerSide.none,
          bodyPadding: EdgeInsets.zero,
          title: 'Solicitud de inscripción',
          appBarLeadingButtons: [
            IconButton(
              onPressed: () => context.goBack(),
              icon: Icon(
                AppIcons.back,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
          appBarTrailingButtons: [const SolicitudBadgePaso(paso: 2)],
          body: Column(
            children: [
              const SolicitudPasosIndicador(pasoActual: 2),
              const SizedBox(height: 12),

              // ── Encabezado sección participantes ───────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
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
                                '${state.participantes.length} participante/s',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Botones
                    Row(
                      children: [
                        _BotonSeccionSmall(
                          icono: AppIcons.add,
                          label: 'Nuevo',
                          onTap: modoEdicion
                              ? () => _abrirFormularioNuevo(context)
                              : () {},
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        _BotonSeccionSmall(
                          icono: AppIcons.downloadFile,
                          label: 'Carga masiva',
                          onTap: () => context.goToCargaMasivaParticipantes(
                            cubit: context.read<ParticipantesCubit>(),
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
                          return _ParticipanteCard(
                            participante: p,
                            habilitado: modoEdicion,
                            onEditar: () => _abrirFormularioEditar(context, p),
                            onEliminar: () => context
                                .read<ParticipantesCubit>()
                                .eliminar(p.id),
                          );
                        },
                      ),
              ),

              // ── Resumen inversión ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: _ResumenInversion(
                  inversion: state.totalInversion,
                  igvPorcentaje: 18,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),

              // ── Botones pie ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomSecondaryButton(
                        text: 'Guardar',
                        icon: AppIcons.save,
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: CustomSecondaryButton(
                        text: 'Cancelar',
                        backgroundColor: AppColors.brandRaspberryAccessible,
                        onPressed: () => context.goBack(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: CustomPrimaryButton(
                        text: 'Continuar →',
                        onPressed: state.participantes.isEmpty
                            ? null
                            : () => context.goToFichaFacturacionSolicitud(
                                solicitud: solicitud,
                                modoEdicion: modoEdicion,
                                formCubit: context.read<SolicitudFormCubit>(),
                                participantesCubit: context
                                    .read<ParticipantesCubit>(),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Card de participante ──────────────────────────────────────────────────────

class _ParticipanteCard extends StatelessWidget {
  final ParticipanteLocal participante;
  final bool habilitado;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const _ParticipanteCard({
    required this.participante,
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
          // ── Acciones ──────────────────────────────────────────
          _AccionesCard(
            habilitado: habilitado,
            onEditar: onEditar,
            onEliminar: onEliminar,
          ),
          const SizedBox(width: AppSpacing.sm),

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
                      participante.importeFormateado,
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
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 10),
                    children: [
                      TextSpan(
                        text: 'Cargo: ',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: AppTextStyles.weightMedium,
                        ),
                      ),
                      TextSpan(
                        text: participante.cargo,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: AppTextStyles.weightRegular,
                        ),
                      ),
                    ],
                  ),
                ),
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
  final bool habilitado;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const _AccionesCard({
    required this.habilitado,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 30,
          height: 30,
          child: IconButton(
            onPressed: habilitado ? onEditar : null,
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
            enabled: habilitado,
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

  const _BotonIconoSmall({
    required this.icono,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
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
  final double inversion;
  final int igvPorcentaje;

  const _ResumenInversion({
    required this.inversion,
    required this.igvPorcentaje,
  });

  @override
  Widget build(BuildContext context) {
    final igv = inversion * igvPorcentaje / 100;
    final total = inversion + igv;

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
              child: const Icon(
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
                  label: 'IGV ($igvPorcentaje%)',
                  monto: igv,
                  negrita: false,
                ),
                const Divider(height: 1, thickness: 0.5),
                _FilaMonto(label: 'Importe total', monto: total, negrita: true),
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
          Text('\$${monto.toStringAsFixed(2)}', style: estilo),
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

  const _BotonSeccionSmall({
    required this.icono,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icono, size: 14),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
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
