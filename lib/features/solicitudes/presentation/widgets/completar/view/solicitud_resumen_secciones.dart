// lib/features/solicitudes/presentation/widgets/completar/view/solicitud_resumen_secciones.dart
//
// Secciones "1. Solicitante", "2. Participantes" y "3. Facturación" de
// SolicitudResumenView.

import 'package:flutter/material.dart';

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class SeccionSolicitante extends StatelessWidget {
  final DatosSolicitante? datos;
  final bool modoEdicion;
  final VoidCallback onEditar;

  const SeccionSolicitante({
    super.key,
    required this.onEditar,
    required this.modoEdicion,
    this.datos,
  });

  @override
  Widget build(BuildContext context) {
    final d = datos;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CabeceraSeccion(
          icono: AppIcons.user,
          titulo: '1. Solicitante',
          // Oculto por completo en modo solo-ver, no solo deshabilitado.
          accion: modoEdicion ? BotonEditar(onTap: onEditar) : null,
        ),
        const SizedBox(height: AppSpacing.sm),
        FilaCampos(
          izquierdo: CampoDato(
            icono: AppIcons.user,
            label: 'Nombre completo',
            valor: d?.nombreCompleto ?? '—',
          ),
          derecho: CampoDato(
            icono: AppIcons.email,
            label: 'Correo',
            valor: d?.correo ?? '—',
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        FilaCampos(
          izquierdo: CampoDato(
            icono: AppIcons.documento,
            label: 'Documento',
            valor: d?.documento ?? '—',
          ),
          derecho: CampoDato(
            icono: AppIcons.info,
            label: '¿Cómo se enteró del evento?',
            valor: d?.canalTexto ?? '—',
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        FilaCampos(
          izquierdo: CampoDato(
            icono: AppIcons.business,
            label: 'Cargo',
            valor: d?.cargo ?? '—',
          ),
          derecho: CampoDato(
            icono: AppIcons.phone,
            label: 'Celular',
            valor: d != null && d.celular.isNotEmpty
                ? '+${d.celularCodigoTelefono} ${d.celular}'
                : '—',
          ),
        ),
      ],
    );
  }
}

class SeccionParticipantes extends StatelessWidget {
  final VoidCallback onVerTodos;

  const SeccionParticipantes({super.key, required this.onVerTodos});

  @override
  Widget build(BuildContext context) {
    final participantes = context
        .watch<ParticipantesCubit>()
        .state
        .participantes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CabeceraSeccion(
          icono: AppIcons.users,
          titulo: '2. Participantes',
          accion: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizing.radiusCircular),
            ),
            child: Text(
              '${participantes.length} participante/s',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: AppTextStyles.weightSemiBold,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        if (participantes.isEmpty)
          Text(
            'Sin participantes registrados',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          )
        else ...[
          // Cabecera tabla
          _FilaTabla(
            numero: 'N°',
            nombre: 'Nombre completo',
            documento: 'Documento',
            cargo: 'Cargo',
            celular: 'Celular',
            esEncabezado: true,
          ),
          const Divider(height: AppSpacing.xs, thickness: 0.5),

          for (int i = 0; i < participantes.length; i++) ...[
            _FilaTabla(
              numero: '${i + 1}',
              nombre: participantes[i].nombreCompleto,
              documento: participantes[i].numDoc,
              cargo: participantes[i].cargo,
              celular: participantes[i].celular,
              esEncabezado: false,
            ),
            if (i < participantes.length - 1)
              const Divider(height: AppSpacing.xs, thickness: 0.3),
          ],
        ],

        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: onVerTodos,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ver los ${participantes.length} participantes',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: AppTextStyles.weightSemiBold,
                ),
              ),
              const SizedBox(width: AppSpacing.xxs),
              const Icon(
                AppIcons.chevronRight,
                color: AppColors.primary,
                size: AppSizing.iconActionSm,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilaTabla extends StatelessWidget {
  final String numero;
  final String nombre;
  final String documento;
  final String cargo;
  final String celular;
  final bool esEncabezado;

  const _FilaTabla({
    required this.numero,
    required this.nombre,
    required this.documento,
    required this.cargo,
    required this.celular,
    required this.esEncabezado,
  });

  @override
  Widget build(BuildContext context) {
    final estilo = esEncabezado
        ? AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: AppTextStyles.weightMedium,
          )
        : AppTextStyles.labelSmall.copyWith(color: AppColors.textPrimary);

    return Row(
      children: [
        SizedBox(width: 20, child: Text(numero, style: estilo)),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          flex: 5,
          child: Text(nombre, style: estilo, overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          flex: 3,
          child: Text(
            documento,
            style: estilo,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          flex: 3,
          child: Text(cargo, style: estilo, overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          flex: 3,
          child: Text(celular, style: estilo, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

class SeccionFacturacion extends StatelessWidget {
  final DatosFacturacion? datos;
  final String tipoPersonaLabel;
  final bool modoEdicion;
  final VoidCallback onEditar;

  const SeccionFacturacion({
    super.key,
    required this.onEditar,
    required this.tipoPersonaLabel,
    required this.modoEdicion,
    this.datos,
  });

  @override
  Widget build(BuildContext context) {
    final d = datos;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CabeceraSeccion(
          icono: AppIcons.receipt,
          titulo: '3. Facturación',
          // Oculto por completo en modo solo-ver, no solo deshabilitado.
          accion: modoEdicion ? BotonEditar(onTap: onEditar) : null,
        ),
        const SizedBox(height: AppSpacing.sm),
        FilaCampos(
          izquierdo: CampoDato(
            icono: AppIcons.documento,
            label: 'Tipo de solicitante',
            valor: tipoPersonaLabel,
          ),
          derecho: CampoDato(
            icono: AppIcons.business,
            label: 'Razón social / Nombres',
            valor: d?.nombresRazon ?? '—',
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        FilaCampos(
          izquierdo: CampoDato(
            icono: AppIcons.fileFactura,
            label: 'Comprobante',
            valor: d?.comprobante ?? '—',
          ),
          derecho: CampoDato(
            icono: AppIcons.documento,
            label: 'Número de documento',
            valor: d?.numDoc ?? '—',
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        FilaCampos(
          izquierdo: CampoDato(
            icono: AppIcons.language,
            label: 'País',
            valor: d?.pais ?? '—',
          ),
          derecho: CampoDato(
            icono: AppIcons.email,
            label: 'Correo de envío de boleta',
            valor: d?.correo ?? '—',
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        FilaCampos(
          izquierdo: CampoDato(
            icono: AppIcons.moneda,
            label: 'Moneda',
            valor: d?.moneda ?? '—',
          ),
          derecho: CampoDato(
            icono: AppIcons.location,
            label: 'Dirección',
            valor: d?.direccion ?? '—',
          ),
        ),
      ],
    );
  }
}
