// lib/features/solicitudes/presentation/widgets/completar/solicitud_completar_datos_solicitante.dart
//
// Sección "Datos del solicitante" del paso 1 — tipo/número documento,
// nacionalidad, sexo, nombres, apellidos, cargo, celular y correo.

import 'package:flutter/material.dart';

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class SeccionDatosSolicitante extends StatefulWidget {
  final bool habilitado;
  final TextEditingController ctrlNumDoc;
  final TextEditingController ctrlNombres;
  final TextEditingController ctrlApellidoPaterno;
  final TextEditingController ctrlApellidoMaterno;
  final TextEditingController ctrlCargo;
  final TextEditingController ctrlCelular;
  final TextEditingController ctrlCorreo;
  final List<PaisItem> paises;
  final PaisItem? paisCelular;
  final ValueChanged<PaisItem> onPaisCelularChanged;
  final String? tipoDocInicialId;
  final String? nacionalidadInicialId;
  final String? sexoInicialId;
  final ValueChanged<TipoDocumentoItem?>? onTipoDocChanged;
  final ValueChanged<NacionalidadItem?>? onNacionalidadChanged;
  final ValueChanged<SexoItem?>? onSexoChanged;
  // Autocompletado por documento (Clientes/BuscarDocumento) — se dispara al
  // perder foco o al presionar el check del teclado en Número documento. El
  // indicador de carga es un overlay de pantalla completa que arma el padre
  // (SolicitudCompletarView), no algo local a este campo.
  final VoidCallback? onBuscarDocumento;

  const SeccionDatosSolicitante({
    super.key,
    required this.habilitado,
    required this.ctrlNumDoc,
    required this.ctrlNombres,
    required this.ctrlApellidoPaterno,
    required this.ctrlApellidoMaterno,
    required this.ctrlCargo,
    required this.ctrlCelular,
    required this.ctrlCorreo,
    required this.paises,
    required this.paisCelular,
    required this.onPaisCelularChanged,
    this.tipoDocInicialId,
    this.nacionalidadInicialId,
    this.sexoInicialId,
    this.onTipoDocChanged,
    this.onNacionalidadChanged,
    this.onSexoChanged,
    this.onBuscarDocumento,
  });

  @override
  State<SeccionDatosSolicitante> createState() =>
      _SeccionDatosSolicitanteState();
}

class _SeccionDatosSolicitanteState extends State<SeccionDatosSolicitante> {
  String? _tipoDocId;
  late final FocusNode _numDocFocus;

  @override
  void initState() {
    super.initState();
    _tipoDocId = widget.tipoDocInicialId;
    _numDocFocus = FocusNode()..addListener(_onNumDocFocusChange);
  }

  void _onNumDocFocusChange() {
    if (_numDocFocus.hasFocus) return; // solo al perder el foco
    widget.onBuscarDocumento?.call();
  }

  @override
  void dispose() {
    _numDocFocus.removeListener(_onNumDocFocusChange);
    _numDocFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalogState = context.watch<CatalogsBloc>().state;
    final tiposDocumento = catalogState is CatalogsLoaded
        ? catalogState.tiposDocumento
        : const <TipoDocumentoItem>[];
    final nacionalidades = catalogState is CatalogsLoaded
        ? catalogState.nacionalidades
        : const <NacionalidadItem>[];
    final sexos = catalogState is CatalogsLoaded
        ? catalogState.sexos
        : const <SexoItem>[];
    final valoresDefecto = catalogState is CatalogsLoaded
        ? catalogState.valoresDefecto
        : const ValoresCRMItem();

    final maxLenDoc = DocumentoValidationUtils.maxLength(
      _tipoDocId,
      valoresDefecto,
    );
    final teclado = DocumentoValidationUtils.keyboardType(
      _tipoDocId,
      valoresDefecto,
    );
    final inputFormatters = DocumentoValidationUtils.inputFormatters(
      _tipoDocId,
      valoresDefecto,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            const Icon(
              Icons.person_rounded,
              color: AppColors.primary,
              size: AppSizing.iconMd,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Datos del solicitante',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: AppTextStyles.weightSemiBold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // Fila 1: Tipo documento + Número documento
        Row(
          children: [
            Expanded(
              child: CustomComboField<TipoDocumentoItem>(
                label: 'Tipo documento *',
                data: tiposDocumento,
                labelIndex: 2, // abreviatura (DNI/CE/RUC/Pasaporte...)
                enabled: widget.habilitado,
                initialValue: widget.tipoDocInicialId,
                onChanged: (item) {
                  setState(() {
                    _tipoDocId = item?.id;
                    widget.ctrlNumDoc.clear();
                  });
                  widget.onTipoDocChanged?.call(item);
                },
                validator: (v) =>
                    v == null || v.isEmpty ? 'Requerido' : null,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: CustomTextField(
                label: 'Número documento *',
                controller: widget.ctrlNumDoc,
                focusNode: _numDocFocus,
                keyboardType: teclado,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => widget.onBuscarDocumento?.call(),
                enabled: widget.habilitado,
                maxLength: maxLenDoc,
                inputFormatters: inputFormatters,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Requerido'
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),

        // Fila 2: Nacionalidad + Sexo
        Row(
          children: [
            Expanded(
              child: CustomComboField<NacionalidadItem>(
                label: 'Nacionalidad *',
                data: nacionalidades,
                enabled: widget.habilitado,
                initialValue: widget.nacionalidadInicialId,
                onChanged: (item) => widget.onNacionalidadChanged?.call(item),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Requerido' : null,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: CustomComboField<SexoItem>(
                label: 'Sexo *',
                data: sexos,
                enabled: widget.habilitado,
                initialValue: widget.sexoInicialId,
                onChanged: widget.onSexoChanged,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Requerido' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),

        // Nombres
        CustomTextField(
          label: 'Nombres *',
          controller: widget.ctrlNombres,
          enabled: widget.habilitado,
          isUpperCase: true,
          textCapitalization: TextCapitalization.words,
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Requerido' : null,
        ),
        const SizedBox(height: AppSpacing.xs),

        // Fila 3: Apellido paterno + Apellido materno
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'Apellido paterno *',
                controller: widget.ctrlApellidoPaterno,
                enabled: widget.habilitado,
                isUpperCase: true,
                textCapitalization: TextCapitalization.words,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Requerido'
                    : null,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: CustomTextField(
                label: 'Apellido materno',
                controller: widget.ctrlApellidoMaterno,
                enabled: widget.habilitado,
                isUpperCase: true,
                textCapitalization: TextCapitalization.words,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),

        // Cargo
        CustomTextField(
          label: 'Cargo *',
          controller: widget.ctrlCargo,
          enabled: widget.habilitado,
          isUpperCase: true,
          textCapitalization: TextCapitalization.sentences,
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Requerido' : null,
        ),
        const SizedBox(height: AppSpacing.xs),

        // Fila 4: Celular + Correo
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SolicitudCampoCelular(
                controller: widget.ctrlCelular,
                habilitado: widget.habilitado,
                paises: widget.paises,
                paisSeleccionado: widget.paisCelular,
                onPaisChanged: widget.onPaisCelularChanged,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Requerido'
                    : null,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: CustomTextField(
                label: 'Correo *',
                controller: widget.ctrlCorreo,
                keyboardType: TextInputType.emailAddress,
                enabled: widget.habilitado,
                validator: (v) => v.emailValidator,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
