// lib/features/solicitudes/presentation/widgets/completar/solicitud_inputs.dart
//
// Inputs compactos exclusivos para los formularios de solicitud.
// No modificar CustomTextField/CustomComboSearchField — estos son wrappers locales
// con menor altura y texto más pequeño, pensados para los pasos de inscripción.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:app_crm/core/index_core.dart';

// ── Constantes de estilo compacto ─────────────────────────────────────────────

const _kFontSize = 11.0;
const _kVerticalPadding = 10.0;

const _kInputStyle = TextStyle(
  fontSize: _kFontSize,
  color: AppColors.textPrimary,
);

const _kLabelStyle = TextStyle(
  fontSize: _kFontSize,
  color: AppColors.textSecondary,
);

const _kHintStyle = TextStyle(
  fontSize: _kFontSize,
  color: AppColors.textDisabled,
);

const _kFloatingLabelStyle = TextStyle(
  fontSize: _kFontSize,
  color: AppColors.primary,
  fontWeight: FontWeight.w600,
);

const _kContentPadding = EdgeInsets.symmetric(
  horizontal: AppSpacing.sm,
  vertical: _kVerticalPadding,
);

// ── SolicitudTextField ────────────────────────────────────────────────────────

class SolicitudTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool enabled;
  final bool readOnly;
  final bool isUpperCase;
  final TextCapitalization textCapitalization;
  final int? maxLines;
  final int? minLines;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;
  final FocusNode? focusNode;

  const SolicitudTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.keyboardType,
    this.enabled = true,
    this.readOnly = false,
    this.isUpperCase = false,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.minLines,
    this.suffixIcon,
    this.prefixIcon,
    this.validator,
    this.onChanged,
    this.onTap,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final List<TextInputFormatter> formatters = isUpperCase
        ? [_UpperCaseFormatter()]
        : [];

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      readOnly: readOnly,
      textCapitalization: textCapitalization,
      maxLines: maxLines,
      minLines: minLines,
      inputFormatters: formatters.isNotEmpty ? formatters : null,
      validator: validator,
      onChanged: onChanged,
      onTap: onTap,
      focusNode: focusNode,
      style: _kInputStyle.copyWith(
        color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: _kLabelStyle,
        hintStyle: _kHintStyle,
        floatingLabelStyle: _kFloatingLabelStyle,
        contentPadding: _kContentPadding,
        isDense: true,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: enabled
            ? Theme.of(context).colorScheme.surface
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizing.radiusSm),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizing.radiusSm),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizing.radiusSm),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: AppSizing.borderFocusWidth,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizing.radiusSm),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizing.radiusSm),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: AppSizing.borderFocusWidth,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizing.radiusSm),
          // ignore: deprecated_member_use
          borderSide: BorderSide(
            color: Theme.of(context).disabledColor.withOpacity(0.4),
          ),
        ),
      ),
    );
  }
}

// ── SolicitudComboField ───────────────────────────────────────────────────────

class SolicitudComboField extends StatefulWidget {
  final List<String> data;
  final String label;
  final String? hint;
  final int displayIndex;
  final String separator;
  final bool enabled;
  final String? initialValue;
  final void Function(ComboItem? item)? onChanged;
  final String? Function(String?)? validator;
  final int maxSuggestions;

  const SolicitudComboField({
    super.key,
    required this.data,
    required this.label,
    this.hint,
    this.displayIndex = 1,
    this.separator = '¦',
    this.enabled = true,
    this.initialValue,
    this.onChanged,
    this.validator,
    this.maxSuggestions = 6,
  });

  @override
  State<SolicitudComboField> createState() => _SolicitudComboFieldState();
}

class _SolicitudComboFieldState extends State<SolicitudComboField> {
  late List<ComboItem> _allItems;
  ComboItem? _selected;

  @override
  void initState() {
    super.initState();
    _allItems = ComboItem.fromList(widget.data, separator: widget.separator);
    _selected = widget.initialValue != null
        ? _allItems.where((e) => e.id == widget.initialValue).firstOrNull
        : null;
  }

  @override
  void didUpdateWidget(covariant SolicitudComboField old) {
    super.didUpdateWidget(old);
    if (old.data != widget.data || old.separator != widget.separator) {
      _allItems = ComboItem.fromList(widget.data, separator: widget.separator);
      if (_selected != null && !_allItems.any((e) => e.id == _selected!.id)) {
        _selected = null;
      }
    }
  }

