// lib/features/lead/presentation/widgets/edit_lead/edit_lead_contacto_section.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';

class EditLeadContactoSection extends StatefulWidget {
  final TextEditingController nombreCtrl;
  final TextEditingController apellidoPCtrl;
  final TextEditingController apellidoMCtrl;
  final TextEditingController empresaCtrl; // editable — actualiza empresa existente
  final TextEditingController correoCtrl;  // editable — actualiza correo existente
  final TextEditingController cargoCtrl;   // solo lectura — SP de guardado aún no lo soporta
  final String telefonoPrefijo;
  final String telefonoNumero;
  final bool isLoading;
  final VoidCallback? onChanged; // notifica al padre para el botón guardar

  const EditLeadContactoSection({
    super.key,
    required this.nombreCtrl,
    required this.apellidoPCtrl,
    required this.apellidoMCtrl,
    required this.empresaCtrl,
    required this.correoCtrl,
    required this.cargoCtrl,
    required this.telefonoPrefijo,
    required this.telefonoNumero,
    required this.isLoading,
    this.onChanged,
  });

  @override
  State<EditLeadContactoSection> createState() => EditLeadContactoSectionState();
}

class EditLeadContactoSectionState extends State<EditLeadContactoSection> {
  // ── Límites configurables ─────────────────────────────────────────────────
  // Cambiar estos valores para permitir más entradas simultáneas
  // static const int _maxNuevasEmpresas = 1; // ← aumentar para más empresas
  // static const int _maxNuevosCorreos  = 1; // ← aumentar para más correos
  // static const int _maxNuevosTels     = 1; // ← aumentar para más teléfonos

  // ── Listas de nuevos items ────────────────────────────────────────────────
  final List<TextEditingController> _nuevasEmpresasCtrl = [];
  final List<TextEditingController> _nuevosCorreosCtrl  = [];
  final List<Country?>              _nuevosTelPaises    = [];
  final List<TextEditingController> _nuevosTelNumCtrl   = [];

  @override
  void dispose() {
    for (final c in _nuevasEmpresasCtrl) c.dispose();
    for (final c in _nuevosCorreosCtrl)  c.dispose();
    for (final c in _nuevosTelNumCtrl)   c.dispose();
    super.dispose();
  }

  // ── Getters para el portrait (valores a enviar al SP) ─────────────────────

  /// Nuevas empresas separadas por ± — vacío si no hay
  String get nuevasEmpresasStr => _nuevasEmpresasCtrl
      .map((c) => c.text.trim())
      .where((s) => s.isNotEmpty)
      .join(AppConstants.sepComodin2);

  /// Nuevos correos separados por ± — vacío si no hay
  String get nuevosCorreosStr => _nuevosCorreosCtrl
      .map((c) => c.text.trim())
      .where((s) => s.isNotEmpty)
      .join(AppConstants.sepComodin2);

  /// Prefijos de nuevos teléfonos separados por ± — vacío si no hay
  String get nuevosPrefijosStr {
    final r = <String>[];
    for (int i = 0; i < _nuevosTelNumCtrl.length; i++) {
      if (_nuevosTelNumCtrl[i].text.trim().isNotEmpty && _nuevosTelPaises[i] != null) {
        r.add('+${_nuevosTelPaises[i]!.phoneCode}');
      }
    }
    return r.join(AppConstants.sepComodin2);
  }

  /// Números de nuevos teléfonos separados por ± — vacío si no hay
  String get nuevosNumerosStr {
    final r = <String>[];
    for (int i = 0; i < _nuevosTelNumCtrl.length; i++) {
      if (_nuevosTelNumCtrl[i].text.trim().isNotEmpty && _nuevosTelPaises[i] != null) {
        r.add(_nuevosTelNumCtrl[i].text.trim());
      }
    }
    return r.join(AppConstants.sepComodin2);
  }

  // TODO(mejora): unificar en un solo getter nuevosTelefonosStr con formato +51¶999000001±+1¶987654321
  // donde ¶ (sepComodin3) separa prefijo/número y ± (sepComodin2) separa entradas.
  // Requiere actualizar el SP para usar fnSplitStringTable05(@TELEFONOS_STR, @sepComodin2, @sepComodin3).
  // String get nuevosTelefonosStr {
  //   final r = <String>[];
  //   for (int i = 0; i < _nuevosTelNumCtrl.length; i++) {
  //     final num  = _nuevosTelNumCtrl[i].text.trim();
  //     final pais = _nuevosTelPaises[i];
  //     if (num.isNotEmpty && pais != null) {
  //       r.add('+${pais.phoneCode}${AppConstants.sepComodin3}$num');
  //     }
  //   }
  //   return r.join(AppConstants.sepComodin2);
  // }

