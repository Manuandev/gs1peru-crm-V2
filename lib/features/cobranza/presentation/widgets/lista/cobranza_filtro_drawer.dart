// lib/features/cobranza/presentation/widgets/lista/cobranza_filtro_drawer.dart
//
// Panel lateral derecho de filtros de Cobranzas — mismo patrón que
// SeguimientoFiltroDrawer / SolicitudFiltroDrawer. Va al SP (task 'LSP' es
// paginado). Rango de fechas: cada extremo con su checkbox (Desde → 00:00:00,
// Hasta → 23:59:59; filtra CI.FC_USUARIO_C). Campaña → Oportunidad en cascada.

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaFiltroDrawer extends StatefulWidget {
  const CobranzaFiltroDrawer({super.key});

  @override
  State<CobranzaFiltroDrawer> createState() => _CobranzaFiltroDrawerState();
}

class _CobranzaFiltroDrawerState extends State<CobranzaFiltroDrawer> {
  DateTime? _desde;
  bool _desdeActivo = false;
  DateTime? _hasta;
  bool _hastaActivo = false;
  int? _campaniaId;
  int? _oportunidadId;

  @override
  void initState() {
    super.initState();
    final state = context.read<CobranzaListBloc>().state;
    final f = state is CobranzaListCargado
        ? state.filtroAvanzado
        : CobranzaFiltroAvanzado.porDefecto();
    _desde = f.desde;
    _desdeActivo = f.desdeActivo;
    _hasta = f.hasta;
    _hastaActivo = f.hastaActivo;
    _campaniaId = f.idCampania;
    _oportunidadId = f.idOportunidad;
  }

  void _aplicar() {
    context.read<CobranzaListBloc>().add(
      CobranzaFiltroAvanzadoAplicado(
        CobranzaFiltroAvanzado(
          desde: _desde,
          desdeActivo: _desdeActivo && _desde != null,
          hasta: _hasta,
          hastaActivo: _hastaActivo && _hasta != null,
          idCampania: _campaniaId,
          idOportunidad: _oportunidadId,
        ),
      ),
    );
    Navigator.of(context).pop();
  }

  void _limpiar() {
    context.read<CobranzaListBloc>().add(const CobranzaFiltroAvanzadoLimpiado());
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
                      'Filtrar cobranzas',
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
                        final oportunidades = _campaniaId == null
                            ? catState.oportunidades
                            : catState.oportunidades
                                  .where((o) => o.idCampania == _campaniaId)
                                  .toList();
                        final dataOportunidades = oportunidades
                            .map(
                              (o) =>
                                  '${o.id}${AppConstants.sepCampos}${o.nombre}',
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
                                  if (_oportunidadId != null) {
                                    final sigueValida =
                                        nuevo == null ||
                                        catState.oportunidades.any(
                                          (o) =>
                                              o.id == _oportunidadId &&
                                              o.idCampania == nuevo,
                                        );
                                    if (!sigueValida) _oportunidadId = null;
                                  }
                                });
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),
                            CustomComboSearchField(
                              key: ValueKey('cob-filtro-oport-$_campaniaId'),
                              data: dataOportunidades,
                              label: 'Oportunidad',
                              hint: 'Buscar oportunidad...',
                              displayIndex: 1,
                              initialValue: _oportunidadId?.toString() ?? '',
                              onChanged: (item) => setState(
                                () => _oportunidadId = int.tryParse(
                                  item?.id ?? '',
                                ),
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