  String _display(ComboItem item) =>
      item.field(widget.displayIndex) ?? item.descripcion;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Autocomplete<ComboItem>(
      initialValue: _selected != null
          ? TextEditingValue(text: _display(_selected!))
          : null,
      displayStringForOption: _display,
      optionsBuilder: (tv) {
        if (tv.text.isEmpty) return _allItems;
        final q = tv.text.toLowerCase();
        return _allItems.where((e) => _display(e).toLowerCase().contains(q));
      },
      optionsMaxHeight: widget.maxSuggestions * AppSizing.buttonHeight,
      onSelected: (item) {
        _selected = item;
        widget.onChanged?.call(item);
      },
      fieldViewBuilder: (context, controller, focusNode, _) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          enabled: widget.enabled,
          style: _kInputStyle.copyWith(
            color: widget.enabled
                ? AppColors.textPrimary
                : AppColors.textSecondary,
          ),
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            labelStyle: _kLabelStyle,
            hintStyle: _kHintStyle,
            floatingLabelStyle: _kFloatingLabelStyle,
            contentPadding: _kContentPadding,
            isDense: true,
            filled: true,
            fillColor: widget.enabled
                ? colorScheme.surface
                : colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizing.radiusSm),
              borderSide: BorderSide(color: colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizing.radiusSm),
              borderSide: BorderSide(color: colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizing.radiusSm),
              borderSide: BorderSide(
                color: colorScheme.primary,
                width: AppSizing.borderFocusWidth,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizing.radiusSm),
              borderSide: BorderSide(color: colorScheme.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizing.radiusSm),
              borderSide: BorderSide(
                color: colorScheme.error,
                width: AppSizing.borderFocusWidth,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizing.radiusSm),
              // ignore: deprecated_member_use
              borderSide: BorderSide(
                color: Theme.of(context).disabledColor.withOpacity(0.4),
              ),
            ),
            suffixIconConstraints: const BoxConstraints(
              maxHeight: 38,
              maxWidth: 36,
            ),
            suffixIcon: AnimatedBuilder(
              animation: controller,
              builder: (_, _) => Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: controller.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          controller.clear();
                          _selected = null;
                          widget.onChanged?.call(null);
                        },
                        child: const Icon(
                          AppIcons.close,
                          size: AppSizing.iconSm,
                          color: AppColors.textSecondary,
                        ),
                      )
                    : const Icon(
                        Icons.expand_more_rounded,
                        size: AppSizing.iconMd,
                        color: AppColors.textSecondary,
                      ),
              ),
            ),
          ),
          validator: widget.validator != null
              ? (_) => widget.validator!(_selected?.id)
              : null,
        );
      },
      optionsViewBuilder: (context, onSelected, options) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: AppSizing.elevationMedium,
          borderRadius: BorderRadius.circular(AppSizing.radiusSm),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: widget.maxSuggestions * AppSizing.buttonHeight,
              maxWidth: MediaQuery.of(context).size.width - AppSpacing.xl,
            ),
            child: ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: options.length,
              separatorBuilder: (_, _) => const Divider(
                height: AppSizing.hairline,
                indent: AppSpacing.md,
              ),
              itemBuilder: (_, i) {
                final item = options.elementAt(i);
                return ListTile(
                  dense: true,
                  title: Text(
                    _display(item),
                    style: _kInputStyle,
                  ),
                  onTap: () => onSelected(item),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ── Formatter interno ─────────────────────────────────────────────────────────

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) =>
      TextEditingValue(
        text: newValue.text.toUpperCase(),
        selection: newValue.selection,
      );
}

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

// ── SolicitudCampoCelular (prefijo de país + input) ───────────────────────────

class SolicitudCampoCelular extends StatelessWidget {
  final TextEditingController controller;
  final bool habilitado;

  const SolicitudCampoCelular({
    super.key,
    required this.controller,
    required this.habilitado,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: habilitado ? () {} : null,
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
                    '🇵🇪',
                    style: TextStyle(fontSize: AppTextStyles.sizeMd),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '+51',
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
            child: SolicitudTextField(
              label: 'Celular *',
              controller: controller,
              keyboardType: TextInputType.phone,
              enabled: habilitado,
            ),
          ),
        ],
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
          'Paso $paso de $total',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textOnDark,
            fontWeight: AppTextStyles.weightSemiBold,
          ),
        ),
      ),
    );
  }
}

// ── Botones de pie compartidos ────────────────────────────────────────────────

class SolicitudBotonBorrador extends StatelessWidget {
  final VoidCallback? onPressed;

  const SolicitudBotonBorrador({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(AppIcons.save, size: AppSizing.iconActionSm),
      label: const Text('Guardar borrador'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.secondary,
        side: const BorderSide(color: AppColors.secondary),
        minimumSize: const Size.fromHeight(AppSizing.buttonHeightSmall),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        ),
        textStyle: AppTextStyles.labelSmall.copyWith(
          fontWeight: AppTextStyles.weightSemiBold,
        ),
      ),
    );
  }
}

class SolicitudBotonContinuar extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;

  const SolicitudBotonContinuar({
    super.key,
    required this.onPressed,
    this.label = 'Continuar →',
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnDark,
        minimumSize: const Size.fromHeight(AppSizing.buttonHeightSmall),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        ),
        textStyle: AppTextStyles.labelSmall.copyWith(
          fontWeight: AppTextStyles.weightSemiBold,
        ),
      ),
      child: Text(label),
    );
  }
}

class SolicitudBotonAtras extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final IconData? icono;

  const SolicitudBotonAtras({
    super.key,
    required this.onPressed,
    this.label = 'Atrás',
    this.icono,
  });

  @override
  Widget build(BuildContext context) {
    final style = OutlinedButton.styleFrom(
      foregroundColor: AppColors.brandRaspberryAccessible,
      side: const BorderSide(color: AppColors.brandRaspberryAccessible),
      minimumSize: const Size.fromHeight(AppSizing.buttonHeightSmall),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
      ),
      textStyle: AppTextStyles.labelSmall.copyWith(
        fontWeight: AppTextStyles.weightSemiBold,
      ),
    );

    if (icono != null) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icono, size: AppSizing.iconActionSm),
        label: Text(label),
        style: style,
      );
    }

    return OutlinedButton(
      onPressed: onPressed,
      style: style,
      child: Text(label),
    );
  }
}
