// lib/features/chat/presentation/bloc/template_form/template_form_bloc.dart

import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
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
/// `TemplateFormStarted` (modo editar) carga el detalle real
/// (`CRM.CSV_PLANTILLA_LST_APP`, task 'DP'). El guardado (`guardar()`, más
/// abajo) no es un evento — ver por qué en su comentario.
class TemplateFormBloc extends Bloc<TemplateFormEvent, TemplateFormState> {
  final GetPlantillaUseCase _getPlantilla;
  final GuardarPlantillaUseCase _guardarPlantilla;
  final SubirArchivoPlantillaUseCase _subirArchivo;

  TemplateFormBloc({
    required GetPlantillaUseCase getPlantilla,
    required GuardarPlantillaUseCase guardarPlantilla,
    required SubirArchivoPlantillaUseCase subirArchivo,
  }) : _getPlantilla = getPlantilla,
       _guardarPlantilla = guardarPlantilla,
       _subirArchivo = subirArchivo,
       super(const TemplateFormInitial()) {
    on<TemplateFormStarted>(_onStarted);
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

    // Modo editar — trae el detalle real de la plantilla (task 'DP').
    emit(const TemplateFormInitial());
    try {
      final plantilla = await _getPlantilla.call(event.idPlantilla!);
      emit(TemplateFormLoaded(plantilla: plantilla));
    } on AppException catch (e) {
      emit(TemplateFormError(e.message));
    }
  }

  /// Orquesta el guardado completo: si `archivoLocal` no es null (el usuario
  /// eligió/grabó un adjunto en esta sesión y todavía no se subió), primero
  /// lo sube y recién con la ruta/nombre/ext reales del servidor arma la
  /// plantilla a guardar; si es null, guarda directo (sin archivo, o con el
  /// que ya traía la plantilla desde antes, sin tocarlo).
  ///
  /// No pasa por un evento/estado del Bloc a propósito — la vista necesita el
  /// `CrudResult` al toque para decidir si vuelve atrás o se queda mostrando
  /// el error sin perder lo tipeado (todos los campos del formulario viven en
  /// el State local de la vista, no en este Bloc, hasta este momento).
  Future<CrudResult> guardar(Plantilla plantilla, {StagedFile? archivoLocal}) async {
    var aGuardar = plantilla;

    if (archivoLocal != null) {
      final subido = await _subirArchivo.call(
        filePath: archivoLocal.path,
        fileName: '${archivoLocal.nameWithoutExt}${archivoLocal.ext}',
        tipo: archivoLocal.tipo,
      );
      if (subido == null) {
        return const CrudError('No se pudo subir el archivo adjunto.');
      }
      aGuardar = plantilla.copyWith(
        archivoRuta: subido.ruta,
        archivoNombre: subido.nombre,
        archivoExt: subido.ext,
      );
    }

    return _guardarPlantilla.call(aGuardar);
  }
}
