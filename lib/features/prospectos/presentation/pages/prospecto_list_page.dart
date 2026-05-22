// // lib\features\prospectos\presentation\pages\prospecto_list_page.dart


// import 'package:app_crm/config/index_config.dart';
// // import 'package:app_crm/core/index_core.dart';
// import 'package:app_crm/features/prospectos/index_prospectos.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class ProspectoListPage extends StatelessWidget {
//   const ProspectoListPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => ProspectoListBloc(
//         GetProspectosUseCase(ProspectoRepositoryImpl(ProspectoRemoteDatasource())),
//       )..add(const ProspectoListStarted()),
//       child: BlocListener<ProspectoListBloc, ProspectoListState>(
//         listener: (context, state) {
//           if (state is ProspectoListError) {
//             context.showErrorSnack(state.message);
//           } else if (state is ProspectoListLoaded) {
//             // context.updateBadge(prospectos: state.prospectos.length);
//           }
//         },
//         child: const ProspectoListView(),
//       ),
//     );
//   }
// }
