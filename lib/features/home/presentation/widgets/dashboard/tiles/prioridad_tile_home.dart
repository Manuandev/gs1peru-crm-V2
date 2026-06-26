// lib/features/home/presentation/widgets/dashboard/tiles/prioridad_tile_home.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';

class PrioridadTileHome extends StatefulWidget {
  final PrioridadHome prioridad;
  const PrioridadTileHome({super.key, required this.prioridad});

  @override
  State<PrioridadTileHome> createState() => _PrioridadTileHomeState();
}

class _PrioridadTileHomeState extends State<PrioridadTileHome> {
  late Duration _elapsed;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _elapsed = Duration.zero;
    _updateElapsed();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() => _updateElapsed());
    });
  }

  void _updateElapsed() {
    final fecha = DateFormatter.parseDate(widget.prioridad.fechaHora);
    if (fecha == null) return;
    _elapsed = DateTime.now().difference(fecha);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prioridad = widget.prioridad;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ─── Avatar ──────────────────────────────────────────────
          CircleAvatar(
            radius: AppSizing.avatarRadiusSm,
            backgroundColor: prioridad.nombre.avatarColor,
            child: Text(
              prioridad.nombre.initials,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textOnDark,
                fontWeight: AppTextStyles.weightBold,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),

          // ─── Nombre + Canal + Estado ──────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _abreviarNombre(prioridad.nombre),
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: AppTextStyles.weightBold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (prioridad.idCanal > 0) ...[
                      AppIconsSocial.widgetCanal(prioridad.idCanal, size: 10),
                      const SizedBox(width: AppSpacing.xxs),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 32),
                        child: Text(
                          _canalCorto(prioridad.idCanal, prioridad.canal),
                          style: AppTextStyles.labelSmall.copyWith(
                            fontSize: AppTextStyles.sizeSub,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                    ],
                    if (prioridad.idEstado.isNotEmpty)
                      Flexible(
                        child: AppIconsSocial.chipEstado(
                          prioridad.idEstado,
                          label: prioridad.estado,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),

          // ─── Tiempo sin respuesta ─────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ElapsedTimeUtils.formatHyM(_elapsed),
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.error,
                  fontWeight: AppTextStyles.weightExtraBold,
                  fontSize: AppTextStyles.sizeSmPlus,
                ),
              ),
              Text(
                'sin resp.',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: AppTextStyles.sizeSub,
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.xs),

          // ─── Botón WhatsApp ───────────────────────────────────────
          _MiniActionButton(
            iconWidget: FaIcon(
              AppIconsSocial.whatsapp,
              color: AppColors.textOnDark,
              size: AppSizing.iconActionSm,
            ),
            color: AppIconsSocial.colorCanal(1),
            onTap: () => context.goToDetalleChatDesdeHome(
              idNumero: prioridad.idNumero,
              idLead: prioridad.idLead,
            ),
            tooltip: 'WhatsApp',
          ),
          const SizedBox(width: AppSpacing.xxs),

          // ─── Botón Llamar ─────────────────────────────────────────
          _MiniActionButton(
            iconWidget: Icon(
              AppIcons.phone,
              color: AppColors.textOnDark,
              size: AppSizing.iconActionSm,
            ),
            color: AppColors.info,
            onTap: () async {
              await LauncherUtils.abrirTelefono(prioridad.telefono);
            },
            tooltip: 'Llamar',
          ),
          const SizedBox(width: AppSpacing.xs),

          // ─── Botón Gestionar ─────────────────────────────────────
          // Navega al chat del lead para gestionarlo directamente
          _GestionarButton(
            onTap: () => context.goToDetalleChatDesdeHome(
              idNumero: prioridad.idNumero,
              idLead: prioridad.idLead,
            ),
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }
}

// ── Abrevia nombres largos para caber en el tile ────────────────────────────
// 4 partes: [n1] [n2] [ap1] [ap2] → "n1 ap1 A."
// 3 partes: [n1] [ap1] [ap2]      → "n1 ap1 A."
// ≤2 partes: muestra tal cual
String _abreviarNombre(String nombre) {
  final partes = nombre.trim().split(RegExp(r'\s+'));
  if (partes.length <= 2) return nombre;
  if (partes.length == 3) {
    final inicial = partes[2].isNotEmpty ? '${partes[2][0].toUpperCase()}.' : '';
    return '${partes[0]} ${partes[1]} $inicial'.trim();
  }
  // 4+ palabras: nombre1 nombre2 apellido1 apellido2
  final inicial = partes[3].isNotEmpty ? '${partes[3][0].toUpperCase()}.' : '';
  return '${partes[0]} ${partes[2]} $inicial'.trim();
}

// ── Nombre corto del canal para el tile compacto ────────────────────────────
String _canalCorto(int idCanal, String canal) {
  const abreviaturas = <int, String>{
    1: 'WA',
    3: 'TikTok',
    4: 'IG',
    5: 'FB',
    6: 'LI',
    7: 'Web',
    8: 'IP',
    9: 'B.B.',
    10: 'Migr.',
    11: 'Ref.',
    12: 'Manual',
  };
  return abreviaturas[idCanal] ?? canal;
}

// ─── Botón de acción compacto (WA / Llamar) ─────────────────────────────────
class _MiniActionButton extends StatelessWidget {
  final Widget iconWidget;
  final Color color;
  final VoidCallback onTap;
  final String tooltip;

  const _MiniActionButton({
    required this.iconWidget,
    required this.color,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizing.radiusSm),
        onTap: onTap,
        child: Container(
          width: AppSizing.miniActionButton,
          height: AppSizing.miniActionButton,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppSizing.radiusSm),
          ),
          child: Center(child: iconWidget),
        ),
      ),
    );
  }
}

// ─── Botón "Gestionar" outlined ──────────────────────────────────────────────
class _GestionarButton extends StatelessWidget {
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _GestionarButton({required this.onTap, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizing.miniActionButton,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(AppIcons.checkSingle, size: AppSizing.iconSm),
        label: Text(
          'Gestionar',
          style: AppTextStyles.labelSmall.copyWith(
            fontSize: AppTextStyles.sizeSub,
            fontWeight: AppTextStyles.weightSemiBold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.xxs,
          ),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          side: BorderSide(color: colorScheme.primary),
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizing.radiusSm),
          ),
        ),
      ),
    );
  }
}
