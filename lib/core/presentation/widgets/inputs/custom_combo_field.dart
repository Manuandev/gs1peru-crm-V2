// lib/core/presentation/widgets/inputs/custom_combo_field.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';

/// Combo de selección simple con scroll (dropdown clásico).
///
/// Uso básico:
/// ```dart
/// CustomComboField(
///   controlId: 'CBO_CARGO',
///   data: globalLists.rhCargos,  // ["001¦Gerente¦GER¦Nivel3", ...]
///   label: 'Cargo',
///   displayIndex: 1,             // muestra descripcion
///   onChanged: (item) {
///     print(item?.id);           // "001"
///     print(item?.value(3));     // "Nivel3"
///   },
/// )
/// ```
class CustomComboField<T extends Comboable> extends StatefulWidget {
  final List<T> data;
  final int idIndex;
  final int labelIndex;
  final String label;
  final String? hint;
  final String? initialValue; // coincide con fields[idIndex].toString()
  final void Function(T? item)? onChanged;
  final bool enabled;
  final String? Function(String?)? validator;
  // Si true: reduce padding interno — ideal para formularios densos
  final bool dense;
  // Ícono prefijo dentro del campo
  final Widget? prefixIcon;

  const CustomComboField({
    super.key,
    required this.data,
    this.idIndex = 0,
    this.labelIndex = 1,
    required this.label,
    this.hint,
    this.initialValue,
    this.onChanged,
    this.enabled = true,
    this.validator,
    this.dense = false,
    this.prefixIcon,
  });

  @override
  State<CustomComboField<T>> createState() => _CustomComboFieldState<T>();
}

class _CustomComboFieldState<T extends Comboable>
    extends State<CustomComboField<T>> {
  T? _selected;

  String _getId(T item) => item.fields[widget.idIndex].toString();
  String _getLabel(T item) => item.fields[widget.labelIndex].toString();

  @override
  void initState() {
    super.initState();
    _selected = widget.initialValue != null
        ? widget.data.where((e) => _getId(e) == widget.initialValue).firstOrNull
        : null;
  }

  @override
  void didUpdateWidget(covariant CustomComboField<T> old) {
    super.didUpdateWidget(old);
    if (old.data != widget.data) {
      // si el item seleccionado ya no existe en la nueva lista, resetea
      if (_selected != null &&
          !widget.data.any((e) => _getId(e) == _getId(_selected as T))) {
        _selected = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // ignore: deprecated_member_use
    final disabledColor = Theme.of(context).disabledColor.withOpacity(0.4);

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizing.radiusSm),
      borderSide: BorderSide(color: colorScheme.outline),
    );

    return DropdownButtonFormField<T>(
      initialValue: _selected,
      isExpanded: true,
      hint: widget.hint != null
          ? Text(
              widget.hint!,
              style: const TextStyle(
                fontSize: AppTextStyles.sizeXs,
                color: AppColors.textDisabled,
              ),
            )
          : null,
      style: AppTextStyles.inputTextCompact.copyWith(
        color: widget.enabled ? AppColors.textPrimary : AppColors.textSecondary,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        enabled: widget.enabled,
        labelStyle: const TextStyle(
          fontSize: AppTextStyles.sizeXs,
          color: AppColors.textSecondary,
        ),
        floatingLabelStyle: const TextStyle(
          fontSize: AppTextStyles.sizeXs,
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: widget.prefixIcon,
        filled: true,
        fillColor: widget.enabled
            ? colorScheme.surface
            : colorScheme.surfaceContainerHighest,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm2,
        ),
        border: border,
        enabledBorder: border,
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
          borderSide: BorderSide(color: disabledColor),
        ),
      ),
      items: widget.data.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return DropdownMenuItem<T>(
          value: item,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (index > 0)
                const Divider(height: 1, thickness: 0.5, color: AppColors.border),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.xs,
                  horizontal: AppSpacing.xxs,
                ),
                child: Text(
                  _getLabel(item),
                  style: AppTextStyles.inputTextCompact,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      selectedItemBuilder: (context) => widget.data
          .map(
            (item) => Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _getLabel(item),
                style: AppTextStyles.inputTextCompact,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          )
          .toList(),
      onChanged: widget.enabled
          ? (val) {
              setState(() => _selected = val);
              widget.onChanged?.call(val);
            }
          : null,
      validator: widget.validator != null
          ? (_) => widget.validator!(
                _selected != null ? _getId(_selected as T) : null,
              )
          : null,
    );
  }
}
