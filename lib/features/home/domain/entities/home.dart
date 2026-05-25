import 'package:app_crm/features/home/index_home.dart';

class Home {
  final int totConversaciones;
  final int totProspectos;
  final int totPropuesta;
  final int totCobranza;
  final List<Prioridad> prioridades;

  const Home({
    required this.totConversaciones,
    required this.totProspectos,
    required this.totPropuesta,
    required this.totCobranza,
    required this.prioridades,
  });
}
