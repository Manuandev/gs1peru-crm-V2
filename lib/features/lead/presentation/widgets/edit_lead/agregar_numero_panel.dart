// lib/features/lead/presentation/widgets/edit_lead/agregar_numero_panel.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_crm/core/index_core.dart';

// Prefijos de país disponibles para selección de número.
class _PrefijoPais with Comboable {
  final String codigo;
  final String pais;
  const _PrefijoPais({required this.codigo, required this.pais});

  @override
  List<dynamic> get fields => [codigo, '$codigo  $pais'];
}

const _prefijosDisponibles = [
  _PrefijoPais(codigo: '+51',  pais: 'Perú'),
  _PrefijoPais(codigo: '+1',   pais: 'USA'),
  _PrefijoPais(codigo: '+57',  pais: 'Colombia'),
  _PrefijoPais(codigo: '+54',  pais: 'Argentina'),
  _PrefijoPais(codigo: '+56',  pais: 'Chile'),
  _PrefijoPais(codigo: '+52',  pais: 'México'),
  _PrefijoPais(codigo: '+593', pais: 'Ecuador'),
  _PrefijoPais(codigo: '+55',  pais: 'Brasil'),
  _PrefijoPais(codigo: '+34',  pais: 'España'),
];

/// Panel inline para agregar un número de teléfono al lead.
/// Gestiona internamente el prefijo y el número ingresado.
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
  _PrefijoPais? _prefijo = _prefijosDisponibles.first;
  final _numCtrl = TextEditingController();

  @override
  void dispose() {
    _numCtrl.dispose();
    super.dispose();
  }

  void _agregar() {
    final numero = _numCtrl.text.trim();
    if (numero.isEmpty || _prefijo == null) return;
    // TODO: conectar SP de agregar número cuando esté disponible.
    widget.onAgregar(_prefijo!.codigo, numero);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color:        AppColors.surfaceLightVariant,
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        border:       Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nuevo número',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 130,
                child: CustomComboField<_PrefijoPais>(
                  data:         _prefijosDisponibles,
                  label:        'Prefijo',
                  initialValue: _prefijo?.codigo,
                  onChanged:    (item) => setState(() => _prefijo = item),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: CustomTextField(
                  label:        'Número',
                  controller:   _numCtrl,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Spacer(),
              CustomOutlinedButton(
                text:      'Cancelar',
                height:    AppSizing.buttonHeightSmall,
                onPressed: widget.onCancelar,
              ),
              const SizedBox(width: AppSpacing.sm),
              CustomPrimaryButton(
                text:      'Agregar',
                height:    AppSizing.buttonHeightSmall,
                onPressed: _agregar,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
