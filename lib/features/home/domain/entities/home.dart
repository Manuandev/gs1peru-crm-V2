import 'package:app_crm/features/home/index_home.dart';

class Home {
  final int totConversaciones;
  final int totProspectos;
  final int totPropuestas;
  final int totCobranza;
  final int totLeadsNuevos;
  final int totLeadsDesarrollo;
  final List<Prioridad> prioridades;

  const Home({
    required this.totConversaciones,
    required this.totProspectos,
    required this.totPropuestas,
    required this.totCobranza,
    required this.totLeadsNuevos,
    required this.totLeadsDesarrollo,
    required this.prioridades,
  });
}
