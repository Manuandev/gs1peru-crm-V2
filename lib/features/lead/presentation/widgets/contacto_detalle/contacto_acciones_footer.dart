// lib/features/lead/presentation/widgets/contacto_detalle/contacto_acciones_footer.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class ContactoAccionesFooter extends StatelessWidget {
  final Negociacion lead;

  const ContactoAccionesFooter({super.key, required this.lead});

  // false si el número nunca tuvo conversación (idChatCab == 0) — oculta el
  // botón de WhatsApp por completo, no solo lo deshabilita. Mismo criterio
  // que LeadCardActions.mostrarWhatsApp en el listado (list/lead_card.dart).
  bool get _mostrarWhatsApp => lead.idChatCab > 0;

  // Sin negociación (contacto cargado sin ninguna activa) → el footer ofrece
  // crear una. Mismo patrón que ContactoNegociacionesTab._crearNegociacion.
  bool get _sinNegociacion => lead.idLead == 0;

  Future<void> _crearNegociacion(BuildContext context) async {
    final cubit = context.read<InfoLeadCubit>();
    cubit.prepararNuevaNegociacion();
    await context.goToEditarLead(idLead: 0, cubit: cubit);
    if (!context.mounted) return;
    // Re-lee cabecera + lista desde el SP — si creó, ya trae la negociación;
    // si canceló, vuelve al mismo estado "sin negociación".
    cubit.cargarPorIdContacto(lead.idContacto);
    context.read<NegociacionesCubit>().cargarNegociaciones(lead.idContacto);
  }

  // Mismo cálculo que LeadCard._tiempoChatAbiertoVencido() (list/lead_card.dart)
  // y ChatInputBar._tiempoChatAbiertoVencido() (chat/) — ventana de chat
  // abierto (TDE) medida desde el primer mensaje del cliente. Sin fecha se
  // considera no vencido, igual que en esas dos referencias.
  bool get _whatsAppVencido {
    final fechaPrimerMensaje = DateFormatter.parseDate(
      lead.fechaPrimerMensajeCliente,
    );
    if (fechaPrimerMensaje == null) return false;

    final transcurrido = DateTime.now().difference(fechaPrimerMensaje);
    final limite = ConfiguracionService().tiempoChatAbierto;
    return transcurrido.inMinutes >= limite * 60;
  }

  @override
  Widget build(BuildContext context) {
    final telefono = lead.telefonoCompleto;
    final colorWhatsApp = _whatsAppVencido
        ? AppColors.textDisabled
        : AppSocialUtils.colorCanal('whatsapp');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.black(AppColors.opacitySubtle),
            blurRadius: AppSizing.shadowBlurMd,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          if (_mostrarWhatsApp) ...[
            Expanded(
              child: CustomOutlinedButton(
                text: 'Conversación',
                icon: AppIcons.whatsapp,
                borderColor: colorWhatsApp,
                foregroundColor: colorWhatsApp,
                // Con conversación existente, el botón abre esa conversación
                // dentro del CRM — mismo destino que el WhatsApp de LeadCard
                // en el listado (list/lead_card.dart), no WhatsApp externo.
                onPressed: () =>
                    context.goToDetalleChat(idChatCab: lead.idChatCab),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: CustomOutlinedButton(
              text: 'Llamar',
              icon: AppIcons.phone,
              onPressed: telefono.isEmpty
                  ? null
                  : () => LauncherUtils.abrirTelefono(telefono),
            ),
          ),
          if (_sinNegociacion) ...[
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: CustomPrimaryButton(
                text: 'Crear negociación',
                icon: AppIcons.add,
                onPressed: () => _crearNegociacion(context),
              ),
            ),
          ],
          // Editar contacto — pendiente hasta que exista la pantalla de edición.
          // const SizedBox(width: AppSpacing.sm),
          // Expanded(
          //   child: CustomPrimaryButton(
          //     text: 'Editar',
          //     icon: AppIcons.edit,
          //     onPressed: () {},
          //   ),
          // ),
        ],
      ),
    );
  }
}
