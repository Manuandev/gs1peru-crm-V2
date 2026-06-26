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
