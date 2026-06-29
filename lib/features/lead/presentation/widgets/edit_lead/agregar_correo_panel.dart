// lib/features/lead/presentation/widgets/edit_lead/agregar_correo_panel.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';

class AgregarCorreoPanel extends StatefulWidget {
  final VoidCallback onCancelar;
  final void Function(String correo) onAgregar;

  const AgregarCorreoPanel({
    super.key,
    required this.onCancelar,
    required this.onAgregar,
  });

  @override
  State<AgregarCorreoPanel> createState() => _AgregarCorreoPanelState();
}

class _AgregarCorreoPanelState extends State<AgregarCorreoPanel> {
  final _correoCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _correoCtrl.dispose();
    super.dispose();
  }

  String? _validarCorreo(String? value) {
    final correo = value?.trim() ?? '';
    if (correo.isEmpty) return 'Ingresa el correo';
    final regex = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(correo)) return 'Correo no válido';
    return null;
  }

  void _agregar() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    widget.onAgregar(_correoCtrl.text.trim());
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
              label: 'Nuevo correo',
              hint: 'ejemplo@correo.com',
              controller: _correoCtrl,
              keyboardType: TextInputType.emailAddress,
              dense: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _agregar(),
              validator: _validarCorreo,
              prefixIcon: const Icon(AppIcons.email),
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
