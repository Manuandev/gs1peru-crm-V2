// lib/features/lead/presentation/widgets/lead_detail_sheet/tabs/datos_tab.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/chat/index_chat.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class DatosTab extends StatelessWidget {
  final Chat chat;
  final Negociacion negociacion;
  final int idNumero;
  final InfoLeadCubit? cubit;
  final VoidCallback? onCerrar;

  const DatosTab({
    super.key,
    required this.chat,
    required this.negociacion,
    required this.idNumero,
    this.cubit,
    this.onCerrar,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Cuando hay padre, el color de estado corresponde al padre (ej: '04' Cerrado),
    // no al subestado crudo ('05' Cobranza).
    final hayPadre = negociacion.idEstadoPadre.isNotEmpty;
    final colorEstado = AppSocialUtils.colorEstado(
      negociacion.idEstadoEfectivo,
    );
    // Separar las descripciones de estado y subestado para mostrarlas por separado.
    final labelEstado = negociacion.estadoEfectivo;
    final labelSubEstado = hayPadre ? negociacion.descripcionEstado : '';
    final apellido = [
      chat.apellidoPaterno ?? '',
      chat.apellidoMaterno ?? '',
    ].where((p) => p.isNotEmpty).join(' ');

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _InfoCard(
            pares: [
              _ParFila(
                izquierda: _CampoDato(
                  icono: Icon(
                    AppIcons.user,
                    size: AppSizing.iconActionSm,
                    color: colorScheme.primary,
                  ),
                  etiqueta: 'Nombres',
                  valor: chat.nombres.isEmpty ? '—' : chat.nombres,
                ),
                derecha: _CampoDato(
                  icono: Icon(
                    AppIcons.user,
                    size: AppSizing.iconActionSm,
                    color: colorScheme.primary,
                  ),
                  etiqueta: 'Apellidos',
                  valor: apellido.isEmpty ? '—' : apellido,
                ),
              ),
              _ParFila(
                izquierda: _CampoDato(
                  icono: Icon(
                    AppIcons.business,
                    size: AppSizing.iconActionSm,
                    color: colorScheme.primary,
                  ),
                  etiqueta: 'Empresa',
                  valor: chat.nombreEmpresa.isEmpty ? '—' : chat.nombreEmpresa,
                ),
                derecha: _CampoDato(
                  icono: Icon(
                    AppIcons.cargo,
                    size: AppSizing.iconActionSm,
                    color: colorScheme.primary,
                  ),
                  etiqueta: 'Cargo',
                  valor: (chat.cargo?.isEmpty ?? true) ? '—' : chat.cargo!,
                ),
              ),
              _ParFila(
                izquierda: _CampoDato(
                  icono: Icon(
                    AppIcons.email,
                    size: AppSizing.iconActionSm,
                    color: colorScheme.primary,
                  ),
                  etiqueta: 'Correo',
                  valor: (chat.correo?.isEmpty ?? true) ? '—' : chat.correo!,
                ),
                derecha: _CampoDato(
                  icono: Icon(
                    AppIcons.phone,
                    size: AppSizing.iconActionSm,
                    color: AppColors.success,
                  ),
                  etiqueta: 'Celular',
                  valor: chat.numero.isEmpty ? '—' : chat.numero,
                ),
              ),
              _ParFila(
                izquierda: _CampoDato(
                  icono: Icon(
                    AppIcons.campaign,
                    size: AppSizing.iconActionSm,
                    color: colorScheme.primary,
                  ),
                  etiqueta: 'Campaña',
                  valor: negociacion.nombreCampania.isEmpty
                      ? '—'
                      : negociacion.nombreCampania,
                ),
                derecha: _CampoDato(
                  icono: Icon(
                    AppIcons.cursoEvento,
                    size: AppSizing.iconActionSm,
                    color: colorScheme.primary,
                  ),
                  etiqueta: 'Curso / Evento',
                  valor: negociacion.nombreOportunidad.isEmpty
                      ? '—'
                      : negociacion.nombreOportunidad,
                ),
              ),
              _ParFila(
                izquierda: _CampoDato(
                  icono: AppSocialUtils.widgetCanalById(
                    negociacion.idCanal,
                    size: AppSizing.iconActionSm,
                  ),
                  etiqueta: 'Canal',
                  valor: negociacion.descripcionCanal.isEmpty
                      ? '—'
                      : negociacion.descripcionCanal,
                ),
                derecha: _CampoDato(
                  icono: Icon(
                    AppIcons.users,
                    size: AppSizing.iconActionSm,
                    color: colorScheme.primary,
                  ),
                  etiqueta: 'Interés',
                  valor: negociacion.descripcionInteres.isEmpty
                      ? '—'
                      : negociacion.descripcionInteres,
                ),
              ),
              _ParFila(
                izquierda: _CampoDato(
                  icono: Icon(
                    AppIcons.flag,
                    size: AppSizing.iconActionSm,
                    color: colorEstado,
                  ),
                  etiqueta: 'Estado',
                  valor: labelEstado.isEmpty ? '—' : labelEstado,
                  valorColor: colorEstado,
                ),
                derecha: _CampoDato(
                  icono: Icon(
                    AppIcons.listAlt,
                    size: AppSizing.iconActionSm,
                    color: colorScheme.primary,
                  ),
                  etiqueta: 'Subestado',
                  valor: labelSubEstado.isEmpty ? '—' : labelSubEstado,
                ),
              ),
              _ParFila(
                izquierda: _CampoDato(
                  icono: Icon(
                    AppIcons.calendar,
                    size: AppSizing.iconActionSm,
                    color: colorScheme.primary,
                  ),
                  etiqueta: 'Fecha de creación',
                  valor: negociacion.fechaHoraCreacion.isEmpty
                      ? '—'
                      : '${negociacion.fechaHoraCreacion.formatDate(AppDateFormat.shortDate)} · ${negociacion.fechaHoraCreacion.formatDate(AppDateFormat.hourMinute)}',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          CustomOutlinedButton(
            text: chat.idContacto == 0 ? 'Crear contacto' : 'Editar contacto',
            icon: chat.idContacto == 0 ? AppIcons.add : AppIcons.edit,
            onPressed: () => context.goToEditarContacto(idNumero: idNumero),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card contenedor con dividers entre pares
// ─────────────────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final List<_ParFila> pares;

  const _InfoCard({required this.pares});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < pares.length; i++) ...[
            pares[i],
            if (i < pares.length - 1)
              const Divider(
                height: AppSizing.hairline,
                indent: AppSpacing.md,
                endIndent: AppSpacing.md,
              ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Par de campos en fila (2 columnas)
// ─────────────────────────────────────────────────────────────────────────────

class _ParFila extends StatelessWidget {
  final _CampoDato izquierda;
  final _CampoDato? derecha;

  const _ParFila({required this.izquierda, this.derecha});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: izquierda),
          if (derecha != null) ...[
            const SizedBox(width: AppSpacing.md),
            Expanded(child: derecha!),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Campo individual: icono + etiqueta pequeña gris + valor
// ─────────────────────────────────────────────────────────────────────────────

class _CampoDato extends StatelessWidget {
  final Widget icono;
  final String etiqueta;
  final String valor;
  final Color? valorColor;

  const _CampoDato({
    required this.icono,
    required this.etiqueta,
    required this.valor,
    this.valorColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: AppSizing.iconActionSm + AppSpacing.xxs, child: icono),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                etiqueta,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                valor,
                style: AppTextStyles.bodySmall.copyWith(
                  color: valorColor ?? AppColors.textPrimary,
                  fontWeight: AppTextStyles.weightMedium,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
