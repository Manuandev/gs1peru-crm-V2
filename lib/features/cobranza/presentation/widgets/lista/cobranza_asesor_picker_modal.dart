// lib/features/cobranza/presentation/widgets/lista/cobranza_asesor_picker_modal.dart

import 'package:flutter/material.dart';

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

/// Modal de búsqueda de asesor (por nombre o código) para el chip "Asesores"
/// de la lista de Cobranzas. Retorna el `codUser` elegido, o `null` si se
/// cierra sin seleccionar (back, tap fuera, o botón de cerrar) — el llamador
/// debe interpretar `null` como "volver al filtro Todos".
///
/// No dispara ninguna recarga al abrirse (revertido 2026-08-21, pedido
/// explícito del usuario) — usa directo el universo de asesores ya cargado
/// en [CatalogsBloc] (global, cargado una vez al iniciar sesión) y
/// [conteosPorAsesor], el snapshot que ya calculó `CobranzaListBloc` sobre
/// la lista pintada en pantalla. Antes recargaba ambos al abrir
/// (`CatalogsLoadRequested` + `CobranzaListRefresh`) y quedaba reactivo a
/// `CobranzaListBloc` — se quitó porque el modal puede abrirse desde un
/// `BuildContext` sin `Provider<CobranzaListBloc>` en su árbol (crash
/// reportado en vivo: "Could not find the correct `Provider<CobranzaListBloc>`
/// above this CobranzaAsesorPickerModal Widget") y porque el usuario
/// prefiere que solo muestre lo que ya está cargado, sin ninguna llamada de
/// red extra al abrir el picker.
class CobranzaAsesorPickerModal extends StatefulWidget {
  final Map<String, Map<int, int>> conteosPorAsesor;
  final String? seleccionadoActual;

  const CobranzaAsesorPickerModal({
    super.key,
    required this.conteosPorAsesor,
    this.seleccionadoActual,
  });

  static Future<String?> show(
    BuildContext context, {
    required Map<String, Map<int, int>> conteosPorAsesor,
    String? seleccionadoActual,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizing.radiusXl),
        ),
      ),
      builder: (_) => CobranzaAsesorPickerModal(
        conteosPorAsesor: conteosPorAsesor,
        seleccionadoActual: seleccionadoActual,
      ),
    );
  }

  @override
  State<CobranzaAsesorPickerModal> createState() =>
      _CobranzaAsesorPickerModalState();
}

