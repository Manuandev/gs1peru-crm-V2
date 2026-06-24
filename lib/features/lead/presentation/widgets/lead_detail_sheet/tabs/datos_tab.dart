// lib/features/lead/presentation/widgets/lead_detail_sheet/tabs/datos_tab.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class DatosTab extends StatelessWidget {
  final Lead lead;
  final int idNumero;

  const DatosTab({super.key, required this.lead, required this.idNumero});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final colorEstado = AppIconsSocial.colorEstado(lead.idEstado);

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
                  valor: lead.nombre.isEmpty ? '—' : lead.nombre,
                ),
                derecha: _CampoDato(
                  icono: Icon(
                    AppIcons.user,
                    size: AppSizing.iconActionSm,
                    color: colorScheme.primary,
                  ),
                  etiqueta: 'Apellidos',
                  valor: lead.apellido.isEmpty ? '—' : lead.apellido,
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
                  valor: lead.nombreEmpresa.isEmpty ? '—' : lead.nombreEmpresa,
                ),
                derecha: _CampoDato(
                  icono: Icon(
                    AppIcons.documento,
                    size: AppSizing.iconActionSm,
                    color: colorScheme.primary,
                  ),
                  etiqueta: 'Cargo',
                  valor: 'Gerente de Operaciones',
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
                  valor: 'juan.perez@gs1mx.org',
                ),
                derecha: _CampoDato(
                  icono: Icon(
                    AppIcons.phone,
                    size: AppSizing.iconActionSm,
                    color: AppColors.success,
                  ),
                  etiqueta: 'Celular',
                  valor: lead.numero.isEmpty ? '—' : lead.numero,
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
                  valor: lead.campania.isEmpty ? '—' : lead.campania,
                ),
                derecha: _CampoDato(
                  icono: AppIconsSocial.widgetCanal(
                    lead.idCanal,
                    size: AppSizing.iconActionSm,
                  ),
                  etiqueta: 'Canal',
                  valor: lead.canal.isEmpty ? '—' : lead.canal,
                ),
              ),
              _ParFila(
                izquierda: _CampoDato(
                  icono: Icon(
                    AppIcons.interes,
                    size: AppSizing.iconActionSm,
                    color: colorScheme.primary,
                  ),
                  etiqueta: 'Curso / Evento',
                  valor: lead.evento.isEmpty ? '—' : lead.evento,
                ),
                derecha: _CampoDato(
                  icono: Icon(
                    AppIcons.users,
                    size: AppSizing.iconActionSm,
                    color: colorScheme.primary,
                  ),
                  etiqueta: 'Interés',
                  valor: lead.interes.isEmpty ? '—' : lead.interes,
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
                  valor: lead.estado.isEmpty ? '—' : lead.estado,
                  valorColor: colorEstado,
                ),
                derecha: _CampoDato(
                  icono: Icon(
                    AppIcons.listAlt,
                    size: AppSizing.iconActionSm,
                    color: colorScheme.primary,
                  ),
                  etiqueta: 'Subestado',
                  valor: (lead.subEstado ?? '').isEmpty ? '—' : lead.subEstado!,
                ),
              ),
              _ParFila(
                izquierda: _CampoDato(
                  icono: Icon(
                    AppIcons.reasignar,
                    size: AppSizing.iconActionSm,
                    color: colorScheme.primary,
                  ),
                  etiqueta: 'Origen',
                  valor: 'Click-to-WhatsApp Ads',
                ),
                derecha: _CampoDato(
                  icono: Icon(
                    AppIcons.calendar,
                    size: AppSizing.iconActionSm,
                    color: colorScheme.primary,
                  ),
                  etiqueta: 'Fecha de creación',
                  valor: '19/05/2026 · 10:12',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          CustomOutlinedButton(
            text: 'Editar lead',
            icon: const Icon(AppIcons.edit),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
              NavigationService.navigateTo(
                AppRoutes.detalleEditarLead,
                arguments: {
                  'idNumero': idNumero,
                  'lead': null,
                  'cubit': null,
                },
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
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
        SizedBox(
          width: AppSizing.iconActionSm + AppSpacing.xxs,
          child: icono,
        ),
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
