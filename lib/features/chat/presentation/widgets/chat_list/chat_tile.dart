// lib/features/chat/presentation/widgets/chat_list/chat_tile.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class ChatTile extends StatelessWidget {
  final Chat chat;
  final VoidCallback? onTap;

  const ChatTile({super.key, required this.chat, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizing.radiusMd),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Fila principal ────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AvatarConCanal(chat: chat),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: _InfoChat(chat: chat)),
                const SizedBox(width: AppSpacing.xs),
                _InfoDerecha(chat: chat),
              ],
            ),

            const SizedBox(height: AppSpacing.xs),
            const Divider(height: 1, thickness: 0.5, color: AppColors.border),
            const SizedBox(height: AppSpacing.xxs),

            // ── Fila de acciones ──────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: AppSizing.botonVerChat,
                  child: CustomOutlinedButton(
                    text: 'Ver chat',
                    onPressed: onTap,
                    height: AppSizing.buttonHeightSmall,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                SizedBox(
                  child: InkWell(
                    onTap: () => LauncherUtils.abrirTelefono(chat.numero),
                    borderRadius: BorderRadius.circular(
                      AppSizing.radiusCircular,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      child: Icon(
                        AppIcons.phone,
                        size: AppSizing.iconMd,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Avatar con ícono del canal superpuesto (Stack — esquina inferior derecha)
// ─────────────────────────────────────────────────────────────────────────────

class _AvatarConCanal extends StatelessWidget {
  final Chat chat;
  const _AvatarConCanal({required this.chat});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: AppSizing.avatarRadiusSm,
          backgroundColor: AvatarUtils.color(chat.nombreCompleto),
          child: Text(
            AvatarUtils.initials(chat.nombreCompleto),
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textOnDark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (chat.idCanal > 0)
          Positioned(
            bottom: -2,
            right: -2,
            child: Container(
              width: AppSizing.avatarCanalBadge,
              height: AppSizing.avatarCanalBadge,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                border: Border.all(
                  color: AppColors.border,
                  width: AppSizing.canalBadgeBorder,
                ),
              ),
              alignment: Alignment.center,
              child: AppIconsSocial.widgetCanal(chat.idCanal, size: 14),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Info central: nombre + chip canal, oportunidad, empresa, mensaje
// ─────────────────────────────────────────────────────────────────────────────

class _InfoChat extends StatelessWidget {
  final Chat chat;
  const _InfoChat({required this.chat});

  @override
  Widget build(BuildContext context) {
    final preview = buildMessagePreview(chat);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nombre + chip canal
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                chat.nombreCompleto,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            if (chat.idCanal > 0) ...[
              const SizedBox(width: AppSpacing.xs),
              _ChipCanal(idCanal: chat.idCanal),
            ],
          ],
        ),

        // Oportunidad
        if (chat.nombreOportunidad.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            chat.nombreOportunidad,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],

        // Empresa
        if (chat.nombreEmpresa.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            chat.nombreEmpresa,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],

        const SizedBox(height: AppSpacing.xxs),

        // Preview del último mensaje (natural ellipsis)
        Row(
          children: [
            if (preview.icon != null) ...[
              Icon(
                preview.icon,
                size: AppSizing.iconCanalInfo,
                color: preview.color ?? AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xxs),
            ],
            Expanded(
              child: Text(
                preview.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelSmall.copyWith(
                  color: preview.color ?? AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Info derecha: tiempo sin respuesta + badge estado + hora del último mensaje
// ─────────────────────────────────────────────────────────────────────────────

class _InfoDerecha extends StatelessWidget {
  final Chat chat;
  const _InfoDerecha({required this.chat});

  @override
  Widget build(BuildContext context) {
    final ahora = DateTime.now();
    final fechaUltimoMensaje = DateTime.tryParse(chat.fechaHora) ?? ahora;
    final elapsed = ahora.difference(fechaUltimoMensaje);
    final colorTiempo = ElapsedTimeUtils.colorFromElapsed(elapsed);

    return SizedBox(
      width: AppSizing.anchoChatDerecha,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            ElapsedTimeUtils.formatHyM(elapsed),
            style: AppTextStyles.labelMedium.copyWith(
              color: colorTiempo,
              fontWeight: AppTextStyles.weightBold,
            ),
            textAlign: TextAlign.end,
          ),
          const SizedBox(height: AppSpacing.xxs),
          AppIconsSocial.chipEstado(
            chat.idEstadoEfectivo,
            label: chat.descEstadoEfectiva,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            chat.fechaHora.formatDate(AppDateFormat.hourMinute),
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.end,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chip del canal de origen (píldora con color del canal)
// ─────────────────────────────────────────────────────────────────────────────

class _ChipCanal extends StatelessWidget {
  final int idCanal;
  const _ChipCanal({required this.idCanal});

  @override
  Widget build(BuildContext context) {
    final nombre = CanalHelper.get(idCanal).nombre;
    final color = AppIconsSocial.colorCanal(idCanal);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizing.radiusXs),
      ),
      child: Text(
        nombre,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: AppTextStyles.weightSemiBold,
          height: 1,
        ),
      ),
    );
  }
}
