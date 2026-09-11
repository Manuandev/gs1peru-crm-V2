// lib/features/solicitudes/presentation/pages/solicitud_list_page.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class SolicitudListPage extends StatefulWidget {
  const SolicitudListPage({super.key});

  @override
  State<SolicitudListPage> createState() => _SolicitudListPageState();
}

class _SolicitudListPageState extends State<SolicitudListPage> {
  @override
  void initState() {
    super.initState();
    // Al entrar a Solicitudes, refresca campañas + eventos para que los combos
    // del panel de filtros estén al día (task 'FIL').
    context.read<CatalogsBloc>().add(const CatalogsFiltrosRefreshed());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SolicitudListBloc(
        GetSolicitudPaginaUseCase(context.read<SolicitudRepository>()),
      )..add(const SolicitudListStarted()),
      child: BlocListener<SolicitudListBloc, SolicitudListState>(
        listener: (context, state) {
          if (state is SolicitudListError) {
            AppSnackBar.error(context, state.message);
          } else if (state is SolicitudListSuccess &&
              state.busqueda.isEmpty) {
            // cntSinValidar se mueve con la búsqueda (el SP la aplica en el
            // universo); mientras se busca, el badge se queda con el último
            // valor sin búsqueda.
            context.updateBadge(solicitudes: state.cntSinValidar);
          }
        },
        child: const SolicitudListView(),
      ),
    );
  }
}
