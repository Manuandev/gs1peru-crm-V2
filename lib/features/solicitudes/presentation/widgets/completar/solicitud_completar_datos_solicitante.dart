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
  final ValueChanged<String>? onSexoChanged;

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

  // Límite de caracteres y tipo de teclado según tipo de documento —
  // códigos reales de SYSTABEXTER02 CODTABLA='F01' (catálogo real).
  static const _maxLengthPorTipo = {
    '1': 8, // DNI
    '4': 12, // Carnet de extranjería
    '6': 11, // RUC
    '7': 12, // Pasaporte
  };
  static const _soloDigitosPorTipo = {
    '1': true,
    '4': false,
    '6': true,
    '7': false,
  };

  // Sexo no tiene catálogo de backend — se mantiene hardcodeado por ahora.
  static const _sexos = ['M¦Masculino', 'F¦Femenino', 'PD¦Por definir'];

  @override
  Widget build(BuildContext context) {
    final maxLenDoc = _tipoDocId != null ? _maxLengthPorTipo[_tipoDocId] : null;
    final soloDigitos = _soloDigitosPorTipo[_tipoDocId] ?? false;
    final teclado = soloDigitos ? TextInputType.number : TextInputType.text;

    final catalogState = context.watch<CatalogsBloc>().state;
    final tiposDocumento = catalogState is CatalogsLoaded
        ? catalogState.tiposDocumento
        : const <TipoDocumentoItem>[];
    final nacionalidades = catalogState is CatalogsLoaded
        ? catalogState.nacionalidades
        : const <NacionalidadItem>[];

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
              child: CustomComboSearchField(
                label: 'Sexo *',
                data: _sexos,
                enabled: widget.habilitado,
                initialValue: widget.sexoInicialId,
                onChanged: (item) => widget.onSexoChanged?.call(item?.id ?? ''),
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
