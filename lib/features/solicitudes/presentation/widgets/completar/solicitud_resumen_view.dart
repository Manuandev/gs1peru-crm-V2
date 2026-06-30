// lib/features/solicitudes/presentation/widgets/completar/solicitud_resumen_view.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';
import 'package:app_crm/features/solicitudes/presentation/widgets/completar/solicitud_pasos_indicador.dart';

class SolicitudResumenView extends StatelessWidget {
  final Solicitud solicitud;
  final bool modoEdicion;

  const SolicitudResumenView({
    super.key,
    required this.solicitud,
    required this.modoEdicion,
  });

  @override
  Widget build(BuildContext context) {
    return BasePage(
      onPop: () => context.goBack(),
      drawerSide: DrawerSide.none,
      bodyPadding: EdgeInsets.zero,
      title: 'Solicitud de inscripcion',
      appBarLeadingButtons: [
        IconButton(
          onPressed: () => context.goBack(),
          icon: Icon(
            AppIcons.back,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ],
      appBarTrailingButtons: [const SolicitudBadgePaso(paso: 4)],
      body: Column(
        children: [
          const SolicitudPasosIndicador(pasoActual: 4),
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
                    onEditar: () => Navigator.of(context).popUntil(
                      ModalRoute.withName(AppRoutes.fichaCompletarSolicitud),
                    ),
                  ),
                  const _Separador(),
                  const _SeccionParticipantes(),
                  const _Separador(),
                  _SeccionFacturacion(
                    onEditar: () => Navigator.of(context).popUntil(
                      ModalRoute.withName(AppRoutes.fichaFacturacionSolicitud),
                    ),
                  ),
                  const _Separador(),
                  const _SeccionResumenComercial(),
                  const _Separador(),
                  const _SeccionDocumentosAdjuntos(),
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
              AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Guardar borrador
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(AppIcons.save, size: 16),
                    label: const Text('Guardar borrador'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                      minimumSize: const Size.fromHeight(
                        AppSizing.buttonHeightSmall,
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
                      ),
                      textStyle: AppTextStyles.bodySmall.copyWith(
                        fontWeight: AppTextStyles.weightSemiBold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm2),

                // Generar solicitud
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(AppIcons.fileFactura, size: 16),
                    label: const Text('Generar solicitud'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.textOnDark,
                      minimumSize: const Size.fromHeight(
                        AppSizing.buttonHeightSmall,
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
                      ),
                      textStyle: AppTextStyles.bodySmall.copyWith(
                        fontWeight: AppTextStyles.weightSemiBold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm2),

                // Cancelar
                SizedBox(
                  width: double.infinity,
                  child: SolicitudBotonAtras(
                    label: 'Cancelar',
                    icono: AppIcons.cancel,
                    onPressed: () => context.goBack(),
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
  final VoidCallback onEditar;

  const _SeccionSolicitante({required this.onEditar});

  @override
  Widget build(BuildContext context) {
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
          izquierdo: const _CampoDato(
            icono: AppIcons.user,
            label: 'Nombre completo',
            valor: 'José Eduardo Posada Peña',
          ),
          derecho: const _CampoDato(
            icono: AppIcons.email,
            label: 'Correo',
            valor: 'eduardoposada20041998@gmail.com',
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _FilaCampos(
          izquierdo: const _CampoDato(
            icono: AppIcons.documento,
            label: 'Documento',
            valor: 'DNI 057588685',
          ),
          derecho: const _CampoDato(
            icono: AppIcons.info,
            label: '¿Cómo se enteró del evento?',
            valor: 'Logística',
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _FilaCampos(
          izquierdo: const _CampoDato(
            icono: AppIcons.business,
            label: 'Cargo',
            valor: 'ADC JR.',
          ),
          derecho: const _CampoDato(
            icono: AppIcons.calendar,
            label: 'Campaña',
            valor: 'Septiembre 2026',
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _FilaCampos(
          izquierdo: const _CampoDato(
            icono: AppIcons.phone,
            label: 'Celular',
            valor: '+51  767 132 84',
          ),
          derecho: const _CampoDato(
            icono: AppIcons.listAlt,
            label: 'Evento',
            valor: 'Expogestión 2026',
          ),
        ),
      ],
    );
  }
}

// ── Seccion 2 — Participantes ─────────────────────────────────────────────────

class _SeccionParticipantes extends StatelessWidget {
  const _SeccionParticipantes();

  static const _participantes = [
    ['José Eduardo Posada Peña', '057588685', 'ADC JR.', '503-76713284'],
    [
      'Rodrigo Alejandro Magaña Blanco',
      '054476059',
      'Gerente Regional',
      '503-79150391',
    ],
    ['Josue Eliseo Amaya Rivera', '053880352', 'ADC JR.', '503-71077672'],
    ['Alejandra Sofia Duenas Trujillo', '044577544', 'ADC JR.', '20-75278536'],
    ['Karla Maria Contreras de Castro', '033906536', 'ADC SR.', '503-77299772'],
  ];

  @override
  Widget build(BuildContext context) {
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
              '5 participantes',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: AppTextStyles.weightSemiBold,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

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

        for (int i = 0; i < _participantes.length; i++) ...[
          _FilaTabla(
            numero: '${i + 1}',
            nombre: _participantes[i][0],
            documento: _participantes[i][1],
            cargo: _participantes[i][2],
            celular: _participantes[i][3],
            esEncabezado: false,
          ),
          if (i < _participantes.length - 1)
            const Divider(height: AppSpacing.xs, thickness: 0.3),
        ],

        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: () {},
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ver los 5 participantes',
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
  final VoidCallback onEditar;

  const _SeccionFacturacion({required this.onEditar});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CabeceraSeccion(
          icono: AppIcons.receipt,
          titulo: '3. Facturacion',
          accion: _BotonEditar(onTap: onEditar),
        ),
        const SizedBox(height: AppSpacing.sm),
        _FilaCampos(
          izquierdo: const _CampoDato(
            icono: AppIcons.documento,
            label: 'Tipo de solicitante',
            valor: 'Juridica',
          ),
          derecho: const _CampoDato(
            icono: AppIcons.business,
            label: 'Razon social',
            valor: 'IML Manufacturing',
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _FilaCampos(
          izquierdo: const _CampoDato(
            icono: AppIcons.fileFactura,
            label: 'Comprobante',
            valor: 'Boleta',
          ),
          derecho: const _CampoDato(
            icono: AppIcons.documento,
            label: 'Numero de documento',
            valor: '02101201231017',
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _FilaCampos(
          izquierdo: const _CampoDato(
            icono: AppIcons.language,
            label: 'Pais',
            valor: 'El Salvador',
          ),
          derecho: const _CampoDato(
            icono: AppIcons.email,
            label: 'Correo de envio de boleta',
            valor: 'karlaoliva@grupoiml.com',
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _FilaCampos(
          izquierdo: const _CampoDato(
            icono: AppIcons.moneda,
            label: 'Moneda',
            valor: 'Dolares',
          ),
          derecho: const _CampoDato(
            icono: AppIcons.location,
            label: 'Direccion',
            valor:
                'Carr. A Metapan Km. 69.7, Lottif La Capellania, Plantel del Grupo IML, Santa Ana',
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
                    'USD 687.65',
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
                    'USD 123.78',
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
                      'USD 811.43',
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
  const _SeccionDocumentosAdjuntos();

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
                icono: AppIcons.fileExcel,
                colorIcono: AppColors.brandForest,
                label: 'Voucher adjunto',
                nombreArchivo:
                    'JOSE EDUARDO POSADA PENA – IML MANUFACTURING.pdf',
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _TarjetaArchivo(
                icono: AppIcons.pdf,
                colorIcono: AppColors.brandRaspberryAccessible,
                label: 'O/C adjunta',
                nombreArchivo: 'OC_IML_2026_91001064.pdf',
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
              color: colorIcono.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppSizing.radiusSm),
            ),
            child: Icon(icono, color: colorIcono, size: AppSizing.iconMd),
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
                  nombreArchivo,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: AppTextStyles.weightMedium,
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
