// lib\core\presentation\widgets\inputs\custom_combo_multi_search_field.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';

class CustomComboMultiSearchField extends StatefulWidget {
  final List<String> data;
  final String separator;
  final int displayIndex;
  final String label;
  final String? hint;
  final List<String> initialValues;
  final void Function(List<ComboItem> items)? onChanged;
  final bool enabled;
  final String? Function(List<ComboItem>)? validator;

  const CustomComboMultiSearchField({
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
  State<CustomComboMultiSearchField> createState() =>
      _CustomComboMultiSearchFieldState();
}

class _CustomComboMultiSearchFieldState
    extends State<CustomComboMultiSearchField> {
  late List<ComboItem> _allItems;
  late List<ComboItem> _selected;

  @override
  void initState() {
    super.initState();
    _allItems = ComboItem.fromList(widget.data, separator: widget.separator);
    _selected = _allItems
        .where((e) => widget.initialValues.contains(e.id))
        .toList();
  }

  @override
  void didUpdateWidget(covariant CustomComboMultiSearchField old) {
    super.didUpdateWidget(old);
    if (old.data != widget.data || old.separator != widget.separator) {
      _allItems = ComboItem.fromList(widget.data, separator: widget.separator);
      _selected = _selected
          .where((s) => _allItems.any((e) => e.id == s.id))
          .toList();
    }
  }

  String _display(ComboItem item) =>
      item.field(widget.displayIndex) ?? item.descripcion;

  Future<void> _openPicker() async {
    final result = await showDialog<List<ComboItem>>(
      context: context,
      builder: (_) => _SearchPickerDialog(
        allItems: _allItems,
        selected: List.of(_selected),
        display: _display,
        label: widget.label,
        hint: widget.hint ?? 'Buscar...',
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
      validator: widget.validator != null
          ? (_) => widget.validator!(_selected)
          : null,
      builder: (field) => InkWell(
        onTap: widget.enabled ? _openPicker : null,
        borderRadius: BorderRadius.circular(AppSizing.radiusXs),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: hasSelection
                ? null
                : (widget.hint ?? 'Buscar y seleccionar...'),
            border: const OutlineInputBorder(),
            enabled: widget.enabled,
            errorText: field.errorText,
            suffixIcon: const Icon(AppIcons.search),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.snackGap,
              vertical: AppSpacing.sm,
            ),
          ),
          isEmpty: !hasSelection,
          child: hasSelection
              ? Wrap(
                  spacing: AppSpacing.chipGap,
                  runSpacing: AppSpacing.xs,
                  children: _selected
                      .map(
                        (item) => Chip(
                          label: Text(
                            _display(item),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          deleteIcon: const Icon(AppIcons.close, size: AppSizing.iconXs),
                          onDeleted: widget.enabled
                              ? () {
                                  setState(() => _selected.remove(item));
                                  widget.onChanged?.call(_selected);
                                }
                              : null,
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                        ),
                      )
                      .toList(),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _SearchPickerDialog extends StatefulWidget {
  final List<ComboItem> allItems;
  final List<ComboItem> selected;
  final String Function(ComboItem) display;
  final String label;
  final String hint;

  const _SearchPickerDialog({
    required this.allItems,
    required this.selected,
    required this.display,
    required this.label,
    required this.hint,
  });

  @override
  State<_SearchPickerDialog> createState() => _SearchPickerDialogState();
}

class _SearchPickerDialogState extends State<_SearchPickerDialog> {
  late List<ComboItem> _selected;
  late List<ComboItem> _filtered;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selected = List.of(widget.selected);
    _filtered = List.of(widget.allItems);
    _searchCtrl.addListener(_filter);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _filter() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? widget.allItems
          : widget.allItems
                .where((e) => widget.display(e).toLowerCase().contains(q))
                .toList();
    });
  }

  void _toggle(ComboItem item) => setState(
    () =>
        _selected.contains(item) ? _selected.remove(item) : _selected.add(item),
  );

  @override
  Widget build(BuildContext context) {
    final allSelected = _filtered.every(_selected.contains);
    return AlertDialog(
      title: Text(widget.label),
      contentPadding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.snackGap, AppSpacing.sm, 0),
      content: SizedBox(
        width: double.maxFinite,
        height: AppSizing.searchDialogContent,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: TextField(
                controller: _searchCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: widget.hint,
                  prefixIcon: const Icon(AppIcons.search, size: AppSizing.iconSearch),
                  suffixIcon: AnimatedBuilder(
                    animation: _searchCtrl,
                    builder: (_, _) => _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(AppIcons.close, size: AppSizing.iconActionSm),
                            onPressed: _searchCtrl.clear,
                          )
                        : const SizedBox.shrink(),
                  ),
                  isDense: true,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                ),
              ),
            ),
            Row(
              children: [
                const SizedBox(width: AppSpacing.snackGap),
                Text(
                  '${_selected.length} seleccionado(s)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() {
                    for (final e in _filtered) {
                      if (!_selected.contains(e)) _selected.add(e);
                    }
                  }),
                  child: Text(
                    allSelected ? 'Todos ✓' : 'Todos',
                    style: AppTextStyles.bodySmall,
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      setState(() => _selected.removeWhere(_filtered.contains)),
                  child: const Text('Ninguno', style: AppTextStyles.bodySmall),
                ),
              ],
            ),
            const Divider(height: AppSizing.hairline),
            Expanded(
              child: _filtered.isEmpty
                  ? const Center(child: Text('Sin resultados'))
                  : ListView.separated(
                      itemCount: _filtered.length,
                      separatorBuilder: (_, _) =>
                          const Divider(height: AppSizing.hairline, indent: AppSpacing.md),
                      itemBuilder: (_, i) {
                        final item = _filtered[i];
                        return CheckboxListTile(
                          dense: true,
                          title: Text(widget.display(item)),
                          value: _selected.contains(item),
                          onChanged: (_) => _toggle(item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _selected),
          child: const Text('Aceptar'),
        ),
      ],
    );
  }
}
