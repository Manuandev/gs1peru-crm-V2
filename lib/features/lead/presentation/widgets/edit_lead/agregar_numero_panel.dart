// lib/features/lead/presentation/widgets/edit_lead/agregar_numero_panel.dart

import 'package:app_crm/index_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_crm/core/index_core.dart';

/// Fila inline para ingresar un número adicional: [selector país] [input número].
/// Se muestra debajo del teléfono principal al pulsar "+".
/// La longitud esperada se deduce del número de ejemplo del país seleccionado.
class AgregarNumeroPanel extends StatefulWidget {
  final VoidCallback onCancelar;
  final void Function(String prefijo, String numero) onAgregar;

  const AgregarNumeroPanel({
    super.key,
    required this.onCancelar,
    required this.onAgregar,
  });

  @override
  State<AgregarNumeroPanel> createState() => _AgregarNumeroPanelState();
}

class _AgregarNumeroPanelState extends State<AgregarNumeroPanel> {
  Country? _pais;
  final _numCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _pais = CountryParser.parseCountryCode('PE');
  }

  @override
  void dispose() {
    _numCtrl.dispose();
    super.dispose();
  }

  void _abrirSelectorPais() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (country) => setState(() {
        _pais = country;
        _formKey.currentState?.validate();
      }),
    );
  }

  // Longitud esperada deducida del número de ejemplo del país (solo dígitos)
  int get _longitudEsperada {
    final ejemplo = (_pais?.example ?? '').replaceAll(RegExp(r'\D'), '');
    return ejemplo.length;
  }

  String? _validarNumero(String? value) {
    final numero = value?.trim() ?? '';
    if (numero.isEmpty) return 'Ingresa el número';

    final longitud = _longitudEsperada;
    if (longitud > 0) {
      if (numero.length < longitud) return 'Mín. $longitud dígitos';
      // +1 de tolerancia para países con longitudes variables
      if (numero.length > longitud + 1) return 'Máx. ${longitud + 1} dígitos';
    } else {
      if (numero.length < 5) return 'Muy corto (mín. 5 dígitos)';
      if (numero.length > 15) return 'Muy largo (máx. 15 dígitos)';
    }
    return null;
  }

  void _agregar() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final numero = _numCtrl.text.trim();
    if (_pais == null) return;
    // TODO: conectar SP de agregar número cuando esté disponible.
    widget.onAgregar('+${_pais!.phoneCode}', numero);
  }

  @override
  Widget build(BuildContext context) {
    final ejemplo = _pais?.example;

    return Form(
      key: _formKey,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SelectorPais(
            pais: _pais,
            onTap: _abrirSelectorPais,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: CustomTextField(
              label: 'Número',
              hint: ejemplo != null && ejemplo.isNotEmpty ? 'Ej: $ejemplo' : null,
              controller: _numCtrl,
              keyboardType: TextInputType.phone,
              dense: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _agregar(),
              validator: _validarNumero,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectorPais extends StatelessWidget {
  final Country? pais;
  final VoidCallback onTap;

  const _SelectorPais({required this.pais, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSizing.radiusMd),
          border: Border.all(color: colorScheme.outline),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (pais != null) ...[
              Text(pais!.flagEmoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '+${pais!.phoneCode}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ] else
              Text(
                'País',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            const SizedBox(width: AppSpacing.xxs),
            Icon(
              AppIcons.forward,
              size: AppSizing.iconSm,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
