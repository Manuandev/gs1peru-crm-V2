// lib/features/lead/presentation/widgets/edit_lead/agregar_empresa_panel.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';

class AgregarEmpresaPanel extends StatefulWidget {
  final VoidCallback onCancelar;
  final void Function(String nombre) onAgregar;

  const AgregarEmpresaPanel({
    super.key,
    required this.onCancelar,
    required this.onAgregar,
  });

  @override
  State<AgregarEmpresaPanel> createState() => _AgregarEmpresaPanelState();
}

class _AgregarEmpresaPanelState extends State<AgregarEmpresaPanel> {
  final _nombreCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nombreCtrl.dispose();
    super.dispose();
  }

  String? _validarNombre(String? value) {
    final nombre = value?.trim() ?? '';
    if (nombre.isEmpty) return 'Ingresa el nombre de la empresa';
    if (nombre.length < 2) return 'Mínimo 2 caracteres';
    return null;
  }

  void _agregar() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    widget.onAgregar(_nombreCtrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: CustomTextField(
              label: 'Nueva empresa',
              controller: _nombreCtrl,
              textCapitalization: TextCapitalization.words,
              dense: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _agregar(),
              validator: _validarNombre,
              prefixIcon: const Icon(AppIcons.business),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          _BtnAgregar(onTap: _agregar),
        ],
      ),
    );
  }
}

class _BtnAgregar extends StatelessWidget {
  final VoidCallback onTap;
  const _BtnAgregar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizing.radiusCircular),
      child: Container(
        margin: const EdgeInsets.only(top: AppSpacing.xs),
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colorScheme.primary,
        ),
        child: Icon(
          AppIcons.check,
          size: AppSizing.iconActionSm,
          color: colorScheme.onPrimary,
        ),
      ),
    );
  }
}
