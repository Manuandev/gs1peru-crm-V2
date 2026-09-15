// lib/features/solicitudes/presentation/widgets/completar/participante_form_campos.dart
//
// Filas de campos del formulario "Nuevo/Editar participante"
// (participante_form_sheet.dart), extraídas como widgets puros — reciben
// controllers/valores/catálogos y devuelven cambios por callback, sin leer
// ni escribir directamente el estado del formulario padre.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

// ── Encabezado ("Nuevo/Editar participante" + cerrar) ─────────────────────────

class EncabezadoFormularioParticipante extends StatelessWidget {
  final bool esEdicion;
  final VoidCallback onCerrar;

  const EncabezadoFormularioParticipante({
    super.key,
    required this.esEdicion,
    required this.onCerrar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            esEdicion ? 'Editar participante' : 'Nuevo participante',
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: AppTextStyles.weightBold,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: onCerrar,
            icon: const Icon(
              AppIcons.close,
              size: AppSizing.iconMd,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tipo documento + N° documento ─────────────────────────────────────────────

class CampoTipoDocNumDoc extends StatelessWidget {
  final List<TipoDocumentoItem> tiposDocumento;
  final String? tipoDocInicialId;
  final ValueChanged<TipoDocumentoItem?> onTipoDocChanged;
  final TextEditingController numDocCtrl;
  final FocusNode numDocFocus;
  final int? maxLenDoc;
  final TextInputType? tecladoDoc;
  final List<TextInputFormatter>? inputFormattersDoc;
  // Requerido + longitud exacta del tipo (DocumentoValidationUtils.validador).
  final FormFieldValidator<String> validatorDoc;
  final VoidCallback onBuscarDocumento;

  const CampoTipoDocNumDoc({
    super.key,
    required this.tiposDocumento,
    required this.tipoDocInicialId,
    required this.onTipoDocChanged,
    required this.numDocCtrl,
    required this.numDocFocus,
    required this.maxLenDoc,
    required this.tecladoDoc,
    required this.inputFormattersDoc,
    required this.validatorDoc,
    required this.onBuscarDocumento,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: CustomComboField<TipoDocumentoItem>(
            label: 'Tipo doc.',
            data: tiposDocumento,
            labelIndex: 2, // abreviatura (Sin doc/DNI/CE/Pas.)
            initialValue: tipoDocInicialId,
            onChanged: onTipoDocChanged,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: CustomTextField(
            label: 'N° documento *',
            controller: numDocCtrl,
            focusNode: numDocFocus,
            isUpperCase: true,
            keyboardType: tecladoDoc,
            maxLength: maxLenDoc,
            inputFormatters: inputFormattersDoc,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onBuscarDocumento(),
            validator: validatorDoc,
          ),
        ),
      ],
    );
  }
}

// ── Nacionalidad + Tipo de participante ───────────────────────────────────────

class CampoNacionalidadTipoParticipante extends StatelessWidget {
  final List<NacionalidadItem> nacionalidades;
  final String? nacionalidadInicialId;
  final ValueChanged<NacionalidadItem?> onNacionalidadChanged;
  final List<TipoParticipanteItem> tiposParticipante;
  final String tipoParticipanteInicial;
  final ValueChanged<TipoParticipanteItem?> onTipoParticipanteChanged;

  const CampoNacionalidadTipoParticipante({
    super.key,
    required this.nacionalidades,
    required this.nacionalidadInicialId,
    required this.onNacionalidadChanged,
    required this.tiposParticipante,
    required this.tipoParticipanteInicial,
    required this.onTipoParticipanteChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          // Combo con búsqueda estricto (2026-09-14) — sin texto libre.
          child: CustomComboSearchField(
            data: nacionalidades
                .map((n) => '${n.id}${AppConstants.sepCampos}${n.nombre}')
                .toList(),
            label: 'Nacionalidad *',
            isUpperCase: true,
            initialValue: nacionalidadInicialId,
            onChanged: (item) => onNacionalidadChanged(
              item == null
                  ? null
                  : nacionalidades.where((n) => n.id == item.id).firstOrNull,
            ),
            validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: CustomComboField<TipoParticipanteItem>(
            label: 'Tipo *',
            data: tiposParticipante,
            initialValue: tipoParticipanteInicial,
            onChanged: onTipoParticipanteChanged,
            validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
          ),
        ),
      ],
    );
  }
}

// ── Nombres + Apellidos + Correo ──────────────────────────────────────────────

class CampoDatosPersonales extends StatelessWidget {
  final TextEditingController nombresCtrl;
  final TextEditingController apellidoPaternoCtrl;
  final TextEditingController apellidoMaternoCtrl;
  final TextEditingController correoCtrl;

  const CampoDatosPersonales({
    super.key,
    required this.nombresCtrl,
    required this.apellidoPaternoCtrl,
    required this.apellidoMaternoCtrl,
    required this.correoCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextField(
          label: 'Nombres *',
          controller: nombresCtrl,
          isUpperCase: true,
          textCapitalization: TextCapitalization.characters,
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Requerido' : null,
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CustomTextField(
                label: 'Apellido paterno *',
                controller: apellidoPaternoCtrl,
                isUpperCase: true,
                textCapitalization: TextCapitalization.characters,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Requerido' : null,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: CustomTextField(
                label: 'Apellido materno',
                controller: apellidoMaternoCtrl,
                isUpperCase: true,
                textCapitalization: TextCapitalization.characters,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        CustomTextField(
          label: 'Correo electrónico *',
          controller: correoCtrl,
          keyboardType: TextInputType.emailAddress,
          isUpperCase: true,
          validator: (v) => v.emailValidator,
        ),
      ],
    );
  }
}

// ── Cargo (combo con búsqueda, texto libre) ───────────────────────────────────

class CampoCargoParticipante extends StatelessWidget {
  final List<CargoItem> cargos;
  final String cargoInicialTexto;
  final ValueChanged<ComboItem?> onCargoChanged;

  const CampoCargoParticipante({
    super.key,
    required this.cargos,
    required this.cargoInicialTexto,
    required this.onCargoChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Mismo catálogo/widget que Datos del solicitante (paso 1) y
    // lead/EditContacto — solo como sugerencia, siempre se guarda como texto
    // libre (`item.descripcion`, nunca `item.id`). Texto libre (allowFreeText,
    // 2026-08-04) — si el cargo no está en el catálogo, tipearlo lo guarda
    // tal cual, sin necesidad de confirmar con el check del teclado
    // (2026-08-12, ver core/CLAUDE.md → CustomComboSearchField).
    return CustomComboSearchField(
      data: cargos
          .map((c) => '${c.id}${AppConstants.sepCampos}${c.nombre}')
          .toList(),
      label: 'Cargo *',
      allowFreeText: true,
      isUpperCase: true,
      initialText: cargoInicialTexto,
      onChanged: onCargoChanged,
      validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
    );
  }
}

// ── Fechas de asistencia (solo si la oportunidad+campaña tiene un evento
// vinculado, ver SolicitudFormState.eventoFechas / solicitudes/CLAUDE.md) ────

class CampoFechasAsistencia extends StatelessWidget {
  final List<EventoFechaItem> fechas;
  final Set<int> seleccionadas;
  final ValueChanged<int> onToggle;

  const CampoFechasAsistencia({
    super.key,
    required this.fechas,
    required this.seleccionadas,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Fechas de asistencia *',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: AppTextStyles.weightMedium,
                ),
              ),
              const Spacer(),
              Text(
                '${seleccionadas.length} de ${fechas.length}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              for (var i = 0; i < fechas.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _BotonFechaAsistencia(
                    fecha: fechas[i].fecha,
                    seleccionada: seleccionadas.contains(fechas[i].idFecha),
                    onTap: () => onToggle(fechas[i].idFecha),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Abreviaturas peruanas de día/mes ("SET" para septiembre, no "SEP") para
/// las fechas de asistencia — compartidas por el formulario de participante
/// (`CampoFechasAsistencia`) y la tarjeta de la lista (`ParticipanteCard`).
abstract final class FormatoFechaAsistencia {
  static const diasSemana = ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];
  static const meses = [
    'ENE',
    'FEB',
    'MAR',
    'ABR',
    'MAY',
    'JUN',
    'JUL',
    'AGO',
    'SET',
    'OCT',
    'NOV',
    'DIC',
  ];

  static String diaSemana(DateTime fecha) => diasSemana[fecha.weekday - 1];
  static String mes(DateTime fecha) => meses[fecha.month - 1];
}

class _BotonFechaAsistencia extends StatelessWidget {
  final DateTime fecha;
  final bool seleccionada;
  final VoidCallback onTap;

  const _BotonFechaAsistencia({
    required this.fecha,
    required this.seleccionada,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorTexto = seleccionada
        ? AppColors.textOnDark
        : AppColors.textPrimary;
    final colorTextoSecundario = seleccionada
        ? AppColors.white(0.8)
        : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizing.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: seleccionada ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizing.radiusSm),
          border: seleccionada ? null : Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              FormatoFechaAsistencia.diaSemana(fecha),
              style: AppTextStyles.labelSmall.copyWith(
                color: colorTextoSecundario,
                fontWeight: AppTextStyles.weightMedium,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              fecha.day.toString().padLeft(2, '0'),
              style: AppTextStyles.titleMedium.copyWith(
                color: colorTexto,
                fontWeight: AppTextStyles.weightBold,
              ),
            ),
            Text(
              FormatoFechaAsistencia.mes(fecha),
              style: AppTextStyles.labelSmall.copyWith(
                color: colorTextoSecundario,
                fontWeight: AppTextStyles.weightMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Celular + Importe ──────────────────────────────────────────────────────────

class CampoCelularImporte extends StatelessWidget {
  final TextEditingController celularCtrl;
  final List<PaisItem> paises;
  final PaisItem? paisSeleccionado;
  final ValueChanged<PaisItem> onPaisChanged;
  final TextEditingController importeCtrl;

  const CampoCelularImporte({
    super.key,
    required this.celularCtrl,
    required this.paises,
    required this.paisSeleccionado,
    required this.onPaisChanged,
    required this.importeCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SolicitudCampoCelular(
            controller: celularCtrl,
            habilitado: true,
            paises: paises,
            paisSeleccionado: paisSeleccionado,
            onPaisChanged: onPaisChanged,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Requerido' : null,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: CustomTextField(
            label: 'Importe *',
            controller: importeCtrl,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Requerido';
              }
              final importe = double.tryParse(v.trim());
              if (importe == null) {
                return 'Número inválido';
              }
              if (importe <= 0) {
                return 'Debe ser mayor a 0';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}

// ── Botones Cancelar / Guardar-Crear ──────────────────────────────────────────

class BotonesFormularioParticipante extends StatelessWidget {
  final bool esEdicion;
  final VoidCallback onCancelar;
  final VoidCallback onGuardar;

  const BotonesFormularioParticipante({
    super.key,
    required this.esEdicion,
    required this.onCancelar,
    required this.onGuardar,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomOutlinedButton(text: 'Cancelar', onPressed: onCancelar),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: CustomPrimaryButton(
            text: esEdicion ? 'Guardar' : 'Crear',
            onPressed: onGuardar,
          ),
        ),
      ],
    );
  }
}
