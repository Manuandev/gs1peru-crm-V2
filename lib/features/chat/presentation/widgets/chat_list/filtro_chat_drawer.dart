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
  String _oportunidadId = '';

  @override
  void initState() {
    super.initState();
    final state = context.read<ChatListBloc>().state;
    if (state is ChatListSuccess) {
      _nombreCtrl.text = state.filtroNombre;
      _empresaCtrl.text = state.filtroEmpresa;
      _numeroCtrl.text = state.filtroNumero;
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
                    BlocBuilder<CatalogsBloc, CatalogsState>(
                      builder: (context, catState) {
                        if (catState is! CatalogsLoaded) return const SizedBox.shrink();
                        final data = catState.oportunidades
                            .map((o) => '${o.id}${AppConstants.sepCampos}${o.nombre}')
                            .toList();
                        return CustomComboSearchField(
                          data: data,
                          label: 'Oportunidad',
                          hint: 'Buscar oportunidad...',
                          displayIndex: 1,
                          initialValue: _oportunidadId,
                          onChanged: (item) => setState(
                            () => _oportunidadId = item?.id ?? '',
                          ),
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
