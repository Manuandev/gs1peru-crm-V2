// lib/features/lead/domain/entities/empresa_contacto.dart
//
// Empresa asociada a un contacto (T_EMPRESA / T_EMPRESA_CONTACTO). Área y
// Cargo usan catálogo real (AreaItem/CargoItem, ver lead/CLAUDE.md).
// idDepartamento/idProvincia/idDistrito son T_EMPRESA.UBIGEO partido en 3
// (2 dígitos c/u) — mismo patrón que ContactoDetalle.

import 'package:app_crm/index_dependencies.dart';

class EmpresaContacto extends Equatable {
  final int idEmpresaContacto;
  final int idEmpresa;
  final String nombreEmpresa;
  final String idPais;
  final String ruc;
  final String razonSocial;
  final String direccion;
  final String area;
  final String cargo;
  final String idDepartamento;
  final String idProvincia;
  final String idDistrito;

  const EmpresaContacto({
    this.idEmpresaContacto = 0,
    this.idEmpresa = 0,
    this.nombreEmpresa = '',
    this.idPais = '',
    this.ruc = '',
    this.razonSocial = '',
    this.direccion = '',
    this.area = '',
    this.cargo = '',
    this.idDepartamento = '',
    this.idProvincia = '',
    this.idDistrito = '',
  });

  EmpresaContacto copyWith({
    int? idEmpresaContacto,
    int? idEmpresa,
    String? nombreEmpresa,
    String? idPais,
    String? ruc,
    String? razonSocial,
    String? direccion,
    String? area,
    String? cargo,
    String? idDepartamento,
    String? idProvincia,
    String? idDistrito,
  }) {
    return EmpresaContacto(
      idEmpresaContacto: idEmpresaContacto ?? this.idEmpresaContacto,
      idEmpresa: idEmpresa ?? this.idEmpresa,
      nombreEmpresa: nombreEmpresa ?? this.nombreEmpresa,
      idPais: idPais ?? this.idPais,
      ruc: ruc ?? this.ruc,
      razonSocial: razonSocial ?? this.razonSocial,
      direccion: direccion ?? this.direccion,
      area: area ?? this.area,
      cargo: cargo ?? this.cargo,
      idDepartamento: idDepartamento ?? this.idDepartamento,
      idProvincia: idProvincia ?? this.idProvincia,
      idDistrito: idDistrito ?? this.idDistrito,
    );
  }

  @override
  List<Object?> get props => [
    idEmpresaContacto,
    idEmpresa,
    nombreEmpresa,
    idPais,
    ruc,
    razonSocial,
    direccion,
    area,
    cargo,
    idDepartamento,
    idProvincia,
    idDistrito,
  ];
}
