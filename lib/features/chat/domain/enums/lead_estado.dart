// lib/features/chat/domain/enums/lead_estado.dart

enum LeadEstado {
  nuevo('00', 'Nuevo'),
  enDesarrollo('01', 'En desarrollo'),
  propuesta('02', 'Propuesta'),
  cobranza('04', 'Cobranza'); // 👈 ID 04, label Cobranza

  final String id;
  final String label;
  const LeadEstado(this.id, this.label);

  static LeadEstado fromId(String id) {
    return LeadEstado.values.firstWhere(
      (e) => e.id == id,
      orElse: () => LeadEstado.nuevo,
    );
  }
}