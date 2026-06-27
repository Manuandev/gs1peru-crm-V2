// lib/features/lead/presentation/widgets/detalle/lead_detalle_info_card.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

// Widget base compartido: card con título en mayúsculas + filas de información.
// Evita duplicar el Container/decoration entre LeadContactoCard y LeadContextoCard.
class LeadInfoSectionCard extends StatelessWidget {
  final String titulo;
  final List<Widget> filas;

  const LeadInfoSectionCard({
    super.key,
    required this.titulo,
    required this.filas,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: Text(
              titulo,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const Divider(height: AppSizing.hairline),
          ...filas,
        ],
      ),
    );
  }
}

// Card CONTACTO: Teléfono (tappable para llamar) + Correo.
class LeadContactoCard extends StatelessWidget {
  final Lead lead;
  const LeadContactoCard({super.key, required this.lead});

  @override
  Widget build(BuildContext context) {
    final telefono = lead.numero.isEmpty
        ? 'Sin teléfono'
        : '${lead.prefijo} ${lead.numero}'.trim();

    return LeadInfoSectionCard(
      titulo: 'CONTACTO',
      filas: [
        _InfoFila(
          icono: Icon(
            AppIcons.phone,
            size: AppSizing.iconSm,
            color: AppColors.success,
          ),
          etiqueta: 'Teléfono',
          valor: telefono,
          onTap: lead.numero.isEmpty
              ? null
              : () => LauncherUtils.abrirTelefono(
                  '${lead.prefijo}${lead.numero}'.limpiarTelefono,
                ),
        ),
        const Divider(
          height: AppSizing.hairline,
          indent: AppSpacing.md,
          endIndent: AppSpacing.md,
        ),
        _InfoFila(
          icono: Icon(
            AppIcons.email,
            size: AppSizing.iconSm,
            color: AppColors.textSecondary,
          ),
          etiqueta: 'Correo',
          valor: lead.correo.isEmpty ? 'Sin correo' : lead.correo,
        ),
      ],
    );
  }
}

// Card CONTEXTO: Origen + Curso/Interés + Empresa.
// Para Curso/Interés prioriza lead.interes; si está vacío usa lead.evento.
class LeadContextoCard extends StatelessWidget {
  final Lead lead;
  const LeadContextoCard({super.key, required this.lead});

  @override
  Widget build(BuildContext context) {
    return LeadInfoSectionCard(
      titulo: 'INFORMACIÓN',
      filas: [
        _InfoFila(
          icono: AppSocialUtils.widgetCanalById(
            lead.idCanal,
            size: AppSizing.iconSm,
          ),
          etiqueta: 'Origen',
          valor: lead.canal.isEmpty ? 'Sin canal' : lead.canal,
        ),
        const Divider(
          height: AppSizing.hairline,
          indent: AppSpacing.md,
          endIndent: AppSpacing.md,
        ),
        _InfoFila(
          icono: Icon(
            AppIcons.interes,
            size: AppSizing.iconSm,
            color: AppColors.textSecondary,
          ),
          etiqueta: 'Curso / Interés',
          valor: lead.interes.isEmpty ? 'Sin interés' : lead.interes,
        ),
        const Divider(
          height: AppSizing.hairline,
          indent: AppSpacing.md,
          endIndent: AppSpacing.md,
        ),
        _InfoFila(
          icono: Icon(
            AppIcons.business,
            size: AppSizing.iconSm,
            color: AppColors.textSecondary,
          ),
          etiqueta: 'Empresa',
          valor: lead.nombreEmpresa.isEmpty
              ? 'Sin empresa'
              : lead.nombreEmpresa,
        ),
      ],
    );
  }
}

// Fila genérica: [ícono] [etiqueta] [valor] [chevron opcional].
// Cuando onTap != null, la fila es tappable y muestra chevron al final.
class _InfoFila extends StatelessWidget {
  final Widget icono;
  final String etiqueta;
  final String valor;
  final VoidCallback? onTap;

  const _InfoFila({
    required this.icono,
    required this.etiqueta,
    required this.valor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fila = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          SizedBox(width: AppSizing.iconSearch, child: icono),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: AppSizing.infoLabelWidth,
            child: Text(
              etiqueta,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: AppTextStyles.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: AppSpacing.xs),
            Icon(
              AppIcons.forward,
              size: AppSizing.iconSm,
              color: AppColors.textDisabled,
            ),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        child: fila,
      );
    }
    return fila;
  }
}

