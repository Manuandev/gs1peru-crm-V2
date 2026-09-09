// lib/features/chat/presentation/widgets/chat_list/filtro_chat_drawer.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class FiltroChatDrawer extends StatefulWidget {
  const FiltroChatDrawer({super.key});

  @override
  State<FiltroChatDrawer> createState() => _FiltroChatDrawerState();
}

class _FiltroChatDrawerState extends State<FiltroChatDrawer> {
  final _nombreCtrl = TextEditingController();
  final _empresaCtrl = TextEditingController();
  final _numeroCtrl = TextEditingController();
  String _campaniaId = '';
  String _oportunidadId = '';

  @override
  void initState() {
    super.initState();
    final state = context.read<ChatListBloc>().state;
    if (state is ChatListSuccess) {
      _nombreCtrl.text = state.filtroNombre;
      _empresaCtrl.text = state.filtroEmpresa;
      _numeroCtrl.text = state.filtroNumero;
      _campaniaId = state.filtroCampaniaId;
      _oportunidadId = state.filtroOportunidadId;
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _empresaCtrl.dispose();
    _numeroCtrl.dispose();
    super.dispose();
  }

  void _aplicar() {
    context.read<ChatListBloc>().add(
      ChatListFiltroAvanzadoAplicado(
        nombre: _nombreCtrl.text.trim(),
        empresa: _empresaCtrl.text.trim(),
        numero: _numeroCtrl.text.trim(),
        campaniaId: _campaniaId,
        oportunidadId: _oportunidadId,
      ),
    );
    Navigator.of(context).pop();
  }

  void _limpiar() {
    context.read<ChatListBloc>().add(const ChatListFiltroAvanzadoLimpiado());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.xs, AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Icon(AppIcons.filter, size: AppSizing.iconMd, color: colorScheme.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Filtrar conversaciones',
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

            // ── Campos ────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomTextField(
                      label: 'Nombre del contacto',
                      hint: 'Ej: Juan Pérez',
                      controller: _nombreCtrl,
                      prefixIcon: const Icon(AppIcons.user),
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    CustomTextField(
                      label: 'Empresa',
                      hint: 'Ej: Empresa SAC',
                      controller: _empresaCtrl,
                      prefixIcon: const Icon(AppIcons.folder),
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    CustomTextField(
                      label: 'Número de teléfono',
                      hint: 'Ej: 999888777',
                      controller: _numeroCtrl,
                      prefixIcon: const Icon(AppIcons.phone),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Campaña y Oportunidad en cascada (mismo criterio que
                    // "Editar negociación"): sin campaña, Oportunidad lista
                    // TODO el catálogo; con campaña elegida, solo las
                    // oportunidades de esa campaña. Ambos filtros se aplican en
                    // memoria (AND) sobre Chat.idCampania / Chat.idOportunidad
                    // (ChatListBloc). El SP trae todo el catálogo — ver
                    // core/CLAUDE.md.
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
                        final oportunidades = _campaniaId.isEmpty
                            ? catState.oportunidades
                            : catState.oportunidades
                                  .where(
                                    (o) =>
                                        o.idCampania.toString() == _campaniaId,
                                  )
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
                              initialValue: _campaniaId,
                              onChanged: (item) {
                                final nuevoId = item?.id ?? '';
                                setState(() {
                                  _campaniaId = nuevoId;
                                  // Si la oportunidad ya elegida no pertenece a
                                  // la campaña nueva, se limpia — queda solo el
                                  // filtro de campaña hasta elegir una
                                  // oportunidad válida de esa campaña.
                                  if (_oportunidadId.isNotEmpty) {
                                    final sigueValida =
                                        nuevoId.isEmpty ||
                                        catState.oportunidades.any(
                                          (o) =>
                                              o.id.toString() == _oportunidadId &&
                                              o.idCampania.toString() == nuevoId,
                                        );
                                    if (!sigueValida) _oportunidadId = '';
                                  }
                                });
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),
                            CustomComboSearchField(
                              // Se recrea al cambiar de campaña para que el
                              // texto visible se resetee cuando cambian
                              // data/initialValue (el Autocomplete interno no
                              // resincroniza su texto solo).
                              key: ValueKey('filtro-oportunidad-$_campaniaId'),
                              data: dataOportunidades,
                              label: 'Oportunidad',
                              hint: 'Buscar oportunidad...',
                              displayIndex: 1,
                              initialValue: _oportunidadId,
                              onChanged: (item) => setState(
                                () => _oportunidadId = item?.id ?? '',
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

            // ── Acciones ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Divider(height: 1, color: colorScheme.outlineVariant),
                  const SizedBox(height: AppSpacing.sm),
                  CustomPrimaryButton(
                    text: 'APLICAR FILTROS',
                    onPressed: _aplicar,
                  ),
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