  /// True si hay al menos un nuevo item con valor
  bool get tieneNuevos =>
      _nuevasEmpresasCtrl.any((c) => c.text.isNotEmpty) ||
      _nuevosCorreosCtrl.any((c) => c.text.isNotEmpty) ||
      _nuevosTelNumCtrl.any((c) => c.text.isNotEmpty);

  // ── Lógica del botón "+" ──────────────────────────────────────────────────

  // bool get _puedeAgregarEmpresa =>
  //     _nuevasEmpresasCtrl.length < _maxNuevasEmpresas &&
  //     (_nuevasEmpresasCtrl.isEmpty || _nuevasEmpresasCtrl.last.text.trim().isNotEmpty);

  // bool get _puedeAgregarCorreo =>
  //     _nuevosCorreosCtrl.length < _maxNuevosCorreos &&
  //     (_nuevosCorreosCtrl.isEmpty || _nuevosCorreosCtrl.last.text.trim().isNotEmpty);

  // bool get _puedeAgregarTel =>
  //     _nuevosTelNumCtrl.length < _maxNuevosTels &&
  //     (_nuevosTelNumCtrl.isEmpty || _nuevosTelNumCtrl.last.text.trim().isNotEmpty);

  // // ── Acciones ──────────────────────────────────────────────────────────────

  // void _addEmpresa() {
  //   final ctrl = TextEditingController();
  //   ctrl.addListener(() { setState(() {}); widget.onChanged?.call(); });
  //   setState(() => _nuevasEmpresasCtrl.add(ctrl));
  //   widget.onChanged?.call();
  // }

  // void _removeEmpresa(int i) {
  //   _nuevasEmpresasCtrl[i].dispose();
  //   setState(() => _nuevasEmpresasCtrl.removeAt(i));
  //   widget.onChanged?.call();
  // }

  // void _addCorreo() {
  //   final ctrl = TextEditingController();
  //   ctrl.addListener(() { setState(() {}); widget.onChanged?.call(); });
  //   setState(() => _nuevosCorreosCtrl.add(ctrl));
  //   widget.onChanged?.call();
  // }

  // void _removeCorreo(int i) {
  //   _nuevosCorreosCtrl[i].dispose();
  //   setState(() => _nuevosCorreosCtrl.removeAt(i));
  //   widget.onChanged?.call();
  // }

  // void _addTelefono() {
  //   final ctrl = TextEditingController();
  //   ctrl.addListener(() { setState(() {}); widget.onChanged?.call(); });
  //   setState(() {
  //     _nuevosTelPaises.add(CountryParser.parseCountryCode('PE'));
  //     _nuevosTelNumCtrl.add(ctrl);
  //   });
  //   widget.onChanged?.call();
  // }

  // void _removeTelefono(int i) {
  //   _nuevosTelNumCtrl[i].dispose();
  //   setState(() {
  //     _nuevosTelPaises.removeAt(i);
  //     _nuevosTelNumCtrl.removeAt(i);
  //   });
  //   widget.onChanged?.call();
  // }

  // void _selectPais(int i) {
  //   showCountryPicker(
  //     context: context,
  //     showPhoneCode: true,
  //     onSelect: (c) => setState(() => _nuevosTelPaises[i] = c),
  //   );
  // }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormSectionTitle('Información del contacto'),
        const SizedBox(height: AppSpacing.md),

        // ── Nombres ───────────────────────────────────────────────────────
        CustomTextField(
          label: 'Nombres',
          controller: widget.nombreCtrl,
          enabled: !widget.isLoading,
          prefixIcon: const Icon(AppIcons.user),
          textCapitalization: TextCapitalization.words,
          dense: true,
        ),
        const SizedBox(height: AppSpacing.sm),

