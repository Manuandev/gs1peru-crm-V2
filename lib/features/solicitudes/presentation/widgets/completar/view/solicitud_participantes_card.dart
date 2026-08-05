// lib/features/solicitudes/presentation/widgets/completar/view/solicitud_participantes_card.dart
//
// Cartilla visual de un participante (nombre, importe, documento,
// nacionalidad, cargo, tipo) usada por SolicitudParticipantesView, y sus
// piezas internas (acciones editar/eliminar, filas de info).

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class ParticipanteCard extends StatelessWidget {
  final ParticipanteLocal participante;
  // Descripción real del catálogo (Pagante/Invitado/Invitado auspicio/
  // Online) — resuelta por el padre contra CatalogsBloc.tiposParticipante,
  // esta card no tiene acceso directo al catálogo. Se muestra para que el
  // asesor pueda verificar de un vistazo si los cálculos de la inversión
  // (que excluyen a los Invitados, ver ParticipantesState.totalPagantes)
  // están tomando el tipo correcto de cada participante.
  final String tipoParticipanteLabel;
  // Si es true, la cartilla muestra "0.00" en vez del importe real guardado
  // — un Invitado no paga, ver comentario en el itemBuilder que arma esta
  // card. El importe real (participante.importe) no se modifica, solo
  // cambia lo que se pinta acá.
  final bool esInvitado;
  final bool habilitado;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const ParticipanteCard({
    super.key,
    required this.participante,
    required this.tipoParticipanteLabel,
    required this.esInvitado,
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
          // ── Acciones — ocultas por completo en modo solo-ver ────
          if (habilitado) ...[
            _AccionesCard(onEditar: onEditar, onEliminar: onEliminar),
            const SizedBox(width: AppSpacing.sm),
          ],

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
                      esInvitado ? '0.00' : participante.importeFormateado,
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
                _FilaInfo(
                  label1: 'Cargo:',
                  valor1: participante.cargo,
                  icono2: AppIcons.user,
                  valor2: tipoParticipanteLabel,
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
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const _AccionesCard({required this.onEditar, required this.onEliminar});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 30,
          height: 30,
          child: IconButton(
            onPressed: onEditar,
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
