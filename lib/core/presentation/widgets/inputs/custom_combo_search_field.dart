// lib/core/presentation/widgets/inputs/custom_combo_search_field.dart

import 'package:flutter/foundation.dart' show listEquals;
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
  // Si no matchea ningún ítem del catálogo, al confirmar (check del teclado)
  // el texto tipeado se manda tal cual como selección — ComboItem con id
  // vacío, descripcion = texto libre. Apagado por defecto (comportamiento
  // estricto de siempre); solo lo activan los campos que lo necesiten
  // (ver Área/Cargo en EditContacto, lead/CLAUDE.md).
  final bool allowFreeText;
  // Solo con [allowFreeText]: valor inicial por TEXTO en vez de por id —
  // usar cuando lo guardado no es un id de catálogo sino el label libre ya
  // tipeado en una sesión anterior. Si el texto matchea un ítem real del
  // catálogo, igual se resuelve como selección normal (conserva el id).
  final String? initialText;

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
    this.allowFreeText = false,
    this.initialText,
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
  // Controller del TextFormField interno de Autocomplete, capturado para
  // engancharle un listener una sola vez (2026-08-12, ver _syncFreeText) —
  // fieldViewBuilder se vuelve a llamar en cada build, así que hay que evitar
  // agregar un listener duplicado por cada rebuild.
  TextEditingController? _boundController;

  @override
  void initState() {
    super.initState();
    _allItems = ComboItem.fromList(widget.data, separator: widget.separator);
    _selected = _resolverInicial();
  }

  ComboItem? _resolverInicial() {
    if (widget.initialValue != null) {
      return _allItems.where((e) => e.id == widget.initialValue).firstOrNull;
    }
    final texto = widget.initialText?.trim() ?? '';
    if (widget.allowFreeText && texto.isNotEmpty) {
      return _allItems.where((e) => _display(e) == texto).firstOrNull ??
          ComboItem(id: '', descripcion: texto);
    }
    return null;
  }

  // Confirma el texto tipeado como selección — matchea contra el catálogo
  // (sin distinguir mayúsculas) si existe, si no lo manda tal cual como
  // texto libre (id vacío). Solo se llama con [allowFreeText] activo.
  //
  // Se dispara en 2 momentos (2026-08-12): en vivo, con cada tecla (vía el
  // listener de _boundController, ver fieldViewBuilder) — así lo que esté
  // escrito en el campo en el momento de "Guardar"/"Siguiente" ya es lo que
  // se guarda, sin depender de que el usuario presione el check del teclado
  // (ej. seleccionó una sugerencia y le agregó una letra más sin confirmar) —
  // y al confirmar con el check (onFieldSubmitted → _commitFreeText), que
  // además cierra el teclado.
  void _syncFreeText(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      if (_selected != null) {
        _selected = null;
        widget.onChanged?.call(null);
      }
      return;
    }
    final match = _allItems
        .where((e) => _display(e).toLowerCase() == trimmed.toLowerCase())
        .firstOrNull;
    final item = match ?? ComboItem(id: '', descripcion: trimmed);
    final sinCambios =
        _selected?.id == item.id && _selected?.descripcion == item.descripcion;
    if (sinCambios) return;
    _selected = item;
    widget.onChanged?.call(item);
  }

  void _commitFreeText(String text) {
    _syncFreeText(text);
    _fieldFocusNode?.unfocus();
  }

  @override
  void didUpdateWidget(covariant CustomComboSearchField old) {
    super.didUpdateWidget(old);
    // listEquals (por contenido) en vez de != (por referencia) — con
    // allowFreeText, el caller típico arma `data` con un .map().toList()
    // dentro de su propio build() (ej. Cargo en solicitudes/), así que
    // llega una instancia nueva en CADA rebuild del padre aunque el
    // contenido no haya cambiado. Comparar por referencia disparaba este
    // bloque en cualquier rebuild ajeno (ej. el setState de "Siguiente"
    // que activa _autovalidar justo antes de validate()) — ver más abajo
    // por qué eso importaba (2026-08-12).
    if (!listEquals(old.data, widget.data) ||
        old.separator != widget.separator) {
      _allItems = ComboItem.fromList(widget.data, separator: widget.separator);
      // Solo resetea si `_selected` venía de un id REAL del catálogo que ya
      // no está en la lista nueva. Con allowFreeText, una selección de
      // texto libre confirmada tiene `id: ''` a propósito (ver
      // _syncFreeText) — ningún ítem real del catálogo matchea un id
      // vacío, así que sin este guard CUALQUIER rebuild del padre borraba
      // el texto libre ya confirmado (`_selected = null`), y el validator
      // volvía a marcar "Requerido" pese a que el campo seguía mostrando
      // el texto tipeado (bug real, Cargo de solicitudes/, 2026-08-12).
      if (_selected != null &&
          _selected!.id.isNotEmpty &&
          !_allItems.any((e) => e.id == _selected!.id)) {
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
        if (widget.allowFreeText && _boundController != controller) {
          _boundController = controller;
          controller.addListener(() => _syncFreeText(controller.text));
        }
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
          textInputAction: widget.allowFreeText ? TextInputAction.done : null,
          onFieldSubmitted: widget.allowFreeText ? _commitFreeText : null,
          // Con allowFreeText, una selección de texto libre confirmada tiene
          // id vacío a propósito (ComboItem(id: '', descripcion: texto), ver
          // _commitFreeText) — validar por id ahí siempre marcaría "Requerido"
          // aunque el asesor sí haya tipeado y confirmado algo. Sin
          // allowFreeText, el id sigue siendo lo correcto a validar (solo
          // existen selecciones reales del catálogo).
          validator: widget.validator != null
              ? (_) => widget.validator!(
                  widget.allowFreeText ? _selected?.descripcion : _selected?.id,
                )
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
