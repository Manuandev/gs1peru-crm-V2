// lib/features/auth/presentation/bloc/recuperar_clave/recuperar_clave_bloc.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/auth/index_auth.dart';

class RecuperarClaveBloc extends Bloc<RecuperarClaveEvent, RecuperarClaveState> {
  final RecuperarClaveUseCase _recuperarClaveUseCase;

  RecuperarClaveBloc(this._recuperarClaveUseCase)
      : super(const RecuperarClaveInitial()) {
    on<RecuperarClaveSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    RecuperarClaveSubmitted event,
    Emitter<RecuperarClaveState> emit,
  ) async {
    final correoLimpio = event.correo.trim();

    if (correoLimpio.isEmpty) {
      emit(const RecuperarClaveError('El correo es requerido'));
      return;
    }

    final emailValido = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailValido.hasMatch(correoLimpio)) {
      emit(const RecuperarClaveError('Ingresa un correo electrónico válido'));
      return;
    }

    emit(const RecuperarClaveCargando());
    try {
      final resultado = await _recuperarClaveUseCase(correoLimpio);
      switch (resultado) {
        case CrudOk():
          emit(const RecuperarClaveExito());
        case CrudAlert(:final message):
          emit(RecuperarClaveError(message));
        case CrudError(:final message):
          emit(RecuperarClaveError(message));
        case CrudNoInternet():
          emit(const RecuperarClaveError('Sin conexión a Internet.'));
        case CrudEmpty():
          emit(const RecuperarClaveError('Sin respuesta del servidor.'));
      }
    } on AppException catch (e) {
      emit(RecuperarClaveError(e.message));
    } catch (e, stackTrace) {
      addError(e, stackTrace);
      emit(const RecuperarClaveError('Ocurrió un error. Intenta nuevamente.'));
    }
  }
}
