// lib/features/cobranza/presentation/pages/cobranza_list_page.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaListPage extends StatelessWidget {
  const CobranzaListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CobranzaListBloc(
        GetCobranzasUseCase(context.read<CobranzaRepository>()),
      )..add(const CobranzaListStarted()),
      child: BlocListener<CobranzaListBloc, CobranzaListState>(
        listener: (context, state) {
          if (state is CobranzaListError) {
            AppSnackBar.error(context, state.message);
          }
        },
        child: const CobranzaListView(),
      ),
    );
  }
}
