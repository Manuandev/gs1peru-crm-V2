// lib/features/lead/presentation/widgets/contacto_detalle/contacto_info_tab.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class ContactoInfoTab extends StatelessWidget {
  final ContactoDetalle contacto;

  const ContactoInfoTab({super.key, required this.contacto});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _InfoCard(
            filas: [
              _InfoFila(
                icono: AppIcons.business,
                etiqueta: 'Empresa',
                valor: contacto.empresa.isEmpty ? '—' : contacto.empresa,
              ),
              _InfoFila(
                
                icono: AppIcons.documento,
                etiqueta: 'Documento',
                valor: contacto.numDocumento.isEmpty
                    ? '—'
                    : '${contacto.tipoDocumento} · ${contacto.numDocumento}',
              ),
              _InfoFila(
                icono: AppIcons.phone,
                etiqueta: 'Teléfono',
                valor: contacto.numero.isEmpty
                    ? '—'
                    : contacto.telefonoCompleto,
              ),
              _InfoFila(
                icono: AppIcons.email,
                etiqueta: 'Correo',
                valor: contacto.correo.isEmpty ? '—' : contacto.correo,
              ),
              _InfoFila(
                icono: AppIcons.calendar,
                etiqueta: 'Fecha de registro',
                valor: contacto.fechaRegistro.isEmpty
                    ? '—'
                    : contacto.fechaRegistro.formatDate(
                        AppDateFormat.shortDate,
                      ),
              ),
              _InfoFila(
                icono: AppIcons.location,
                etiqueta: 'Dirección',
                valor: contacto.direccion.isEmpty ? '—' : contacto.direccion,
              ),
              _InfoFila(
                icono: AppIcons.map,
                etiqueta: 'Ubigeo',
                valor: _ubigeoLabel,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoCard(
            filas: [
              _InfoFila(
                icono: AppIcons.user,
                etiqueta: 'Cargo',
                valor: contacto.cargo.isEmpty ? '—' : contacto.cargo,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          CustomOutlinedButton(
            text: 'Editar contacto',
            icon: const Icon(AppIcons.edit),
            // TODO: navegar a pantalla de edición de contacto cuando esté disponible
            onPressed: () {},
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  String get _ubigeoLabel {
    final partes = [
      if (contacto.departamento.isNotEmpty) contacto.departamento,
      if (contacto.provincia.isNotEmpty) contacto.provincia,
      if (contacto.distrito.isNotEmpty) contacto.distrito,
    ];
    return partes.isEmpty ? '—' : partes.join(' / ');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card de sección
// ─────────────────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final List<Widget> filas;

  const _InfoCard({required this.filas});

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
          for (int i = 0; i < filas.length; i++) ...[
            filas[i],
            if (i < filas.length - 1)
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
// Fila de información: ícono en cuadrado gris + etiqueta arriba / valor abajo
// ─────────────────────────────────────────────────────────────────────────────

class _InfoFila extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String valor;

  const _InfoFila({
    required this.icono,
    required this.etiqueta,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Ícono en cuadrado gris redondeado
          Container(
            width: AppSizing.iconContainerMd,
            height: AppSizing.iconContainerMd,
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(AppSizing.radiusSm),
            ),
            child: Icon(
              icono,
              size: AppSizing.iconActionSm,
              color: AppColors.grey500,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Etiqueta pequeña arriba + valor abajo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  etiqueta.toUpperCase(),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: AppTextStyles.letterSpacingNarrow,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
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
      ),
    );
  }
}
