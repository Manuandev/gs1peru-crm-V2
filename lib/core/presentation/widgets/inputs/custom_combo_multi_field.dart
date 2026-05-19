// lib\core\presentation\widgets\inputs\custom_combo_multi_field.dart

import 'package:app_crm/core/index_core.dart';
import 'package:flutter/material.dart';

class CustomComboMultiField extends StatefulWidget {
  final List<String> data;
  final String separator;
  final int displayIndex;
  final String label;
  final String? hint;
  final List<String> initialValues;
  final void Function(List<ComboItem> items)? onChanged;
  final bool enabled;
  final String? Function(List<ComboItem>)? validator;

  const CustomComboMultiField({
    super.key,
    required this.data,
    this.separator = '¦',
    this.displayIndex = 1,
    required this.label,
    this.hint,
    this.initialValues = const [],
    this.onChanged,
    this.enabled = true,
    this.validator,
  });

  @override
  State<CustomComboMultiField> createState() => _CustomComboMultiFieldState();
}

class _CustomComboMultiFieldState extends State<CustomComboMultiField> {
  late List<ComboItem> _allItems;
  late List<ComboItem> _selected;

  @override
  void initState() {
    super.initState();
    _allItems = ComboItem.fromList(widget.data, separator: widget.separator);
    _selected = _allItems.where((e) => widget.initialValues.contains(e.id)).toList();
  }

  @override
  void didUpdateWidget(covariant CustomComboMultiField old) {
    super.didUpdateWidget(old);
    if (old.data != widget.data || old.separator != widget.separator) {
      _allItems = ComboItem.fromList(widget.data, separator: widget.separator);
      _selected = _selected.where((s) => _allItems.any((e) => e.id == s.id)).toList();
    }
  }

  String _display(ComboItem item) =>
      item.field(widget.displayIndex) ?? item.descripcion;

  Future<void> _openPicker() async {
    final result = await showDialog<List<ComboItem>>(
      context: context,
      builder: (_) => _PickerDialog(
        allItems: _allItems,
        selected: List.of(_selected),
        display: _display,
        label: widget.label,
      ),
    );
    if (result != null) {
      setState(() => _selected = result);
      widget.onChanged?.call(_selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = _selected.isNotEmpty;
    return FormField<List<ComboItem>>(
      validator: widget.validator != null ? (_) => widget.validator!(_selected) : null,
      builder: (field) => InkWell(
        onTap: widget.enabled ? _openPicker : null,
        borderRadius: BorderRadius.circular(4),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: hasSelection ? null : (widget.hint ?? 'Seleccione...'),
            border: const OutlineInputBorder(),
            enabled: widget.enabled,
            errorText: field.errorText,
            suffixIcon: const Icon(Icons.arrow_drop_down),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          isEmpty: !hasSelection,
          child: hasSelection
              ? Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: _selected
                      .map((item) => Chip(
                            label: Text(_display(item),
                                style: Theme.of(context).textTheme.bodySmall),
                            deleteIcon: const Icon(Icons.close, size: 14),
                            onDeleted: widget.enabled
                                ? () {
                                    setState(() => _selected.remove(item));
                                    widget.onChanged?.call(_selected);
                                  }
                                : null,
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                          ))
                      .toList(),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _PickerDialog extends StatefulWidget {
  final List<ComboItem> allItems;
  final List<ComboItem> selected;
  final String Function(ComboItem) display;
  final String label;

  const _PickerDialog({
    required this.allItems,
    required this.selected,
    required this.display,
    required this.label,
  });

  @override
  State<_PickerDialog> createState() => _PickerDialogState();
}

class _PickerDialogState extends State<_PickerDialog> {
  late List<ComboItem> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.of(widget.selected);
  }

  void _toggle(ComboItem item) => setState(() =>
      _selected.contains(item) ? _selected.remove(item) : _selected.add(item));

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.label),
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.allItems.length,
          itemBuilder: (_, i) {
            final item = widget.allItems[i];
            return CheckboxListTile(
              dense: true,
              title: Text(widget.display(item)),
              value: _selected.contains(item),
              onChanged: (_) => _toggle(item),
            );
          },
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(onPressed: () => Navigator.pop(context, _selected), child: const Text('Aceptar')),
      ],
    );
  }
}