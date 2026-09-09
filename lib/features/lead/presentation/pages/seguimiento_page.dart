// lib/features/lead/presentation/pages/seguimiento_page.dart
//
// Página NUEVA de Seguimiento con paginado real (task 'LSP'). Reemplaza a
// LeadListPage en la ruta AppRoutes.seguimiento. LeadListPage/LeadListBloc
// quedan intactos, sin caller.

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class SeguimientoPage extends StatefulWidget {
  final LeadListFiltro? filtroInicial;
  // true → arranca con el rango de fechas del filtro avanzado APAGADO (trae
  // todo el histórico). Lo manda el embudo de Home; el Drawer entra en false.
  final bool sinRangoFecha;

  const SeguimientoPage({
    super.key,
    this.filtroInicial,
    this.sinRangoFecha = false,
  });

  @override
  State<SeguimientoPage> createState() => _SeguimientoPageState();
}

class _SeguimientoPageState extends State<SeguimientoPage> {
  @override
  void initState() {
    super.initState();
    // Mantiene frescos los combos del filtro avanzado (campañas + oportunidades).
    context.read<CatalogsBloc>().add(const CatalogsFiltrosRefreshed());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SeguimientoBloc(
        GetSeguimientoPaginaUseCase(
          SeguimientoRepositoryImpl(SeguimientoRemoteDatasource()),
        ),
        filtroInicial: widget.filtroInicial,
        sinRangoFecha: widget.sinRangoFecha,
      )..add(const SeguimientoIniciado()),
      child: BlocListener<SeguimientoBloc, SeguimientoEstado>(
        listenWhen: (prev, curr) =>
            curr is SeguimientoErrorInicial || curr is SeguimientoCargado,
        listener: (context, state) {
          if (state is SeguimientoErrorInicial) {
            AppSnackBar.error(context, state.mensaje);
          } else if (state is SeguimientoCargado) {
            context.updateBadge(seguimientos: state.activos);
          }
        },
        child: const SeguimientoView(),
      ),
    );
  }
}
