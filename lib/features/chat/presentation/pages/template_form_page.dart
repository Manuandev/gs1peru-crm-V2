// lib/features/chat/presentation/pages/template_form_page.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/features/chat/index_chat.dart';

/// Crear (`idPlantilla` null) o editar (`idPlantilla` con valor) una plantilla.
///
/// Primera entrega — solo vista: `TemplateFormStarted` se despacha siempre
/// (arma el formulario en memoria), pero nunca dispara una llamada real al
/// backend — ver `TemplateFormBloc._onStarted`, donde la carga del detalle
/// por SP queda escrita y comentada hasta que ese endpoint exista.
class TemplateFormPage extends StatelessWidget {
  final int? idPlantilla;

  const TemplateFormPage({super.key, this.idPlantilla});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => TemplateFormBloc(
        getPlantilla: GetPlantillaUseCase(ctx.read<ChatRepository>()),
        guardarPlantilla: GuardarPlantillaUseCase(ctx.read<ChatRepository>()),
        subirArchivo: SubirArchivoPlantillaUseCase(ctx.read<ChatRepository>()),
      )..add(TemplateFormStarted(idPlantilla)),
      child: const TemplateFormView(),
    );
  }
}
