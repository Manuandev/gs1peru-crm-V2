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
    return DropdownButtonFormField<T>(
      initialValue: _selected,
      isExpanded: true,
      hint: widget.hint != null ? Text(widget.hint!) : null,
      decoration: InputDecoration(
        labelText: widget.label,
        enabled: widget.enabled,
        border: const OutlineInputBorder(),
      ),
      items: widget.data
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Text(
                  _getLabel(item),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ),
          )
          .toList(),
      selectedItemBuilder: (context) => widget.data
          .map(
            (item) => Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _getLabel(item),
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
