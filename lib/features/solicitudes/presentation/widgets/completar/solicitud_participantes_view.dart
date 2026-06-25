// lib/features/solicitudes/presentation/widgets/completar/solicitud_participantes_view.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';
import 'package:app_crm/features/solicitudes/presentation/widgets/completar/solicitud_pasos_indicador.dart';

class SolicitudParticipantesView extends StatefulWidget {
  final Solicitud solicitud;
  final bool modoEdicion;

  const SolicitudParticipantesView({
    super.key,
    required this.solicitud,
    required this.modoEdicion,
  });

  @override
  State<SolicitudParticipantesView> createState() =>
      _SolicitudParticipantesViewState();
}

class _SolicitudParticipantesViewState
    extends State<SolicitudParticipantesView> {
  // Mock mientras se integra el BLoC
  static const _participantesMock = [
    _ParticipanteMock(
      tipoDoc: 'PASAPORTE',
      numDoc: '057588685',
      nombre: 'JOSE EDUARDO POSADA PEÑA',
      celular: '503-76713284',
      nacionalidad: 'SALVADOREÑA/O/A',
      correo: 'eduardoposada20041998@gmail.com',
      cargo: 'ADC JR.',
      tipoPago: 'Pagante',
      precio: r'$137.53',
    ),
    _ParticipanteMock(
      tipoDoc: 'PASAPORTE',
      numDoc: '054476059',
      nombre: 'RODRIGO ALEJANDRO MAGAÑA BLANCO',
      celular: '503-79150391',
      nacionalidad: 'SALVADOREÑA/O/A',
      correo: 'rodrigomagana96@gmail.com',
      cargo: 'GERENTE REGIONAL CATEGORÍAS',
      tipoPago: 'Pagante',
      precio: r'$137.53',
    ),
    _ParticipanteMock(
      tipoDoc: 'PASAPORTE',
      numDoc: '053880352',
      nombre: 'JOSUE ELISEO AMAYA RIVERA',
      celular: '503-71077672',
      nacionalidad: 'SALVADOREÑA/O/A',
      correo: 'josueamaya1996@gmail.com',
      cargo: 'ADC JR.',
      tipoPago: 'Pagante',
      precio: r'$137.53',
    ),
    _ParticipanteMock(
      tipoDoc: 'DNI',
      numDoc: '74521896',
      nombre: 'MARIA FERNANDA LOPEZ QUISPE',
      celular: '51-987654321',
      nacionalidad: 'PERUANO/A',
      correo: 'mflopez@empresa.com',
      cargo: 'COORDINADORA COMERCIAL',
      tipoPago: 'Cortesía',
      precio: r'$0.00',
    ),
    _ParticipanteMock(
      tipoDoc: 'DNI',
      numDoc: '69834512',
      nombre: 'CARLOS ANTONIO HERRERA VEGA',
      celular: '51-912345678',
      nacionalidad: 'PERUANO/A',
      correo: 'cherrera@empresa.pe',
      cargo: 'JEFE DE LOGÍSTICA',
      tipoPago: 'Pagante',
      precio: r'$137.53',
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
      appBarTrailingButtons: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.md),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.white(0.15),
              borderRadius: BorderRadius.circular(AppSizing.radiusSm),
            ),
            child: Text(
              'Paso 2 de 4',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textOnDark,
                fontWeight: AppTextStyles.weightSemiBold,
              ),
            ),
          ),
        ),
      ],
      body: Column(
        children: [
          const SolicitudPasosIndicador(pasoActual: 2),
          const SizedBox(height: 12),
          // ── Encabezado sección participantes ─────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Título + contador
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
                            '${_participantesMock.length} participante/s',
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
                      onTap: () {},
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _BotonSeccionSmall(
                      icono: AppIcons.downloadFile,
                      label: 'Carga masiva',
                      onTap: () {},
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _BotonIconoSmall(
                      icono: AppIcons.delete,
                      color: AppColors.error,
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // ── Lista de participantes ────────────────────────────────
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              itemCount: _participantesMock.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) => _ParticipanteCard(
                participante: _participantesMock[index],
                habilitado: widget.modoEdicion,
              ),
            ),
          ),

          // ── Resumen inversión (fijo) ──────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: _ResumenInversion(
              inversion: _participantesMock.fold(
                0.0,
                (sum, p) =>
                    sum +
                    (double.tryParse(p.precio.replaceAll(r'$', '')) ?? 0.0),
              ),
              igvPorcentaje: 18,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // ── Botones pie ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(AppIcons.save, size: 15),
                    label: const Text('Guardar borrador'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.secondary,
                      side: const BorderSide(color: AppColors.secondary),
                      minimumSize: const Size.fromHeight(
                        AppSizing.buttonHeightSmall,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
                      ),
                      textStyle: AppTextStyles.labelSmall.copyWith(
                        fontWeight: AppTextStyles.weightSemiBold,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.goBack(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.brandRaspberryAccessible,
                      side: const BorderSide(
                        color: AppColors.brandRaspberryAccessible,
                      ),
                      minimumSize: const Size.fromHeight(
                        AppSizing.buttonHeightSmall,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
                      ),
                      textStyle: AppTextStyles.labelSmall.copyWith(
                        fontWeight: AppTextStyles.weightSemiBold,
                      ),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.goToFichaFacturacionSolicitud(
                      solicitud: widget.solicitud,
                      modoEdicion: widget.modoEdicion,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnDark,
                      minimumSize: const Size.fromHeight(
                        AppSizing.buttonHeightSmall,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
                      ),
                      textStyle: AppTextStyles.labelSmall.copyWith(
                        fontWeight: AppTextStyles.weightSemiBold,
                      ),
                    ),
                    child: const Text('Continuar →'),
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

// ── Modelo mock participante ──────────────────────────────────────────────────

class _ParticipanteMock {
  final String tipoDoc;
  final String numDoc;
  final String nombre;
  final String celular;
  final String nacionalidad;
  final String correo;
  final String cargo;
  final String tipoPago;
  final String precio;

  const _ParticipanteMock({
    required this.tipoDoc,
    required this.numDoc,
    required this.nombre,
    required this.celular,
    required this.nacionalidad,
    required this.correo,
    required this.cargo,
    required this.tipoPago,
    required this.precio,
  });
}

// ── Card de participante ──────────────────────────────────────────────────────

class _ParticipanteCard extends StatelessWidget {
  final _ParticipanteMock participante;
  final bool habilitado;

  const _ParticipanteCard({
    required this.participante,
    required this.habilitado,
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
          // ── Acciones del card ──────────────────────────────────
          _AccionesCard(habilitado: habilitado),
          const SizedBox(width: AppSpacing.sm),

          // ── Info ───────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre + precio
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        participante.nombre,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: AppTextStyles.weightBold,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      participante.precio,
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

// ── Acciones del card (editar + menú eliminar) ───────────────────────────────

class _AccionesCard extends StatelessWidget {
  final bool habilitado;

  const _AccionesCard({required this.habilitado});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Editar
        SizedBox(
          width: 30,
          height: 30,
          child: IconButton(
            onPressed: habilitado ? () {} : null,
            padding: EdgeInsets.zero,
            icon: const Icon(AppIcons.edit, size: 16, color: AppColors.primary),
          ),
        ),

        // Menú eliminar
        SizedBox(
          width: 30,
          height: 30,
          child: PopupMenuButton<String>(
            onSelected: (_) {},
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

// ── Botón icono solo (sin label) ──────────────────────────────────────────────

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

// ── Fila de dos campos de info ────────────────────────────────────────────────

class _FilaInfo extends StatelessWidget {
  final String? label1;
  final IconData? icono1;
  final String valor1;
  final String? label2;
  final IconData? icono2;
  final String valor2;

  const _FilaInfo({
    this.label1,
    required this.valor1,
    this.icono2,
    required this.valor2,
  }) : label2 = null,
       icono1 = null;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: _Campo(label: label1, icono: icono1, valor: valor1),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: _Campo(label: label2, icono: icono2, valor: valor2),
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
          // Ícono lateral
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

          // Filas de montos
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
