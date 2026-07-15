// lib/features/solicitudes/presentation/widgets/completar/solicitud_completar_datos_solicitante.dart
//
// Sección "Datos del solicitante" del paso 1 — tipo/número documento,
// nacionalidad, sexo, nombres, apellidos, cargo, celular y correo.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  });

  @override
  State<SeccionDatosSolicitante> createState() =>
      _SeccionDatosSolicitanteState();
}

class _SeccionDatosSolicitanteState extends State<SeccionDatosSolicitante> {
  String? _tipoDocId;

  @override
  void initState() {
    super.initState();
    _tipoDocId = widget.tipoDocInicialId;
  }

  // Límite de caracteres y tipo de teclado según tipo de documento — ids
  // reales de SYSTABEXTER02 CODTABLA='F01', vienen de
  // `CatalogsBloc.valoresDefecto` (parte [13] del SP), no hardcodeados.
  int? _maxLengthPorTipoDoc(ValoresCRMItem v) {
    if (_tipoDocId == null) return null;
    if (_tipoDocId == v.idTipoDocDni) return 8;
    if (_tipoDocId == v.idTipoDocCde) return 12;
    if (_tipoDocId == v.idTipoDocRuc) return 11;
    if (_tipoDocId == v.idTipoDocPas) return 12;
    return null;
  }

  bool _soloDigitosPorTipoDoc(ValoresCRMItem v) =>
      _tipoDocId == v.idTipoDocDni || _tipoDocId == v.idTipoDocRuc;

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

    final maxLenDoc = _maxLengthPorTipoDoc(valoresDefecto);
    final soloDigitos = _soloDigitosPorTipoDoc(valoresDefecto);
    final teclado = soloDigitos ? TextInputType.number : TextInputType.text;

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
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: CustomTextField(
                label: 'Número documento *',
                controller: widget.ctrlNumDoc,
                keyboardType: teclado,
                enabled: widget.habilitado,
                maxLength: maxLenDoc,
                inputFormatters: soloDigitos
                    ? [FilteringTextInputFormatter.digitsOnly]
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
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: CustomTextField(
                label: 'Correo *',
                controller: widget.ctrlCorreo,
                keyboardType: TextInputType.emailAddress,
                enabled: widget.habilitado,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
