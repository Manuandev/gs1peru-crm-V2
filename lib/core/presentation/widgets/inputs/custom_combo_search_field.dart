// lib\core\presentation\widgets\inputs\custom_combo_search_field.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';

class CustomComboSearchField extends StatefulWidget {
  final List<String> data;
  final String separator;
  final int displayIndex;
  final String label;
  final String? hint;
  final String? initialValue;
  final void Function(ComboItem? item)? onChanged;
  final bool enabled;
  final String? Function(String?)? validator;
  final int maxSuggestions;

  const CustomComboSearchField({
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
    this.maxSuggestions = 6,
  });

  @override
  State<CustomComboSearchField> createState() => _CustomComboSearchFieldState();
}

class _CustomComboSearchFieldState extends State<CustomComboSearchField> {
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
  void didUpdateWidget(covariant CustomComboSearchField old) {
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
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            border: const OutlineInputBorder(),
            suffixIcon: AnimatedBuilder(
              animation: controller,
              builder: (_, _) => controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(AppIcons.close, size: AppSizing.iconActionSm),
                      onPressed: () {
                        controller.clear();
                        _selected = null;
                        widget.onChanged?.call(null);
                      },
                    )
                  : const Icon(AppIcons.search, size: AppSizing.iconActionSm),
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
              separatorBuilder: (_, _) => const Divider(height: AppSizing.hairline, indent: AppSpacing.md),
              itemBuilder: (_, i) {
                final item = options.elementAt(i);
                return ListTile(
                  dense: true,
                  title: Text(_display(item)),
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
