// lib/features/solicitudes/presentation/widgets/completar/participante_form_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/presentation/bloc/participantes/participantes_cubit.dart';
import 'package:app_crm/features/solicitudes/presentation/widgets/completar/solicitud_inputs.dart';

// ── Constantes de opciones ────────────────────────────────────────────────────
// "Tipo" de participante no tiene catálogo de backend — se mantiene hardcodeado.

const _tiposParticipante = ['Pagante', 'Invitado', 'Invitado auspicio', 'Online'];

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

  String _tipoDocLabel = '';
  String? _tipoDocInicialId;
  String _nacionalidadLabel = '';
  String? _nacionalidadInicialId;
  late String _tipoParticipante;
  PaisItem? _paisSeleccionado;

  late final TextEditingController _numDocCtrl;
  late final TextEditingController _nombresCtrl;
  late final TextEditingController _apellidoPaternoCtrl;
  late final TextEditingController _apellidoMaternoCtrl;
  late final TextEditingController _correoCtrl;
  late final TextEditingController _cargoCtrl;
  late final TextEditingController _celularCtrl;
  late final TextEditingController _importeCtrl;

  bool get _esEdicion => widget.participante != null;

  @override
  void initState() {
    super.initState();
    final p = widget.participante;
    _tipoParticipante = p?.tipoParticipante ?? _tiposParticipante.first;
    _tipoDocLabel = p?.tipoDoc ?? '';
    _nacionalidadLabel = p?.nacionalidad ?? '';

    final catalogState = context.read<CatalogsBloc>().state;
    if (catalogState is CatalogsLoaded) {
      _tipoDocInicialId = catalogState.tiposDocumento
          .where((t) => t.nombre == _tipoDocLabel)
          .firstOrNull
          ?.id;
      _nacionalidadInicialId = catalogState.nacionalidades
          .where((n) => n.nombre == _nacionalidadLabel)
          .firstOrNull
          ?.id;
      final paises = catalogState.paises;
      _paisSeleccionado = (p != null && p.celularCodigoTelefono.isNotEmpty)
          ? paises
                .where((x) => x.codigoTelefono == p.celularCodigoTelefono)
                .firstOrNull
          : null;
      _paisSeleccionado ??= paises.isEmpty
          ? null
          : paises.where((x) => x.codigoTelefono == '51').firstOrNull ??
                paises.first;
    }

    _numDocCtrl = TextEditingController(text: p?.numDoc ?? '');
    _nombresCtrl = TextEditingController(text: p?.nombres ?? '');
    _apellidoPaternoCtrl = TextEditingController(
      text: p?.apellidoPaterno ?? '',
    );
    _apellidoMaternoCtrl = TextEditingController(
      text: p?.apellidoMaterno ?? '',
    );
    _correoCtrl = TextEditingController(text: p?.correo ?? '');
    _cargoCtrl = TextEditingController(text: p?.cargo ?? '');
    _celularCtrl = TextEditingController(text: p?.celular ?? '');
    _importeCtrl = TextEditingController(
      text: p != null && p.importe > 0 ? p.importe.toStringAsFixed(2) : '',
    );
  }

  @override
  void dispose() {
    _numDocCtrl.dispose();
    _nombresCtrl.dispose();
    _apellidoPaternoCtrl.dispose();
    _apellidoMaternoCtrl.dispose();
    _correoCtrl.dispose();
    _cargoCtrl.dispose();
    _celularCtrl.dispose();
    _importeCtrl.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;

    final importe = double.tryParse(_importeCtrl.text.trim()) ?? 0.0;

    final resultado = ParticipanteLocal(
      id: widget.participante?.id ?? 0,
      tipoDoc: _tipoDocLabel,
      numDoc: _numDocCtrl.text.trim().toUpperCase(),
      nacionalidad: _nacionalidadLabel,
      nombres: _nombresCtrl.text.trim().toUpperCase(),
      apellidoPaterno: _apellidoPaternoCtrl.text.trim().toUpperCase(),
      apellidoMaterno: _apellidoMaternoCtrl.text.trim().toUpperCase(),
      correo: _correoCtrl.text.trim(),
      cargo: _cargoCtrl.text.trim().toUpperCase(),
      celular: _celularCtrl.text.trim(),
      celularCodigoTelefono: _paisSeleccionado?.codigoTelefono ?? '',
      tipoParticipante: _tipoParticipante,
      importe: importe,
      esSolicitante: widget.participante?.esSolicitante ?? false,
    );

    widget.onGuardar(resultado);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final catalogState = context.watch<CatalogsBloc>().state;
    final tiposDocumento = catalogState is CatalogsLoaded
        ? catalogState.tiposDocumento
        : const <TipoDocumentoItem>[];
    final nacionalidades = catalogState is CatalogsLoaded
        ? catalogState.nacionalidades
        : const <NacionalidadItem>[];
    final paises = catalogState is CatalogsLoaded
        ? catalogState.paises
        : const <PaisItem>[];

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
                          width: 130,
                          child: CustomComboField<TipoDocumentoItem>(
                            label: 'Tipo doc.',
                            data: tiposDocumento,
                            initialValue: _tipoDocInicialId,
                            onChanged: (item) => setState(
                              () => _tipoDocLabel = item?.nombre ?? '',
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: CustomTextField(
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

                    // Nacionalidad + Tipo de participante
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CustomComboField<NacionalidadItem>(
                            label: 'Nacionalidad *',
                            data: nacionalidades,
                            initialValue: _nacionalidadInicialId,
                            onChanged: (item) => setState(
                              () => _nacionalidadLabel = item?.nombre ?? '',
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: CustomComboSearchField(
                            label: 'Tipo *',
                            data: _tiposParticipante,
                            displayIndex: 0,
                            initialValue: _tipoParticipante,
                            onChanged: (item) {
                              if (item != null) {
                                setState(() => _tipoParticipante = item.id);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Nombres
                    CustomTextField(
                      label: 'Nombres *',
                      controller: _nombresCtrl,
                      isUpperCase: true,
                      textCapitalization: TextCapitalization.characters,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Apellido paterno + Apellido materno
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'Apellido paterno *',
                            controller: _apellidoPaternoCtrl,
                            isUpperCase: true,
                            textCapitalization: TextCapitalization.characters,
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Requerido'
                                : null,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: CustomTextField(
                            label: 'Apellido materno',
                            controller: _apellidoMaternoCtrl,
                            isUpperCase: true,
                            textCapitalization: TextCapitalization.characters,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Correo
                    CustomTextField(
                      label: 'Correo electrónico *',
                      controller: _correoCtrl,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v.emailValidator,
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Cargo
                    CustomTextField(
                      label: 'Cargo *',
                      controller: _cargoCtrl,
                      isUpperCase: true,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Celular + Importe
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SolicitudCampoCelular(
                            controller: _celularCtrl,
                            habilitado: true,
                            paises: paises,
                            paisSeleccionado: _paisSeleccionado,
                            onPaisChanged: (p) =>
                                setState(() => _paisSeleccionado = p),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Requerido'
                                : null,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: CustomTextField(
                            label: 'Importe',
                            controller: _importeCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return null;
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
                          child: CustomOutlinedButton(
                            text: 'Cancelar',
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: CustomPrimaryButton(
                            text: _esEdicion ? 'Guardar' : 'Crear',
                            onPressed: _guardar,
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
