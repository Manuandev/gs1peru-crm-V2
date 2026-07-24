// lib/features/chat/presentation/bloc/template_form/template_form_bloc.dart

import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/features/chat/index_chat.dart';

const _plantillaVacia = Plantilla(
  idPlantilla: 0,
  nombre: '',
  idMeta: '',
  estadoMeta: '',
  contenido: '',
  archivoRuta: '',
  archivoNombre: '',
  archivoExt: '',
  tieneBoton: false,
);

/// Bloc del formulario de crear/editar plantilla.
///
/// Primera entrega — solo vista: `TemplateFormStarted` nunca dispara la carga
/// real (queda escrita y comentada), y `TemplateFormGuardarPressed` no
/// persiste nada todavía. `GetPlantillaUseCase`/`GuardarPlantillaUseCase` ya
/// están inyectados y listos para cuando el SP de backend se defina.
class TemplateFormBloc extends Bloc<TemplateFormEvent, TemplateFormState> {
  // ignore: unused_field — se usa al descomentar la carga real, ver _onStarted.
  final GetPlantillaUseCase _getPlantilla;
  // ignore: unused_field — se usa al descomentar el guardado real, ver _onGuardarPressed.
  final GuardarPlantillaUseCase _guardarPlantilla;

  TemplateFormBloc({
    required GetPlantillaUseCase getPlantilla,
    required GuardarPlantillaUseCase guardarPlantilla,
  }) : _getPlantilla = getPlantilla,
       _guardarPlantilla = guardarPlantilla,
       super(const TemplateFormInitial()) {
    on<TemplateFormStarted>(_onStarted);
    on<TemplateFormGuardarPressed>(_onGuardarPressed);
  }

  Future<void> _onStarted(
    TemplateFormStarted event,
    Emitter<TemplateFormState> emit,
  ) async {
    if (event.idPlantilla == null) {
      // Modo crear — formulario vacío, sin llamada al backend.
      emit(const TemplateFormLoaded(plantilla: _plantillaVacia));
      return;
    }

    // Modo editar — por ahora abre igual con el formulario vacío (solo con
    // el id ya seteado), sin traer los datos reales de la plantilla.
    // TODO: descomentar cuando el SP de detalle ('DP') esté definido:
    // emit(const TemplateFormInitial());
    // try {
    //   final plantilla = await _getPlantilla.call(event.idPlantilla!);
    //   emit(TemplateFormLoaded(plantilla: plantilla));
    // } on AppException catch (e) {
    //   emit(TemplateFormError(e.message));
    // }
    emit(
      TemplateFormLoaded(
        plantilla: Plantilla(
          idPlantilla: event.idPlantilla!,
          nombre: _plantillaVacia.nombre,
          idMeta: _plantillaVacia.idMeta,
          estadoMeta: _plantillaVacia.estadoMeta,
          contenido: _plantillaVacia.contenido,
          archivoRuta: _plantillaVacia.archivoRuta,
          archivoNombre: _plantillaVacia.archivoNombre,
          archivoExt: _plantillaVacia.archivoExt,
          tieneBoton: _plantillaVacia.tieneBoton,
        ),
      ),
    );
  }

  Future<void> _onGuardarPressed(
    TemplateFormGuardarPressed event,
    Emitter<TemplateFormState> emit,
  ) async {
    // No persiste nada todavía — solo refleja los datos armados por la vista
    // en el estado, para que el flujo de UI (ej. navegar de vuelta) siga
    // funcionando de punta a punta sin depender del backend.
    // TODO: descomentar cuando el SP de guardado ('UP') esté definido:
    // emit(TemplateFormLoaded(plantilla: event.plantilla, guardando: true));
    // final result = await _guardarPlantilla.call(event.plantilla);
    // switch (result) {
    //   case CrudOk():
    //     emit(TemplateFormLoaded(plantilla: event.plantilla));
    //   case CrudAlert(:final message) || CrudError(:final message):
    //     emit(TemplateFormError(message));
    //   case CrudNoInternet():
    //     emit(const TemplateFormError('Sin conexión a Internet.'));
    //   case CrudEmpty():
    //     emit(const TemplateFormError('El servidor no respondió.'));
    // }
    emit(TemplateFormLoaded(plantilla: event.plantilla));
  }
}
