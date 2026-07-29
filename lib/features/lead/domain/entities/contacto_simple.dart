// lib/features/lead/domain/entities/contacto_simple.dart
//
// Aggregate reducido de un contacto — usado solo por EditContactoSimple
// (pantalla "Editar datos básicos", pedido de negocio 2026-07-27: solo
// tipo/número documento, nacionalidad, prefijo (saludo), nombres, apellidos,
// cargo, UN celular, UN correo y UNA empresa (ruc/razón social). Distinto de
// [ContactoDetalle] (aggregate completo de EditContacto, con listas de
// N celulares/correos/empresas) — esa pantalla completa sigue existiendo
// intacta, esta es una alternativa más simple, no un reemplazo.
// idContacto == 0 → todavía no existe contacto para este número (pantalla
// arranca en modo "crear"). idNumero es el ancla — el número desde el que
// se abrió la pantalla; el celular editable es siempre el que corresponde
// a ese mismo idNumero (nunca otro, aunque el contacto tenga más números).

import 'package:app_crm/index_dependencies.dart';

class ContactoSimple extends Equatable {
  final int idContacto;
  final int idNumero; // ancla — el número desde el que se abrió la pantalla
  final String idTipoDocumento;
  final String numeroDocumento;
  final String idNacionalidad;
  final String prefijoContacto; // saludo: Estimado/Estimada — sin catálogo de backend con id/label, PrefijoContactoItem.valor
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String prefijoCelular; // código de país, ej. '+51'
  final String celular;
  final int idCorreo;
  final String correo;
  final int idEmpresaContacto;
  final String ruc;
  final String razonSocial;
  final String idCargo;

  const ContactoSimple({
    this.idContacto = 0,
    this.idNumero = 0,
    this.idTipoDocumento = '',
    this.numeroDocumento = '',
    this.idNacionalidad = '',
    this.prefijoContacto = '',
    this.nombre = '',
    this.apellidoPaterno = '',
    this.apellidoMaterno = '',
    this.prefijoCelular = '',
    this.celular = '',
    this.idCorreo = 0,
    this.correo = '',
    this.idEmpresaContacto = 0,
    this.ruc = '',
    this.razonSocial = '',
    this.idCargo = '',
  });

  ContactoSimple copyWith({
    int? idContacto,
    int? idNumero,
    String? idTipoDocumento,
    String? numeroDocumento,
    String? idNacionalidad,
    String? prefijoContacto,
    String? nombre,
    String? apellidoPaterno,
    String? apellidoMaterno,
    String? prefijoCelular,
    String? celular,
    int? idCorreo,
    String? correo,
    int? idEmpresaContacto,
    String? ruc,
    String? razonSocial,
    String? idCargo,
  }) {
    return ContactoSimple(
      idContacto: idContacto ?? this.idContacto,
      idNumero: idNumero ?? this.idNumero,
      idTipoDocumento: idTipoDocumento ?? this.idTipoDocumento,
      numeroDocumento: numeroDocumento ?? this.numeroDocumento,
      idNacionalidad: idNacionalidad ?? this.idNacionalidad,
      prefijoContacto: prefijoContacto ?? this.prefijoContacto,
      nombre: nombre ?? this.nombre,
      apellidoPaterno: apellidoPaterno ?? this.apellidoPaterno,
      apellidoMaterno: apellidoMaterno ?? this.apellidoMaterno,
      prefijoCelular: prefijoCelular ?? this.prefijoCelular,
      celular: celular ?? this.celular,
      idCorreo: idCorreo ?? this.idCorreo,
      correo: correo ?? this.correo,
      idEmpresaContacto: idEmpresaContacto ?? this.idEmpresaContacto,
      ruc: ruc ?? this.ruc,
      razonSocial: razonSocial ?? this.razonSocial,
      idCargo: idCargo ?? this.idCargo,
    );
  }

  @override
  List<Object?> get props => [
    idContacto,
    idNumero,
    idTipoDocumento,
    numeroDocumento,
    idNacionalidad,
    prefijoContacto,
    nombre,
    apellidoPaterno,
    apellidoMaterno,
    prefijoCelular,
    celular,
    idCorreo,
    correo,
    idEmpresaContacto,
    ruc,
    razonSocial,
    idCargo,
  ];
}
