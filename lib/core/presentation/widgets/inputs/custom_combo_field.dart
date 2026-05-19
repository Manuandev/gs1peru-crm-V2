// lib\core\presentation\widgets\inputs\custom_combo_field.dart

import 'package:app_crm/core/index_core.dart';
import 'package:flutter/material.dart';

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
class CustomComboField extends StatefulWidget {
  /// Lista cruda: cada elemento es "id¦descripcion¦value...".
  final List<String> data;

  /// Separador de campos (default ¦).
  final String separator;

  /// Índice del campo que se muestra en el dropdown (0-based).
  ///   0 → id | 1 → descripcion | 2 → value(2) | 3 → value(3) | ...
  final int displayIndex;

  final String label;
  final String? hint;

  /// Valor inicial: debe coincidir con [ComboItem.id].
  final String? initialValue;

  final void Function(ComboItem? item)? onChanged;
  final bool enabled;

  /// Validador: recibe el [ComboItem.id] seleccionado (nullable si no seleccionó).
  final String? Function(String?)? validator;

  const CustomComboField({
    super.key,
    required this.data,
    this.separator = '¦',
    this.displayIndex = 1,
    required this.label,
    this.hint,
    this.initialValue,
    this.onChanged,
    this.enabled = true,
    this.validator,
  });

  @override
  State<CustomComboField> createState() => _CustomComboFieldState();
}

class _CustomComboFieldState extends State<CustomComboField> {
  late List<ComboItem> _items;
  ComboItem? _selected;

  @override
  void initState() {
    super.initState();
    _rebuild();
  }

  @override
  void didUpdateWidget(covariant CustomComboField old) {
    super.didUpdateWidget(old);
    if (old.data != widget.data || old.separator != widget.separator) {
      _rebuild();
    }
  }

  void _rebuild() {
    _items = ComboItem.fromList(widget.data, separator: widget.separator);
    _selected = widget.initialValue != null
        ? _items.where((e) => e.id == widget.initialValue).firstOrNull
        : null;
  }

  String _display(ComboItem item) =>
      item.field(widget.displayIndex) ?? item.descripcion;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<ComboItem>(
      initialValue: _selected,
      isExpanded: true,
      hint: widget.hint != null ? Text(widget.hint!) : null,
      decoration: InputDecoration(
        labelText: widget.label,
        enabled: widget.enabled,
        border: const OutlineInputBorder(),
      ),
      items: _items
          .map((item) => DropdownMenuItem<ComboItem>(
                value: item,
                child: Text(_display(item)),
              ))
          .toList(),
      onChanged: widget.enabled
          ? (val) {
              setState(() => _selected = val);
              widget.onChanged?.call(val);
            }
          : null,
      validator: widget.validator != null
          ? (val) => widget.validator!(val?.id)
          : null,
    );
  }

  // ── Getters de acceso rápido ─────────────────────────────────────────────
  ComboItem? get selectedItem => _selected;
  String?    get selectedId   => _selected?.id;

  /// Accede a cualquier campo del item seleccionado por índice.
  String?    selectedValue(int index) => _selected?.field(index);
}