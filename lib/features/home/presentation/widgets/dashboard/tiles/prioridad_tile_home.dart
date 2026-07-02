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
  bool _gestionando = false;

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

  Future<void> _gestionar() async {
    setState(() => _gestionando = true);
    final idNumero = widget.prioridad.idNumero;
    final result = await context.read<HomeRepository>().gestionarPrioridad(
      idNumero,
    );
    if (!mounted) return;
    switch (result) {
      case CrudOk(:final message):
        AppSnackBar.success(context, message);
        context.read<HomeBloc>().add(HomePrioridadGestionada(idNumero));
        return; // el tile desaparece de la lista — no hace falta setState
      case CrudAlert(:final message):
        AppSnackBar.warning(context, message);
      case CrudError(:final message):
        AppSnackBar.error(context, message);
      case CrudNoInternet():
        AppSnackBar.error(context, 'Sin conexión. Intenta de nuevo.');
      case CrudEmpty():
        AppSnackBar.error(context, 'Respuesta inesperada del servidor.');
    }
    setState(() => _gestionando = false);
  }

  @override
  Widget build(BuildContext context) {
    final prioridad = widget.prioridad;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ─── Avatar con ícono de persona ─────────────────────────
          CircleAvatar(
            radius: AppSizing.avatarRadiusXs,
            backgroundColor: prioridad.nombre.avatarColor,
            child: Icon(
              AppIcons.userFilled,
              color: AppColors.textOnDark,
              size: AppSizing.avatarXs,
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
                  style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: AppTextStyles.weightBold,
                    fontSize: AppTextStyles.sizeSm,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (prioridad.idCanal > 0) ...[
                      AppSocialUtils.widgetCanalById(prioridad.idCanal, size: 12),
                      const SizedBox(width: AppSpacing.xxs),
                    ],
                    if (prioridad.idEstado.isNotEmpty)
                      Flexible(
                        child: AppSocialUtils.chipEstado(
                          prioridad.idEstado,
                          label: prioridad.estado,
                          fontSize: AppTextStyles.sizeSub,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 1,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xxs),

          // ─── Tiempo sin respuesta ─────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ElapsedTimeUtils.formatHyM(_elapsed),
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.urgente,
                  fontWeight: AppTextStyles.weightExtraBold,
                  fontSize: AppTextStyles.sizeSm,
                ),
              ),
              Text(
                'sin respuesta',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: AppTextStyles.sizeSub,
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.sm),

          // ─── Botones de acción ────────────────────────────────────
          _MiniActionButton(
            iconWidget: FaIcon(
              AppIcons.whatsapp,
              color: AppColors.textOnDark,
              size: AppSizing.iconXxs,
            ),
            size: AppSizing.miniActionButtonSm,
            color: AppSocialUtils.colorCanalById(5),
            onTap: () => context.goToDetalleChatDesdeHome(
              idChatCab: prioridad.idChatCab,
            ),
            tooltip: 'WhatsApp',
          ),
          const SizedBox(width: AppSpacing.xxs),

          _MiniActionButton(
            iconWidget: Icon(
              AppIcons.phone,
              color: AppColors.textOnDark,
              size: AppSizing.iconXxs,
            ),
            size: AppSizing.miniActionButtonSm,
            color: AppColors.info,
            onTap: () async {
              await LauncherUtils.abrirTelefono(prioridad.telefono);
            },
            tooltip: 'Llamar',
          ),
          const SizedBox(width: AppSpacing.xxs),

          // ─── Botón Gestionar ─────────────────────────────────────
          _GestionarButton(
            onTap: _gestionando ? null : _gestionar,
            isLoading: _gestionando,
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
    final inicial = partes[2].isNotEmpty
        ? '${partes[2][0].toUpperCase()}.'
        : '';
    return '${partes[0]} ${partes[1]} $inicial'.trim();
  }
  // 4+ palabras: nombre1 nombre2 apellido1 apellido2
  final inicial = partes[3].isNotEmpty ? '${partes[3][0].toUpperCase()}.' : '';
  return '${partes[0]} ${partes[2]} $inicial'.trim();
}

// ─── Botón de acción compacto (WA / Llamar) ─────────────────────────────────
class _MiniActionButton extends StatelessWidget {
  final Widget iconWidget;
  final Color color;
  final VoidCallback onTap;
  final String tooltip;
  final double size;

  const _MiniActionButton({
    required this.iconWidget,
    required this.color,
    required this.onTap,
    required this.tooltip,
    this.size = AppSizing.miniActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizing.radiusSm),
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
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

// ─── Botón "Gestionar" outlined azul compacto ───────────────────────────────
class _GestionarButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isLoading;

  const _GestionarButton({required this.onTap, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizing.miniActionButtonSm,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: isLoading
            ? SizedBox(
                width: AppSizing.iconXxs,
                height: AppSizing.iconXxs,
                child: CircularProgressIndicator(
                  strokeWidth: AppSizing.spinnerStrokeSmall,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              )
            : Icon(AppIcons.checkSingle, size: AppSizing.iconXxs),
        label: Text(
          isLoading ? 'Gestionando…' : 'Gestionar',
          style: AppTextStyles.labelSmall.copyWith(
            fontSize: AppTextStyles.sizeSub,
            fontWeight: AppTextStyles.weightSemiBold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: 0,
          ),
          minimumSize: const Size(0, AppSizing.miniActionButtonSm),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizing.radiusSm),
          ),
        ),
      ),
    );
  }
}

