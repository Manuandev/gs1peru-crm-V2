// lib/features/solicitudes/presentation/widgets/completar/participante_form_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

// ── Constantes de opciones ────────────────────────────────────────────────────
// "Tipo" de participante no tiene catálogo de backend — se mantiene hardcodeado.
// El id (1-4) es lo que se manda como ID_TIP_PARTICIPANTE al CUD — antes se
// mandaba el label completo ('Invitado auspicio', 18 chars) y truncaba la
// columna en EVT.T_TECMSOLINSCRIPCION02.

const _tiposParticipante = [
  '1¦Pagante',
  '2¦Invitado',
  '3¦Invitado auspicio',
  '4¦Online',
];
const _idTipoParticipantePagante = '1';

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
  final _documentoService = DocumentoExternoService();

  String _tipoDocId = '';
  String _tipoDocLabel = '';
  String? _tipoDocInicialId;
  String _nacionalidadId = '';
  String _nacionalidadLabel = '';
  String? _nacionalidadInicialId;
  late String _tipoParticipante;
  PaisItem? _paisSeleccionado;

  late final FocusNode _numDocFocus;
  String _ultimoDocBuscado = '';
  bool _buscandoDocumento = false;

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
    _tipoParticipante = p?.tipoParticipante ?? _idTipoParticipantePagante;
    _tipoDocId = p?.tipoDocId ?? '';
    _tipoDocLabel = p?.tipoDoc ?? '';
    _tipoDocInicialId = _tipoDocId.isNotEmpty ? _tipoDocId : null;
    _nacionalidadId = p?.nacionalidadId ?? '';
    _nacionalidadLabel = p?.nacionalidad ?? '';
    _nacionalidadInicialId = _nacionalidadId.isNotEmpty
        ? _nacionalidadId
        : null;

    final catalogState = context.read<CatalogsBloc>().state;
    if (catalogState is CatalogsLoaded) {
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

    _numDocFocus = FocusNode()..addListener(_onNumDocFocusChange);
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
    _numDocFocus.removeListener(_onNumDocFocusChange);
    _numDocFocus.dispose();
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
      tipoDocId: _tipoDocId,
      tipoDoc: _tipoDocLabel,
      numDoc: _numDocCtrl.text.trim().toUpperCase(),
      nacionalidadId: _nacionalidadId,
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

  void _onNumDocFocusChange() {
    if (_numDocFocus.hasFocus) return; // solo al perder el foco
    _buscarDocumento();
  }

  // Autocompleta nombres/apellidos/correo por DNI (8 dígitos) o RUC (11) al
  // salir del campo N° documento — Clientes/BuscarDocumento (interno →
  // RENIEC/SUNAT de fallback, ver solicitudes/CLAUDE.md).
  Future<void> _buscarDocumento() async {
    final numDoc = _numDocCtrl.text.trim();
    final esBusqueda = numDoc.length == 8 || numDoc.length == 11;
    if (!esBusqueda || numDoc == _ultimoDocBuscado) return;
    _ultimoDocBuscado = numDoc;

    setState(() => _buscandoDocumento = true);
    try {
      final resultado = await _documentoService.buscar(numDoc);
      if (!mounted) return;
      if (resultado == null || resultado.sinDatos) return;

      setState(() {
        if (resultado.nombres.isNotEmpty) {
          _nombresCtrl.text = resultado.nombres;
        } else if (resultado.nomEmpresa.isNotEmpty) {
          _nombresCtrl.text = resultado.nomEmpresa; // RUC sin persona natural
        }
        if (resultado.apePaterno.isNotEmpty) {
          _apellidoPaternoCtrl.text = resultado.apePaterno;
        }
        if (resultado.apeMaterno.isNotEmpty) {
          _apellidoMaternoCtrl.text = resultado.apeMaterno;
        }
        if (resultado.correo.isNotEmpty) {
          _correoCtrl.text = resultado.correo;
        }
      });
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.error(
        context,
        'No se pudo autocompletar los datos del documento.',
      );
    } finally {
      if (mounted) setState(() => _buscandoDocumento = false);
    }
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
                  bottom:
                      MediaQuery.viewInsetsOf(context).bottom + AppSpacing.md,
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
                              labelIndex: 2, // abreviatura (DNI/CE/RUC/...)
                              initialValue: _tipoDocInicialId,
                              onChanged: (item) => setState(() {
                                _tipoDocId = item?.id ?? '';
                                _tipoDocLabel = item?.abreviatura ?? '';
                              }),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: CustomTextField(
                              label: 'N° documento *',
                              controller: _numDocCtrl,
                              focusNode: _numDocFocus,
                              isUpperCase: true,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _buscarDocumento(),
                              suffixIcon: _buscandoDocumento
                                  ? const Padding(
                                      padding: EdgeInsets.all(AppSpacing.sm),
                                      child: SizedBox(
                                        width: AppSizing.iconSm,
                                        height: AppSizing.iconSm,
                                        child: CircularProgressIndicator(
                                          strokeWidth:
                                              AppSizing.spinnerStrokeSmall,
                                        ),
                                      ),
                                    )
                                  : null,
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
                              onChanged: (item) => setState(() {
                                _nacionalidadId = item?.id ?? '';
                                _nacionalidadLabel = item?.nombre ?? '';
                              }),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: CustomComboSearchField(
                              label: 'Tipo *',
                              data: _tiposParticipante,
                              displayIndex: 1,
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
                              keyboardType:
                                  const TextInputType.numberWithOptions(
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
