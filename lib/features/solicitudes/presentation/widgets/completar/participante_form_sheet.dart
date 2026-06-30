// lib/features/solicitudes/presentation/widgets/completar/participante_form_sheet.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/presentation/bloc/participantes/participantes_cubit.dart';
import 'package:app_crm/features/solicitudes/presentation/widgets/completar/solicitud_inputs.dart';

// ── Constantes de opciones ────────────────────────────────────────────────────

const _tiposDoc = ['DNI', 'PASAPORTE', 'CE', 'RUC'];
const _tiposPago = ['Pagante', 'Cortesía'];

// ── Función helper para abrir el sheet ───────────────────────────────────────

Future<void> mostrarFormularioParticipante(
  BuildContext context, {
  ParticipanteLocal? participante,
  required void Function(ParticipanteLocal) onGuardar,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ParticipanteFormSheet(
      participante: participante,
      onGuardar: onGuardar,
    ),
  );
}

// ── Widget del formulario ─────────────────────────────────────────────────────

class _ParticipanteFormSheet extends StatefulWidget {
  final ParticipanteLocal? participante;
  final void Function(ParticipanteLocal) onGuardar;

  const _ParticipanteFormSheet({
    required this.participante,
    required this.onGuardar,
  });

  @override
  State<_ParticipanteFormSheet> createState() => _ParticipanteFormSheetState();
}

class _ParticipanteFormSheetState extends State<_ParticipanteFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late String _tipoDoc;
  late String _tipoPago;

  late final TextEditingController _numDocCtrl;
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _celularCtrl;
  late final TextEditingController _nacionalidadCtrl;
  late final TextEditingController _correoCtrl;
  late final TextEditingController _cargoCtrl;
  late final TextEditingController _precioCtrl;

  bool get _esEdicion => widget.participante != null;

  @override
  void initState() {
    super.initState();
    final p = widget.participante;
    _tipoDoc = p?.tipoDoc ?? _tiposDoc.first;
    _tipoPago = p?.tipoPago ?? _tiposPago.first;
    _numDocCtrl = TextEditingController(text: p?.numDoc ?? '');
    _nombreCtrl = TextEditingController(text: p?.nombre ?? '');
    _celularCtrl = TextEditingController(text: p?.celular ?? '');
    _nacionalidadCtrl = TextEditingController(text: p?.nacionalidad ?? '');
    _correoCtrl = TextEditingController(text: p?.correo ?? '');
    _cargoCtrl = TextEditingController(text: p?.cargo ?? '');
    _precioCtrl = TextEditingController(
      text: p?.precio != null && p!.precio > 0
          ? p.precio.toStringAsFixed(2)
          : '',
    );
  }

  @override
  void dispose() {
    _numDocCtrl.dispose();
    _nombreCtrl.dispose();
    _celularCtrl.dispose();
    _nacionalidadCtrl.dispose();
    _correoCtrl.dispose();
    _cargoCtrl.dispose();
    _precioCtrl.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;

    final precio = _tipoPago == 'Cortesía'
        ? 0.0
        : double.tryParse(_precioCtrl.text.trim()) ?? 0.0;

    final resultado = ParticipanteLocal(
      id: widget.participante?.id ?? 0,
      tipoDoc: _tipoDoc,
      numDoc: _numDocCtrl.text.trim().toUpperCase(),
      nombre: _nombreCtrl.text.trim().toUpperCase(),
      celular: _celularCtrl.text.trim(),
      nacionalidad: _nacionalidadCtrl.text.trim().toUpperCase(),
      correo: _correoCtrl.text.trim(),
      cargo: _cargoCtrl.text.trim().toUpperCase(),
      tipoPago: _tipoPago,
      precio: precio,
    );

    widget.onGuardar(resultado);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSizing.radiusXl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Pill indicador ──────────────────────────────────────
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(AppSizing.radiusCircular),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Header ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.primaryWithOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizing.radiusSm),
                  ),
                  child: const Icon(
                    AppIcons.user,
                    color: AppColors.primary,
                    size: AppSizing.iconMd,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  _esEdicion ? 'Editar participante' : 'Nuevo participante',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: AppTextStyles.weightBold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    AppIcons.close,
                    size: AppSizing.iconMd,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // ── Formulario scrollable ───────────────────────────────
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: AppSpacing.md,
                right: AppSpacing.md,
                top: AppSpacing.md,
                bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.md,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Tipo doc + N° doc
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 110,
                          child: SolicitudComboField(
                            label: 'Tipo doc.',
                            data: _tiposDoc,
                            displayIndex: 0,
                            initialValue: _tipoDoc,
                            onChanged: (item) {
                              if (item != null) {
                                setState(() => _tipoDoc = item.id);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: SolicitudTextField(
                            label: 'N° documento *',
                            controller: _numDocCtrl,
                            isUpperCase: true,
                            keyboardType: TextInputType.text,
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Requerido'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Nombre completo
                    SolicitudTextField(
                      label: 'Nombre completo *',
                      controller: _nombreCtrl,
                      isUpperCase: true,
                      textCapitalization: TextCapitalization.characters,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Celular + Nacionalidad
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SolicitudTextField(
                            label: 'Celular *',
                            controller: _celularCtrl,
                            keyboardType: TextInputType.phone,
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Requerido'
                                : null,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: SolicitudTextField(
                            label: 'Nacionalidad *',
                            controller: _nacionalidadCtrl,
                            isUpperCase: true,
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Requerido'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Correo
                    SolicitudTextField(
                      label: 'Correo electrónico *',
                      controller: _correoCtrl,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Requerido';
                        if (!v.contains('@')) return 'Email inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Cargo
                    SolicitudTextField(
                      label: 'Cargo *',
                      controller: _cargoCtrl,
                      isUpperCase: true,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Tipo pago + Precio
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 120,
                          child: SolicitudComboField(
                            label: 'Tipo pago',
                            data: _tiposPago,
                            displayIndex: 0,
                            initialValue: _tipoPago,
                            onChanged: (item) {
                              if (item != null) {
                                setState(() {
                                  _tipoPago = item.id;
                                  if (_tipoPago == 'Cortesía') {
                                    _precioCtrl.clear();
                                  }
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: SolicitudTextField(
                            label: 'Precio (USD)',
                            controller: _precioCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            enabled: _tipoPago != 'Cortesía',
                            validator: (v) {
                              if (_tipoPago == 'Cortesía') return null;
                              if (v == null || v.trim().isEmpty) {
                                return 'Requerido';
                              }
                              if (double.tryParse(v.trim()) == null) {
                                return 'Número inválido';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // ── Botones ─────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textSecondary,
                              side: const BorderSide(color: AppColors.border),
                              minimumSize: const Size.fromHeight(
                                AppSizing.buttonHeightSmall,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppSizing.radiusMd,
                                ),
                              ),
                            ),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _guardar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.textOnDark,
                              minimumSize: const Size.fromHeight(
                                AppSizing.buttonHeightSmall,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppSizing.radiusMd,
                                ),
                              ),
                            ),
                            child: Text(_esEdicion ? 'Guardar' : 'Crear'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
  }
}

