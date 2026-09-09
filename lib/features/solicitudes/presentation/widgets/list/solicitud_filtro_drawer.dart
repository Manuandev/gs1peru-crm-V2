// lib/features/solicitudes/presentation/widgets/list/solicitud_filtro_drawer.dart
//
// Panel lateral derecho de filtros de Solicitudes — mismo patrón que
// SeguimientoFiltroDrawer. El filtro va al SP (task 'LSP' es paginado).
//
// Rango de fechas: cada extremo con su checkbox (Desde → 00:00:00, Hasta →
// 23:59:59). Por defecto: del 1 del mes actual a hoy, ambos activos (igual que
// la web). Campaña → Evento en cascada (evento se recorta a los de esa campaña).

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class SolicitudFiltroDrawer extends StatefulWidget {
  const SolicitudFiltroDrawer({super.key});

  @override
  State<SolicitudFiltroDrawer> createState() => _SolicitudFiltroDrawerState();
}

class _SolicitudFiltroDrawerState extends State<SolicitudFiltroDrawer> {
  DateTime? _desde;
  bool _desdeActivo = false;
  DateTime? _hasta;
  bool _hastaActivo = false;
  int? _campaniaId;
  int? _eventoId;

  @override
  void initState() {
    super.initState();
    final state = context.read<SolicitudListBloc>().state;
    final f = state is SolicitudListSuccess
        ? state.filtroAvanzado
        : SolicitudFiltroAvanzado.porDefecto();
    _desde = f.desde;
    _desdeActivo = f.desdeActivo;
    _hasta = f.hasta;
    _hastaActivo = f.hastaActivo;
    _campaniaId = f.idCampania;
    _eventoId = f.idEvento;
  }

  void _aplicar() {
    context.read<SolicitudListBloc>().add(
      SolicitudFiltroAvanzadoAplicado(
        SolicitudFiltroAvanzado(
          desde: _desde,
          desdeActivo: _desdeActivo && _desde != null,
          hasta: _hasta,
          hastaActivo: _hastaActivo && _hasta != null,
          idCampania: _campaniaId,
          idEvento: _eventoId,
        ),
      ),
    );
    Navigator.of(context).pop();
  }

  void _limpiar() {
    context.read<SolicitudListBloc>().add(
      const SolicitudFiltroAvanzadoLimpiado(),
    );
    Navigator.of(context).pop();
  }

  Future<void> _elegirFecha({required bool esDesde}) async {
    final ahora = DateTime.now();
    final inicial = (esDesde ? _desde : _hasta) ?? ahora;
    final elegida = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: DateTime(ahora.year - 5),
      lastDate: DateTime(ahora.year + 1, 12, 31),
    );
    if (elegida == null) return;
    setState(() {
      if (esDesde) {
        _desde = elegida;
        _desdeActivo = true;
      } else {
        _hasta = elegida;
        _hastaActivo = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.xs,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Icon(
                    AppIcons.filter,
                    size: AppSizing.iconMd,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Filtrar solicitudes',
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: AppTextStyles.weightSemiBold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(AppIcons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: colorScheme.outlineVariant),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Rango de fechas',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: AppTextStyles.weightSemiBold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _CampoFecha(
                      label: 'Desde',
                      fecha: _desde,
                      activo: _desdeActivo,
                      onCheck: (v) => setState(() => _desdeActivo = v),
                      onTap: () => _elegirFecha(esDesde: true),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _CampoFecha(
                      label: 'Hasta',
                      fecha: _hasta,
                      activo: _hastaActivo,
                      onCheck: (v) => setState(() => _hastaActivo = v),
                      onTap: () => _elegirFecha(esDesde: false),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Campaña → Evento en cascada.
                    BlocBuilder<CatalogsBloc, CatalogsState>(
                      builder: (context, catState) {
                        if (catState is! CatalogsLoaded) {
                          return const SizedBox.shrink();
                        }
                        final dataCampanias = catState.campanias
                            .map(
                              (c) =>
                                  '${c.id}${AppConstants.sepCampos}${c.nombre}',
                            )
                            .toList();
                        final eventos = _campaniaId == null
                            ? catState.eventos
                            : catState.eventos
                                  .where((e) => e.idCampania == _campaniaId)
                                  .toList();
                        final dataEventos = eventos
                            .map(
                              (e) =>
                                  '${e.id}${AppConstants.sepCampos}${e.nombre}',
                            )
                            .toList();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CustomComboSearchField(
                              data: dataCampanias,
                              label: 'Campaña',
                              hint: 'Buscar campaña...',
                              displayIndex: 1,
                              initialValue: _campaniaId?.toString() ?? '',
                              onChanged: (item) {
                                final nuevo = int.tryParse(item?.id ?? '');
                                setState(() {
                                  _campaniaId = nuevo;
                                  if (_eventoId != null) {
                                    final sigue =
                                        nuevo == null ||
                                        catState.eventos.any(
                                          (e) =>
                                              e.id == _eventoId &&
                                              e.idCampania == nuevo,
                                        );
                                    if (!sigue) _eventoId = null;
                                  }
                                });
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),
                            CustomComboSearchField(
                              key: ValueKey('sol-filtro-evento-$_campaniaId'),
                              data: dataEventos,
                              label: 'Evento',
                              hint: 'Buscar evento...',
                              displayIndex: 1,
                              initialValue: _eventoId?.toString() ?? '',
                              onChanged: (item) => setState(
                                () => _eventoId = int.tryParse(item?.id ?? ''),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Divider(height: 1, color: colorScheme.outlineVariant),
                  const SizedBox(height: AppSpacing.sm),
                  CustomPrimaryButton(text: 'BUSCAR', onPressed: _aplicar),
                  CustomTextButton(
                    text: 'Limpiar filtros',
                    onPressed: _limpiar,
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

class _CampoFecha extends StatelessWidget {
  final String label;
  final DateTime? fecha;
  final bool activo;
  final ValueChanged<bool> onCheck;
  final VoidCallback onTap;

  const _CampoFecha({
    required this.label,
    required this.fecha,
    required this.activo,
    required this.onCheck,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final texto = fecha == null
        ? 'Elegir fecha'
        : fecha!.format(AppDateFormat.shortDate);

    return Row(
      children: [
        SizedBox(
          width: AppSizing.iconLg,
          child: Checkbox(
            value: activo,
            onChanged: (v) => onCheck(v ?? false),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSizing.radiusSm),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizing.radiusSm),
                border: Border.all(color: colorScheme.outline),
              ),
              child: Row(
                children: [
                  Icon(
                    AppIcons.calendar,
                    size: AppSizing.iconActionSm,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '$label: ',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      texto,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: fecha == null
                            ? AppColors.textDisabled
                            : AppColors.textPrimary,
                        fontWeight: AppTextStyles.weightMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
