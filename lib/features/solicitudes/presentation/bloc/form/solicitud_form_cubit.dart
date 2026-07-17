// lib/features/solicitudes/presentation/bloc/form/solicitud_form_cubit.dart

import 'package:app_crm/index_dependencies.dart'; // Cubit, PlatformFile

part 'solicitud_form_state.dart';

class SolicitudFormCubit extends Cubit<SolicitudFormState> {
  SolicitudFormCubit() : super(const SolicitudFormState());

  /// 'Tipo de persona' (Jurídica/Natural) es un solo dato compartido por los
  /// pasos 1 y 3 del wizard — cambiarlo en cualquiera de los dos se refleja
  /// en el otro y en el resumen.
  void cambiarTipoPersona(String tipoPersona) =>
      emit(state.copyWith(tipoPersona: tipoPersona));

  void guardarSolicitante(DatosSolicitante datos) =>
      emit(state.copyWith(solicitante: datos));

  void guardarFacturacion(DatosFacturacion datos) =>
      emit(state.copyWith(facturacion: datos));

  /// Setea/actualiza el NUMSOL — llamado una vez al entrar al wizard (con
  /// el NUMSOL real si se edita una solicitud existente, o vacío si es
  /// creación) y de nuevo tras el primer guardado exitoso de una solicitud
  /// nueva, con el NUMSOL que generó el backend.
  void actualizarNumSol(String numSol) => emit(state.copyWith(numSol: numSol));

  /// Bloquea cantidad/importe/moneda del wizard a los valores ya definidos
  /// en la negociación de origen — llamado una sola vez, al crear una
  /// solicitud nueva desde "Generar solicitud" (nunca al editar una ya
  /// existente). Ver `SolicitudFormState.cantidadEsperada`.
  ///
  /// Los datos de contacto (`nombres`/`apellidoPaterno`/`apellidoMaterno`/
  /// `nombreEmpresa`/`correo`/`celular`/`celularCodigoTelefono`/`cargo`) y
  /// `precioTotal` son solo de **prellenado/referencia** — a diferencia de
  /// cantidad/precioBase/descuento/moneda, no bloquean nada; el asesor puede
  /// editarlos en el paso 1 como cualquier otro dato. Ver
  /// solicitudes/CLAUDE.md.
  void sembrarDatosNegociacion({
    required int cantidad,
    required double precioBase,
    required double descuento,
    required String idMoneda,
    double precioTotal = 0,
    String nombres = '',
    String apellidoPaterno = '',
    String apellidoMaterno = '',
    String nombreEmpresa = '',
    String correo = '',
    String celular = '',
    String celularCodigoTelefono = '',
    String ruc = '',
    String cargo = '',
  }) => emit(
    state.copyWith(
      cantidadEsperada: cantidad,
      precioBaseLead: precioBase,
      descuentoLead: descuento,
      idMonedaBloqueada: idMoneda,
      precioTotalLead: precioTotal,
      nombresLead: nombres,
      apellidoPaternoLead: apellidoPaterno,
      apellidoMaternoLead: apellidoMaterno,
      nombreEmpresaLead: nombreEmpresa,
      correoLead: correo,
      celularLead: celular,
      celularCodigoTelefonoLead: celularCodigoTelefono,
      rucLead: ruc,
      cargoLead: cargo,
    ),
  );

  /// Voucher/O.C. adjuntados en el paso 1 — viven acá (no en el estado local
  /// de la vista) para que sobrevivan hasta Resumen y "Generar solicitud"
  /// pueda subirlos con el NUMSOL recién confirmado.
  void guardarArchivoVoucher(PlatformFile archivo) =>
      emit(state.copyWith(archivoVoucher: archivo));

  void quitarArchivoVoucher() =>
      emit(state.copyWith(limpiarArchivoVoucher: true));

  void guardarArchivoOC(PlatformFile archivo) =>
      emit(state.copyWith(archivoOC: archivo));

  void quitarArchivoOC() => emit(state.copyWith(limpiarArchivoOC: true));
}
