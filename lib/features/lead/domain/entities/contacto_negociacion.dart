// lib/features/lead/domain/entities/contacto_negociacion.dart
//
// Composite para el listado principal (LeadCard/LeadListBloc) — una fila
// del SP [CRM].[SP_LeadsLst] task 'LS' es 1 Contacto + su Numero principal +
// su Negociacion (lead) más reciente. Contacto/Numero/Negociacion se quedan
// puros y reutilizables; esta clase solo existe para esa pantalla.

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class ContactoNegociacion extends Equatable {
  final Contacto contacto;
  final Numero numero;
  final Negociacion negociacion;

  /// Cantidad total de leads de este número (CL.CT_LEADS) — para el badge
  /// "N casos" de la card, no es un campo de [Negociacion].
  final int totalLeads;

  const ContactoNegociacion({
    required this.contacto,
    required this.numero,
    required this.negociacion,
    required this.totalLeads,
  });

  /// Nombre a mostrar — si el contacto no tiene nombre/apellidos registrados,
  /// cae al número de teléfono como identificador.
  String get nombreCompleto {
    final nombre = contacto.nombreCompleto;
    return nombre.isNotEmpty ? nombre : '${numero.prefijo} ${numero.numero}';
  }

  @override
  List<Object?> get props => [contacto, numero, negociacion, totalLeads];

  ContactoNegociacion copyWith({
    Contacto? contacto,
    Numero? numero,
    Negociacion? negociacion,
    int? totalLeads,
  }) {
    return ContactoNegociacion(
      contacto: contacto ?? this.contacto,
      numero: numero ?? this.numero,
      negociacion: negociacion ?? this.negociacion,
      totalLeads: totalLeads ?? this.totalLeads,
    );
  }
}
