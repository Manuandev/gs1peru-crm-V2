// lib/features/solicitudes/presentation/widgets/completar/solicitud_inputs.dart
//
// Widgets exclusivos del wizard de solicitud que NO tienen equivalente en
// lib/core/presentation/widgets — toggle de tipo de persona, badge de paso y
// el campo de celular con prefijo de país. Para texto/combos/botones usar
// siempre los widgets generales del core (CustomTextField, CustomComboField,
// CustomComboSearchField, CustomPrimaryButton, CustomSecondaryButton,
// CustomOutlinedButton) — no crear wrappers locales para ellos.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:app_crm/core/index_core.dart';

// ── SolicitudToggleTipoPersona (pill jurídica/natural) ────────────────────────

class SolicitudToggleTipoPersona extends StatelessWidget {
  final String valor;
  final bool habilitado;
  final ValueChanged<String> onChanged;

  const SolicitudToggleTipoPersona({
    super.key,
    required this.valor,
    required this.habilitado,
    required this.onChanged,
  });

  static const _duracion = Duration(milliseconds: 250);
  static const _curva = Curves.easeInOut;
  static const double _anchoPorOpcion = 82.0;

  @override
  Widget build(BuildContext context) {
    final esJuridica = valor == 'juridica';

    return SizedBox(
      height: AppSizing.buttonHeightSmall,
      width: _anchoPorOpcion * 2 + 6,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: AppColors.surfaceLightVariant,
          borderRadius: BorderRadius.circular(AppSizing.radiusCircular),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: _duracion,
              curve: _curva,
              left: esJuridica ? 0 : _anchoPorOpcion,
              top: 0,
              bottom: 0,
              width: _anchoPorOpcion,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppSizing.radiusCircular),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black(0.14),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                SizedBox(
                  width: _anchoPorOpcion,
                  child: GestureDetector(
                    onTap: habilitado ? () => onChanged('juridica') : null,
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: _duracion,
                        curve: _curva,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: esJuridica
                              ? AppColors.textOnDark
                              : AppColors.textSecondary,
                          fontWeight: esJuridica
                              ? AppTextStyles.weightSemiBold
                              : AppTextStyles.weightRegular,
                        ),
                        child: const Text('Jurídica'),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: _anchoPorOpcion,
                  child: GestureDetector(
                    onTap: habilitado ? () => onChanged('natural') : null,
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: _duracion,
                        curve: _curva,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: !esJuridica
                              ? AppColors.textOnDark
                              : AppColors.textSecondary,
                          fontWeight: !esJuridica
                              ? AppTextStyles.weightSemiBold
                              : AppTextStyles.weightRegular,
                        ),
                        child: const Text('Natural'),
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

// ── SolicitudCampoCelular (código telefónico por país, vía catálogo + input) ──
//
// El código telefónico viene de PaisItem.codigoTelefono (catálogo real,
// CatalogsBloc.paises). En el campo cerrado solo se muestra el código
// (ej. "+51") — el nombre del país solo aparece en la lista del selector,
// para poder buscarlo.

class SolicitudCampoCelular extends StatelessWidget {
  final TextEditingController controller;
  final bool habilitado;
  final List<PaisItem> paises;
  final PaisItem? paisSeleccionado;
  final ValueChanged<PaisItem> onPaisChanged;
  final String? Function(String?)? validator;

  const SolicitudCampoCelular({
    super.key,
    required this.controller,
    required this.habilitado,
    required this.paises,
    required this.paisSeleccionado,
    required this.onPaisChanged,
    this.validator,
  });

  Future<void> _abrirSelector(BuildContext context) async {
    if (paises.isEmpty) return;
    final seleccionado = await showModalBottomSheet<PaisItem>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SelectorPaisTelefono(paises: paises),
    );
    if (seleccionado != null) onPaisChanged(seleccionado);
  }

  @override
  Widget build(BuildContext context) {
    final codigo = paisSeleccionado?.codigoTelefono ?? '';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: habilitado ? () => _abrirSelector(context) : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              decoration: BoxDecoration(
                color: habilitado
                    ? AppColors.inputBackground
                    : AppColors.surfaceLightVariant,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(AppSizing.radiusMd),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    codigo.isEmpty ? '+ --' : '+$codigo',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: AppTextStyles.weightMedium,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  const Icon(
                    Icons.expand_more_rounded,
                    size: AppSizing.iconSm,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: CustomTextField(
              label: 'Celular *',
              controller: controller,
              keyboardType: TextInputType.phone,
              enabled: habilitado,
              maxLength: 9,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: validator,
            ),
          ),
        ],
      ),
    );
  }
}