class _CobranzaAsesorPickerModalState
    extends State<CobranzaAsesorPickerModal> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  // Universo de asesores refrescado con el task angosto 'ASE' (solo
  // asesores, sin el catálogo completo) — null mientras no llega o si falla
  // (best-effort), cae al snapshot de CatalogsBloc.state en ese caso. Mismo
  // criterio que CatalogsRemoteDatasource.getTipoCambio()/getAsesores(), ver
  // core/CLAUDE.md — evita recargar el catálogo entero (campañas,
  // oportunidades, etc.) solo para poner al día si de la nada asignaron un
  // asesor nuevo.
  List<AsesorItem>? _asesoresFrescos;

  @override
  void initState() {
    super.initState();
    _cargarAsesoresFrescos();
  }

  Future<void> _cargarAsesoresFrescos() async {
    try {
      // Ambito 'inscripciones': la lista sale de la misma tabla por la que
      // filtra esta pantalla (ID_USUARIO_EJEC). Con el universo de contactos
      // faltaban ejecutivos que si aparecen en las cards.
      final asesores = await context.read<CatalogsRepository>().getAsesores(
        ambito: AsesorAmbito.inscripciones,
      );
      if (mounted) setState(() => _asesoresFrescos = asesores);
    } catch (_) {
      // Best-effort — si falla, el picker sigue usable con el snapshot de
      // CatalogsBloc (catálogo cacheado desde el login).
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<AsesorItem> _filtrar(List<AsesorItem> asesores) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return asesores;
    return asesores
        .where(
          (a) =>
              a.nombre.toLowerCase().contains(q) ||
              a.codUser.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.sizeOf(context).height;

    final conteosPorAsesor = widget.conteosPorAsesor;

    return SizedBox(
      height: screenHeight * 0.75,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Center(
              child: Container(
                width: AppSizing.sheetHandleWidth,
                height: AppSizing.sheetHandleHeight,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(
                    AppSizing.radiusCircular,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.xs,
              AppSpacing.xs,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Seleccionar asesor',
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: AppTextStyles.weightSemiBold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    AppIcons.close,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: CustomTextField(
              controller: _searchCtrl,
              hint: 'Buscar por nombre o código',
              prefixIcon: Icon(AppIcons.search),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: BlocBuilder<CatalogsBloc, CatalogsState>(
              builder: (context, state) {
                if (state is CatalogsLoading || state is CatalogsInitial) {
                  return const AppLoadingView();
                }
                if (state is CatalogsError) {
                  return AppErrorView(
                    message: state.message,
                    onRetry: () => context.read<CatalogsBloc>().add(
                      const CatalogsLoadRequested(),
                    ),
                  );
                }

                final asesores =
                    _asesoresFrescos ?? (state as CatalogsLoaded).asesores;
                final filtrados = _filtrar(asesores);

                if (asesores.isEmpty) {
                  return const AppEmptyView(
                    message: 'No hay asesores en el catálogo.',
                  );
                }
                if (filtrados.isEmpty) {
                  return const AppEmptyView(
                    message: 'No se encontraron asesores.',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.xxs,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
                  itemCount: filtrados.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.xs),
                  itemBuilder: (context, i) {
                    final asesor = filtrados[i];
                    return _AsesorTile(
                      asesor: asesor,
                      conteoPorEstado:
                          conteosPorAsesor[asesor.codUser] ?? const {},
                      isSelected: asesor.codUser == widget.seleccionadoActual,
                      onTap: () => Navigator.of(context).pop(asesor.codUser),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AsesorTile extends StatelessWidget {
  final AsesorItem asesor;
  final Map<int, int> conteoPorEstado;
  final bool isSelected;
  final VoidCallback onTap;

  const _AsesorTile({
    required this.asesor,
    required this.conteoPorEstado,
    required this.isSelected,
    required this.onTap,
  });

  // Mismo orden/labels/íconos que CobranzaSummaryCards/CobranzaDetalleStepper
  // — 0 Pend.deDocumento, 2 Facturar, 5 Pend.factura, 3 Cancelado.
  static const _estados = [
    (id: 0, label: 'Pend. documento', icon: AppIcons.fileOutlined),
    (id: 2, label: 'Facturar', icon: AppIcons.receipt),
    (id: 5, label: 'Pend. pago', icon: AppIcons.time),
    (id: 3, label: 'Cancelado', icon: AppIcons.checkCircle),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm2,
        ),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primaryContainer : colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSizing.radiusMd),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
            width: isSelected
                ? AppSizing.borderFocusWidth
                : AppSizing.hairline,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: AppSizing.avatarRadiusXs,
                  backgroundColor: asesor.nombre.avatarColor,
                  child: Text(
                    asesor.nombre.initials,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textOnDark,
                      fontWeight: AppTextStyles.weightBold,
                    ),
                  ),
                ),
                if (asesor.disponible)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: AppSizing.dotIndicatorSize,
                      height: AppSizing.dotIndicatorSize,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.surface,
                          width: AppSizing.hairline,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    asesor.nombre,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: AppTextStyles.weightSemiBold,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    asesor.codUser,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Siempre visibles los 4 estados (activo=color, en 0=gris) — antes
            // solo aparecía el estado con cantidad > 0, chico, debajo del
            // nombre; pedido explícito del usuario: más grande, a la derecha,
            // y siempre los 4 aunque estén en cero (con datos reales donde
            // solo "Facturar" tenía cantidad, el resto ni aparecía).
            SizedBox(
              width: 96,
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: AppSpacing.xxs,
                runSpacing: AppSpacing.xxs,
                children: [
                  for (final e in _estados)
                    _EstadoBadgeGrande(
                      icon: e.icon,
                      color: colorEstadoGes(e.id),
                      cantidad: conteoPorEstado[e.id] ?? 0,
                      tooltip: e.label,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Badge grande: ícono + cantidad, coloreado por estado si tiene cantidad > 0,
// gris si está en 0 — a diferencia del chico de antes, siempre se renderiza
// (nunca se oculta por estar en cero). Mismo lenguaje visual que
// SolicitudAsesorPickerModal._EstadoBadgeGrande.
class _EstadoBadgeGrande extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int cantidad;
  final String tooltip;

  const _EstadoBadgeGrande({
    required this.icon,
    required this.color,
    required this.cantidad,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    // Cada estado conserva SIEMPRE su propio color (icono/texto/borde) esté
    // en 0 o no — igual que CobranzaSummaryCards, donde "Pend. pago"/
    // "Cancelado" en 0 se ven en su color (rojo/verde), nunca gris (fix real
    // 2026-08-21: la primera versión ponía gris genérico en 0, "faltan los
    // colores" reportado por el usuario). Relleno sólido (activo) vs. solo
    // borde (en 0) ya basta para distinguir "tiene registros" de "no tiene".
    final activo = cantidad > 0;
    final colorContenido = activo ? AppColors.textOnDark : color;

    return Tooltip(
      message: tooltip,
      child: Container(
        constraints: const BoxConstraints(
          minWidth: AppSizing.badgeEstadoMinWidth,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: activo ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizing.radiusCircular),
          border: activo ? null : Border.all(color: color),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: AppSizing.iconSm, color: colorContenido),
            const SizedBox(width: AppSpacing.xxs),
            Text(
              '$cantidad',
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: AppTextStyles.weightBold,
                color: colorContenido,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
