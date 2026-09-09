// lib/features/cobranza/presentation/pages/cobranza_list_page.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaListPage extends StatefulWidget {
  // true → arranca con el rango de fechas del filtro avanzado APAGADO (trae
  // todo el histórico). Lo manda el embudo de Home; el Drawer entra en false.
  final bool sinRangoFecha;

  const CobranzaListPage({super.key, this.sinRangoFecha = false});

  @override
  State<CobranzaListPage> createState() => _CobranzaListPageState();
}

class _CobranzaListPageState extends State<CobranzaListPage> {
  @override
  void initState() {
    super.initState();
    // Mantiene frescos los combos del filtro avanzado (campañas + oportunidades).
    context.read<CatalogsBloc>().add(const CatalogsFiltrosRefreshed());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CobranzaListBloc(
        GetCobranzaPaginaUseCase(context.read<CobranzaRepository>()),
        sinRangoFecha: widget.sinRangoFecha,
      )..add(const CobranzaListStarted()),
      child: BlocListener<CobranzaListBloc, CobranzaListState>(
        listenWhen: (prev, curr) =>
            curr is CobranzaListErrorInicial || curr is CobranzaListCargado,
        listener: (context, state) {
          if (state is CobranzaListErrorInicial) {
            AppSnackBar.error(context, state.mensaje);
          } else if (state is CobranzaListCargado) {
            context.updateBadge(cobranza: state.pendientesDocumento);
          }
        },
        child: const CobranzaListView(),
      ),
    );
  }
}
