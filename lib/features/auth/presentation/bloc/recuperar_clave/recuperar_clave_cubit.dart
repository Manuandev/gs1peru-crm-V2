// lib/features/auth/presentation/bloc/recuperar_clave/recuperar_clave_cubit.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/auth/domain/usecases/recuperar_clave_usecase.dart';
import 'recuperar_clave_state.dart';

class RecuperarClaveCubit extends Cubit<RecuperarClaveState> {
  final RecuperarClaveUseCase _recuperarClaveUseCase;

  RecuperarClaveCubit(this._recuperarClaveUseCase)
      : super(const RecuperarClaveInitial());

  Future<void> enviarCorreo(String correo) async {
    final correoLimpio = correo.trim();

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
      await _recuperarClaveUseCase(correoLimpio);
      emit(const RecuperarClaveExito());
    } on AppException catch (e) {
      emit(RecuperarClaveError(e.message));
    } catch (_) {
      emit(const RecuperarClaveError('Ocurrió un error. Intenta nuevamente.'));
    }
  }
}
