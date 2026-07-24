// lib/features/lead/domain/entities/contacto_detalle.dart
//
// Aggregate editable completo de un contacto — usado solo por la pantalla
// EditContacto (crear/editar). Distinto de [Contacto] (identidad liviana
// usada en el listado de Seguimiento) porque acá se necesitan campos que
// ese modelo no trae: documento, nacionalidad, ubicación, LinkedIn, y las
// listas completas de números/correos/empresas (no solo el primero de cada
// uno). idContacto == 0 → todavía no existe contacto para este número
// (pantalla arranca en modo "crear").

import 'package:app_crm/index_dependencies.dart';
import 'numero_contacto.dart';
import 'correo_contacto.dart';
import 'empresa_contacto.dart';

class ContactoDetalle extends Equatable {
  final int idContacto;
  final int idNumero; // ancla — el número desde el que se abrió la pantalla
  final String prefijoContacto; // saludo: Estimado/Estimada — sin catálogo de backend
  final String linkedin;
  final String idTipoDocumento;
  final String numeroDocumento;
  final String idNacionalidad;
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String idPais;
  final String idDepartamento;
  final String idProvincia;
  final String idDistrito;
  final String direccion;
  final List<NumeroContacto> numeros;
  final List<CorreoContacto> correos;
  final List<EmpresaContacto> empresas;

  const ContactoDetalle({
    this.idContacto = 0,
    this.idNumero = 0,
    this.prefijoContacto = '',
    this.linkedin = '',
    this.idTipoDocumento = '',
    this.numeroDocumento = '',
    this.idNacionalidad = '',
    this.nombre = '',
    this.apellidoPaterno = '',
    this.apellidoMaterno = '',
    this.idPais = '',
    this.idDepartamento = '',
    this.idProvincia = '',
    this.idDistrito = '',
    this.direccion = '',
    this.numeros = const [],
    this.correos = const [],
    this.empresas = const [],
  });

  ContactoDetalle copyWith({
    int? idContacto,
    int? idNumero,
    String? prefijoContacto,
    String? linkedin,
    String? idTipoDocumento,
    String? numeroDocumento,
    String? idNacionalidad,
    String? nombre,
    String? apellidoPaterno,
    String? apellidoMaterno,
    String? idPais,
    String? idDepartamento,
    String? idProvincia,
    String? idDistrito,
    String? direccion,
    List<NumeroContacto>? numeros,
    List<CorreoContacto>? correos,
    List<EmpresaContacto>? empresas,
  }) {
    return ContactoDetalle(
      idContacto: idContacto ?? this.idContacto,
      idNumero: idNumero ?? this.idNumero,
      prefijoContacto: prefijoContacto ?? this.prefijoContacto,
      linkedin: linkedin ?? this.linkedin,
      idTipoDocumento: idTipoDocumento ?? this.idTipoDocumento,
      numeroDocumento: numeroDocumento ?? this.numeroDocumento,
      idNacionalidad: idNacionalidad ?? this.idNacionalidad,
      nombre: nombre ?? this.nombre,
      apellidoPaterno: apellidoPaterno ?? this.apellidoPaterno,
      apellidoMaterno: apellidoMaterno ?? this.apellidoMaterno,
      idPais: idPais ?? this.idPais,
      idDepartamento: idDepartamento ?? this.idDepartamento,
      idProvincia: idProvincia ?? this.idProvincia,
      idDistrito: idDistrito ?? this.idDistrito,
      direccion: direccion ?? this.direccion,
      numeros: numeros ?? this.numeros,
      correos: correos ?? this.correos,
      empresas: empresas ?? this.empresas,
    );
  }

  @override
  List<Object?> get props => [
    idContacto,
    idNumero,
    prefijoContacto,
    linkedin,
    idTipoDocumento,
    numeroDocumento,
    idNacionalidad,
    nombre,
    apellidoPaterno,
    apellidoMaterno,
    idPais,
    idDepartamento,
    idProvincia,
    idDistrito,
    direccion,
    numeros,
    correos,
    empresas,
  ];
}