// ── SolicitudCampoCelularBusqueda (variante con combo de búsqueda) ───────────
//
// Mismo propósito que SolicitudCampoCelular (código telefónico + celular),
// pero el selector de país es un CustomComboSearchField (tipear para
// filtrar, por prefijo o por nombre del país) en vez de un modal — pedido de
// negocio, 2026-07-22, **solo para el paso 3 (Facturación)**. Los otros 2
// lugares que usan el campo de celular (Datos del solicitante, paso 1, y
// Nuevo participante) siguen con SolicitudCampoCelular (modal) tal cual —
// decisión explícita, no se generalizó el cambio a los 3 lugares. Si más
// adelante se pide ahí también, evaluar unificar en un solo widget.

class SolicitudCampoCelularBusqueda extends StatelessWidget {
  final TextEditingController controller;
  final bool habilitado;
  final List<PaisItem> paises;
  final PaisItem? paisSeleccionado;
  final ValueChanged<PaisItem> onPaisChanged;
  final String? Function(String?)? validator;

  const SolicitudCampoCelularBusqueda({
    super.key,
    required this.controller,
    required this.habilitado,
    required this.paises,
    required this.paisSeleccionado,
    required this.onPaisChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final data = paises
        .map(
          (p) =>
              '${p.codigoTelefono}${AppConstants.sepCampos}'
              '${p.nombre} (+${p.codigoTelefono})',
        )
        .toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: CustomComboSearchField(
            data: data,
            label: 'País',
            enabled: habilitado,
            initialValue: paisSeleccionado?.codigoTelefono,
            onChanged: (item) {
              if (item == null) return;
              final pais = paises
                  .where((p) => p.codigoTelefono == item.id)
                  .firstOrNull;
              if (pais != null) onPaisChanged(pais);
            },
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          flex: 3,
          child: CustomTextField(
            label: 'Celular *',
            controller: controller,
            keyboardType: TextInputType.phone,
            enabled: habilitado,
            maxLength: 9,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: validator,
          ),
        ),
      ],
    );
  }
}

// ── Selector de país (código telefónico) — bottom sheet con búsqueda ─────────

class _SelectorPaisTelefono extends StatefulWidget {
  final List<PaisItem> paises;

  const _SelectorPaisTelefono({required this.paises});

  @override
  State<_SelectorPaisTelefono> createState() => _SelectorPaisTelefonoState();
}

class _SelectorPaisTelefonoState extends State<_SelectorPaisTelefono> {
  late List<PaisItem> _filtrados;

  @override
  void initState() {
    super.initState();
    _filtrados = widget.paises;
  }

  void _filtrar(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      _filtrados = q.isEmpty
          ? widget.paises
          : widget.paises
                .where(
                  (p) =>
                      p.nombre.toLowerCase().contains(q) ||
                      p.codigoTelefono.contains(q),
                )
                .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSizing.radiusXl),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(AppSizing.radiusCircular),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: CustomTextField(
                label: 'Buscar país',
                prefixIcon: const Icon(AppIcons.search),
                onChanged: _filtrar,
              ),
            ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _filtrados.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final pais = _filtrados[i];
                  return ListTile(
                    title: Text(pais.nombre),
                    trailing: Text(
                      '+${pais.codigoTelefono}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: AppTextStyles.weightSemiBold,
                      ),
                    ),
                    onTap: () => Navigator.of(context).pop(pais),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── SolicitudBadgePaso (chip "Paso X de Y" del AppBar) ───────────────────────

class SolicitudBadgePaso extends StatelessWidget {
  final int paso;
  final int total;

  const SolicitudBadgePaso({super.key, required this.paso, this.total = 4});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.white(0.15),
          borderRadius: BorderRadius.circular(AppSizing.radiusSm),
        ),
        child: Text(
          '$paso de $total',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textOnDark,
            fontWeight: AppTextStyles.weightSemiBold,
          ),
        ),
      ),
    );
  }
}
