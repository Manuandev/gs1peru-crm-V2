// lib/features/lead/presentation/widgets/contacto_detalle/contacto_negociaciones_tab.dart
//
// Pestaña "Negociaciones" de Seguimiento (ContactoDetalleView) — distinta de
// NegociacionesTab (Conversaciones/ChatLeadPanel): acá el resumen es de 3
// tarjetas informativas (Negociaciones totales / Lista para propuesta /
// Ganada), sin chips de filtro. Sí comparte con esa pestaña el flujo de
// "Crear negociación" (mismo patrón: prepararNuevaNegociacion() sobre el
// InfoLeadCubit compartido + goToEditarLead(idLead: 0) + restaurar si el
// usuario cancela sin guardar).

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class ContactoNegociacionesTab extends StatelessWidget {
  final int idNumero;
  final List<Negociacion> negociaciones;

  const ContactoNegociacionesTab({
    super.key,
    required this.idNumero,
    required this.negociaciones,
  });

  // "Ganada" = negociación cerrada (idEstadoPadre '04') en el sub-estado '05'
  // — mismo código de negocio que NegociacionesTab (lead_detail_sheet), no
  // confundir con el catálogo genérico de etapas de AppSocialUtils.
  int get _ganadas => negociaciones
      .where((n) => n.idEstado == '05' && n.idEstadoPadre == '04')
      .length;

  // "Lista para propuesta" = idEstado efectivo '02' (Cotización) + sus hijos.
  int get _listasParaPropuesta =>
      negociaciones.where((n) => n.idEstadoEfectivo == '02').length;

  // Deja el InfoLeadCubit compartido listo para crear una negociación nueva
  // del mismo contacto/número, navega a Crear/Editar lead y, si el usuario
  // cancela sin guardar, restaura la negociación que estaba activa antes.
  // Mismo patrón que NegociacionesTab._crearNegociacion() (Conversaciones).
  Future<void> _crearNegociacion(BuildContext context) async {
    final cubit = context.read<InfoLeadCubit>();
    final estadoPrevio = cubit.state;
    final idLeadPrevio = estadoPrevio is InfoLeadSuccess
        ? estadoPrevio.negociacion.idLead
        : 0;

    cubit.prepararNuevaNegociacion();
    await context.goToEditarLead(idLead: 0, cubit: cubit);

    final estadoActual = cubit.state;
    final sigueEnBlanco =
        estadoActual is InfoLeadSuccess && estadoActual.negociacion.idLead == 0;
    if (sigueEnBlanco && idLeadPrevio != 0) {
      cubit.load(idLeadPrevio);
    }
    if (context.mounted) {
      context.read<NegociacionesCubit>().cargarNegociaciones(idNumero);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (negociaciones.isEmpty) {
      return _EstadoVacio(onCrear: () => _crearNegociacion(context));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xxl,
      ),
      children: [
        _ResumenNegociaciones(
          total: negociaciones.length,
          listasParaPropuesta: _listasParaPropuesta,
          ganadas: _ganadas,
        ),
        const SizedBox(height: AppSpacing.md),
        ...negociaciones.map(
          (n) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: ContactoNegociacionCard(negociacion: n),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        CustomOutlinedButton(
          text: '+ Crear negociación',
          onPressed: () => _crearNegociacion(context),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Resumen de 3 tarjetas — solo informativo, no filtra la lista de abajo
// ─────────────────────────────────────────────────────────────────────────────

class _ResumenNegociaciones extends StatelessWidget {
  final int total;
  final int listasParaPropuesta;
  final int ganadas;

  const _ResumenNegociaciones({
    required this.total,
    required this.listasParaPropuesta,
    required this.ganadas,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.md,
      ),
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
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _ResumenSeccion(
                icon: AppIcons.negociacion,
                color: AppColors.purple,
                valor: total,
                etiqueta: 'Negociaciones totales',
              ),
            ),
            const VerticalDivider(
              width: AppSpacing.sm,
              thickness: AppSizing.hairline,
              color: AppColors.divider,
            ),
            Expanded(
              child: _ResumenSeccion(
                icon: AppIcons.fileOutlined,
                color: AppColors.warning,
                valor: listasParaPropuesta,
                etiqueta: 'Lista para propuesta',
              ),
            ),
            const VerticalDivider(
              width: AppSpacing.sm,
              thickness: AppSizing.hairline,
              color: AppColors.divider,
            ),
            Expanded(
              child: _ResumenSeccion(
                icon: AppIcons.etapaGanado,
                color: AppColors.success,
                valor: ganadas,
                etiqueta: 'Ganada',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResumenSeccion extends StatelessWidget {
  // IconData (Material) o FaIconData (FontAwesome) — se resuelve en build().
  final Object icon;
  final Color color;
  final int valor;
  final String etiqueta;

  const _ResumenSeccion({
    required this.icon,
    required this.color,
    required this.valor,
    required this.etiqueta,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ícono + número van siempre en esta primera fila — así quedan
          // alineados en la misma línea en las 3 secciones sin importar
          // cuántas líneas ocupe la etiqueta de abajo.
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: AppSizing.avatarXs,
                height: AppSizing.avatarXs,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: icon is FaIconData
                    ? FaIcon(
                        icon as FaIconData,
                        size: AppSizing.iconXs,
                        color: color,
                      )
                    : Icon(
                        icon as IconData,
                        size: AppSizing.iconXs,
                        color: color,
                      ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '$valor',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: AppTextStyles.weightBold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            etiqueta,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Estado vacío
// ─────────────────────────────────────────────────────────────────────────────

class _EstadoVacio extends StatelessWidget {
  final VoidCallback onCrear;

  const _EstadoVacio({required this.onCrear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
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
            const SizedBox(height: AppSpacing.md),
            Text(
              'Sin negociaciones',
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: AppTextStyles.weightSemiBold,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Este contacto aún no tiene negociaciones registradas.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            CustomOutlinedButton(
              text: '+ Crear negociación',
              onPressed: onCrear,
            ),
          ],
        ),
      ),
    );
  }
}