        FormFieldRow(
          izquierdo: CustomTextField(
            label: 'Apellido Paterno',
            controller: widget.apellidoPCtrl,
            enabled: !widget.isLoading,
            textCapitalization: TextCapitalization.words,
            dense: true,
          ),
          derecho: CustomTextField(
            label: 'Apellido Materno',
            controller: widget.apellidoMCtrl,
            enabled: !widget.isLoading,
            textCapitalization: TextCapitalization.words,
            dense: true,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // ── Empresa (solo lectura por ahora) ─────────────────────────────
        // TODO: habilitar edición + botón "+" cuando el SP esté listo
        // _CampoConAgregar(
        //   child: CustomTextField(
        //     label: 'Empresa',
        //     controller: widget.empresaCtrl,
        //     enabled: !widget.isLoading,
        //     prefixIcon: const Icon(AppIcons.business),
        //     textCapitalization: TextCapitalization.words,
        //     dense: true,
        //   ),
        //   puedeAgregar: !widget.isLoading && _puedeAgregarEmpresa,
        //   onAgregar: _addEmpresa,
        // ),
        // for (int i = 0; i < _nuevasEmpresasCtrl.length; i++) ...[
        //   const SizedBox(height: AppSpacing.xs),
        //   _FilaNueva(
        //     child: CustomTextField(
        //       label: 'Nueva empresa',
        //       controller: _nuevasEmpresasCtrl[i],
        //       enabled: !widget.isLoading,
        //       prefixIcon: const Icon(AppIcons.business),
        //       textCapitalization: TextCapitalization.words,
        //       dense: true,
        //     ),
        //     onRemove: () => _removeEmpresa(i),
        //   ),
        // ],
        CustomTextField(
          label: 'Empresa',
          controller: widget.empresaCtrl,
          enabled: false,
          prefixIcon: const Icon(AppIcons.business),
          dense: true,
        ),

        const SizedBox(height: AppSpacing.sm),

        // ── Cargo (solo lectura — el SP de guardado aún no lo soporta) ────
        CustomTextField(
          label: 'Cargo',
          controller: widget.cargoCtrl,
          enabled: false,
          prefixIcon: const Icon(AppIcons.documento),
          dense: true,
        ),
        const SizedBox(height: AppSpacing.sm),

        // ── Teléfono (solo lectura por ahora) ────────────────────────────
        // TODO: habilitar botón "+" cuando el SP esté listo
        // _CampoConAgregar(
        //   child: CustomTextField(
        //     label: 'Teléfono',
        //     controller: TextEditingController(
        //       text: '${widget.telefonoPrefijo} ${widget.telefonoNumero}',
        //     ),
        //     enabled: false,
        //     prefixIcon: const Icon(AppIcons.phone),
        //     dense: true,
        //   ),
        //   puedeAgregar: !widget.isLoading && _puedeAgregarTel,
        //   onAgregar: _addTelefono,
        // ),
        // for (int i = 0; i < _nuevosTelNumCtrl.length; i++) ...[
        //   const SizedBox(height: AppSpacing.xs),
        //   _FilaNuevaTelefono(
        //     pais: _nuevosTelPaises[i],
        //     numCtrl: _nuevosTelNumCtrl[i],
        //     isLoading: widget.isLoading,
        //     onSelectPais: () => _selectPais(i),
        //     onRemove: () => _removeTelefono(i),
        //   ),
        // ],
        CustomTextField(
          label: 'Teléfono',
          controller: TextEditingController(
            text: '${widget.telefonoPrefijo} ${widget.telefonoNumero}',
          ),
          enabled: false,
          prefixIcon: const Icon(AppIcons.phone),
          dense: true,
        ),

        const SizedBox(height: AppSpacing.sm),

        // ── Correo (solo lectura por ahora) ──────────────────────────────
        // TODO: habilitar edición + botón "+" cuando el SP esté listo
        // _CampoConAgregar(
        //   child: CustomTextField(
        //     label: 'Correo',
        //     controller: widget.correoCtrl,
        //     enabled: !widget.isLoading,
        //     prefixIcon: const Icon(AppIcons.email),
        //     keyboardType: TextInputType.emailAddress,
        //     dense: true,
        //   ),
        //   puedeAgregar: !widget.isLoading && _puedeAgregarCorreo,
        //   onAgregar: _addCorreo,
        // ),
        // for (int i = 0; i < _nuevosCorreosCtrl.length; i++) ...[
        //   const SizedBox(height: AppSpacing.xs),
        //   _FilaNueva(
        //     child: CustomTextField(
        //       label: 'Nuevo correo',
        //       hint: 'ejemplo@correo.com',
        //       controller: _nuevosCorreosCtrl[i],
        //       enabled: !widget.isLoading,
        //       prefixIcon: const Icon(AppIcons.email),
        //       keyboardType: TextInputType.emailAddress,
        //       dense: true,
        //     ),
        //     onRemove: () => _removeCorreo(i),
        //   ),
        // ],
        CustomTextField(
          label: 'Correo',
          controller: widget.correoCtrl,
          enabled: false,
          prefixIcon: const Icon(AppIcons.email),
          dense: true,
        ),
      ],
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────

/// Campo existente + botón "+"
// class _CampoConAgregar extends StatelessWidget {
//   final Widget child;
//   final bool puedeAgregar;
//   final VoidCallback onAgregar;

//   const _CampoConAgregar({
//     required this.child,
//     required this.puedeAgregar,
//     required this.onAgregar,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Expanded(child: child),
//         const SizedBox(width: AppSpacing.xs),
//         _BtnAgregar(enabled: puedeAgregar, onTap: onAgregar),
//       ],
//     );
//   }
// }

// /// Fila de nuevo item con "x" para eliminar
// class _FilaNueva extends StatelessWidget {
//   final Widget child;
//   final VoidCallback onRemove;

//   const _FilaNueva({required this.child, required this.onRemove});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Expanded(child: child),
//         const SizedBox(width: AppSpacing.xs),
//         _BtnEliminar(onTap: onRemove),
//       ],
//     );
//   }
// }

// /// Fila de nuevo teléfono: [selector país] [número] [x]
// class _FilaNuevaTelefono extends StatelessWidget {
//   final Country? pais;
//   final TextEditingController numCtrl;
//   final bool isLoading;
//   final VoidCallback onSelectPais;
//   final VoidCallback onRemove;

//   const _FilaNuevaTelefono({
//     required this.pais,
//     required this.numCtrl,
//     required this.isLoading,
//     required this.onSelectPais,
//     required this.onRemove,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final cs = Theme.of(context).colorScheme;
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         GestureDetector(
//           onTap: isLoading ? null : onSelectPais,
//           child: Container(
//             height: 42,
//             padding: const EdgeInsets.symmetric(
//               horizontal: AppSpacing.sm,
//               vertical: AppSpacing.xs,
//             ),
//             decoration: BoxDecoration(
//               color: cs.surface,
//               borderRadius: BorderRadius.circular(AppSizing.radiusMd),
//               border: Border.all(color: cs.outline),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 if (pais != null) ...[
//                   Text(pais!.flagEmoji, style: const TextStyle(fontSize: 18)),
//                   const SizedBox(width: AppSpacing.xs),
//                   Text(
//                     '+${pais!.phoneCode}',
//                     style: AppTextStyles.bodyMedium.copyWith(color: cs.onSurface),
//                   ),
//                 ] else
//                   Text('País', style: AppTextStyles.bodyMedium.copyWith(color: cs.onSurfaceVariant)),
//                 const SizedBox(width: AppSpacing.xxs),
//                 Icon(AppIcons.forward, size: AppSizing.iconSm, color: cs.onSurfaceVariant),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(width: AppSpacing.xs),
//         Expanded(
//           child: CustomTextField(
//             label: 'Número',
//             controller: numCtrl,
//             enabled: !isLoading,
//             keyboardType: TextInputType.phone,
//             dense: true,
//             inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//           ),
//         ),
//         const SizedBox(width: AppSpacing.xs),
//         _BtnEliminar(onTap: onRemove),
//       ],
//     );
//   }
// }

// class _BtnAgregar extends StatelessWidget {
//   final bool enabled;
//   final VoidCallback onTap;
//   const _BtnAgregar({required this.enabled, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     final cs = Theme.of(context).colorScheme;
//     final color = enabled ? cs.primary : cs.outline;
//     return InkWell(
//       onTap: enabled ? onTap : null,
//       borderRadius: BorderRadius.circular(AppSizing.radiusCircular),
//       child: Container(
//         padding: const EdgeInsets.all(AppSpacing.xs),
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           border: Border.all(color: color, width: AppSizing.hairline),
//         ),
//         child: Icon(AppIcons.add, size: AppSizing.iconActionSm, color: color),
//       ),
//     );
//   }
// }

// class _BtnEliminar extends StatelessWidget {
//   final VoidCallback onTap;
//   const _BtnEliminar({required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     final cs = Theme.of(context).colorScheme;
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(AppSizing.radiusCircular),
//       child: Container(
//         padding: const EdgeInsets.all(AppSpacing.xs),
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           border: Border.all(color: cs.error, width: AppSizing.hairline),
//         ),
//         child: Icon(AppIcons.close, size: AppSizing.iconActionSm, color: cs.error),
//       ),
//     );
//   }
// }
