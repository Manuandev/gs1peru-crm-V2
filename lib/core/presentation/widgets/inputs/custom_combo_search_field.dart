// lib/core/presentation/widgets/inputs/custom_combo_search_field.dart

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
  // Capturado en fieldViewBuilder — se usa en onSelected para quitar el foco
  // y cerrar el teclado al tocar una coincidencia de la lista (2026-07-22).
  // Antes el foco se quedaba en el campo tras elegir una opción.
  FocusNode? _fieldFocusNode;

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

  InputDecoration _buildDecoration(
    BuildContext context,
    TextEditingController controller,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    // ignore: deprecated_member_use
    final disabledColor = Theme.of(context).disabledColor.withOpacity(0.4);

    return InputDecoration(
      labelText: widget.label,
      hintText: widget.hint,
      labelStyle: const TextStyle(
        fontSize: AppTextStyles.sizeXs,
        color: AppColors.textSecondary,
      ),
      hintStyle: const TextStyle(
        fontSize: AppTextStyles.sizeXs,
        color: AppColors.textDisabled,
      ),
      floatingLabelStyle: const TextStyle(
        fontSize: AppTextStyles.sizeXs,
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm2,
      ),
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
        borderSide: BorderSide(color: disabledColor),
      ),
      suffixIconConstraints: const BoxConstraints(maxHeight: 38, maxWidth: 36),
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
    );
  }

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
        // Quita el foco y cierra el teclado al elegir una coincidencia —
        // ya terminaste de buscar, no hace falta que el campo se quede
        // activo (2026-07-22).
        _fieldFocusNode?.unfocus();
      },
      fieldViewBuilder: (context, controller, focusNode, _) {
        _fieldFocusNode = focusNode;
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          enabled: widget.enabled,
          style: AppTextStyles.inputTextCompact.copyWith(
            color: widget.enabled
                ? AppColors.textPrimary
                : AppColors.textSecondary,
          ),
          decoration: _buildDecoration(context, controller),
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
                    style: AppTextStyles.inputTextCompact,
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
