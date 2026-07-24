// lib/features/lead/presentation/widgets/edit_contacto/contacto_form_rows.dart
//
// Modelos de fila para las listas dinámicas de EditContactoPortrait
// (celular/correo/empresa) — atan un TextEditingController a su valor de
// negocio. `localId` es solo para Key de Flutter (identifica la fila en la
// lista aunque se reordene/elimine), nunca se manda al backend.

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';

class NumeroFormRow {
  final int localId;
  int idNumero;
  // Prefijo de celular — catálogo real (PaisItem.codigoTelefono), ya no el
  // paquete country_picker (era un modal, se cambió a combo con búsqueda).
  PaisItem? pais;
  final TextEditingController numeroCtrl;
  bool esPrincipal;
  bool esFavorito;
  bool activo;

  NumeroFormRow({
    required this.localId,
    this.idNumero = 0,
    this.pais,
    String numeroInicial = '',
    this.esPrincipal = false,
    this.esFavorito = false,
    this.activo = true,
  }) : numeroCtrl = TextEditingController(text: numeroInicial);

  void dispose() => numeroCtrl.dispose();
}

class CorreoFormRow {
  final int localId;
  int idCorreo;
  final TextEditingController correoCtrl;
  bool activo;

  CorreoFormRow({
    required this.localId,
    this.idCorreo = 0,
    String correoInicial = '',
    this.activo = true,
  }) : correoCtrl = TextEditingController(text: correoInicial);

  void dispose() => correoCtrl.dispose();
}

class EmpresaFormRow {
  final int localId;
  int idEmpresaContacto;
  int idEmpresa;
  final TextEditingController nombreCtrl;
  final TextEditingController rucCtrl;
  final TextEditingController razonSocialCtrl;
  final TextEditingController direccionCtrl;
  // Catálogo real — País (PaisItem), Área/Cargo (SYSTABEXTER02 CODTABLA='AOF'
  // / DBO.SYSMCARGO01), ya no texto libre, ver lead/CLAUDE.md.
  PaisItem? pais;
  AreaItem? area;
  CargoItem? cargo;
  // Ubigeo propio de la empresa (T_EMPRESA.UBIGEO) — independiente del
  // ubigeo del contacto.
  UbigeoItem? departamento;
  UbigeoItem? provincia;
  UbigeoItem? distrito;
  bool expandido;
  // Autocompletado por RUC (Clientes/BuscarDocumento) — foco propio por fila
  // ya que la lista es dinámica; ver EditContactoPortrait._buscarRuc.
  final FocusNode rucFocus = FocusNode();
  String ultimoRucBuscado = '';

  EmpresaFormRow({
    required this.localId,
    this.idEmpresaContacto = 0,
    this.idEmpresa = 0,
    String nombreInicial = '',
    String rucInicial = '',
    String razonSocialInicial = '',
    String direccionInicial = '',
    this.pais,
    this.area,
    this.cargo,
    this.expandido = false,
  }) : nombreCtrl = TextEditingController(text: nombreInicial),
       rucCtrl = TextEditingController(text: rucInicial),
       razonSocialCtrl = TextEditingController(text: razonSocialInicial),
       direccionCtrl = TextEditingController(text: direccionInicial);

  String get subtitulo => [
    cargo?.nombre ?? '',
    area?.nombre ?? '',
  ].where((s) => s.trim().isNotEmpty).join(' · ');

  void dispose() {
    nombreCtrl.dispose();
    rucCtrl.dispose();
    razonSocialCtrl.dispose();
    direccionCtrl.dispose();
    rucFocus.dispose();
  }
}
