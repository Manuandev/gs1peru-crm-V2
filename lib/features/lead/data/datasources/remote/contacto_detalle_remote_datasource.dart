// lib/features/lead/data/datasources/remote/contacto_detalle_remote_datasource.dart
//
// TODO: reemplazar toda la implementación mock por llamadas reales al backend
//       cuando se definan los SPs correspondientes.

import 'package:app_crm/features/lead/index_lead.dart';

class ContactoDetalleRemoteDatasource {
  Future<ContactoDetalleModel> obtenerDetalleContacto(int idContacto) async {
    // TODO: reemplazar por SP real — ej: '[CRM].[SP_ContactoDetalleLst]'
    await Future.delayed(const Duration(milliseconds: 800));

    return ContactoDetalleModel(
      idContacto: idContacto,
      nombre: 'Carla',
      apellido: 'Rojas Méndez',
      cargo: 'Community Manager',
      empresa: 'Estudio Creativo',
      tipoDocumento: 'DNI',
      numDocumento: '70912036',
      prefijo: '+51',
      numero: '987 654 321',
      correo: 'carla.rojas@estudiocreativo.pe',
      fechaRegistro: '2025-11-12 00:00:00',
      direccion: 'Av. La Marina 2355, San Miguel',
      departamento: 'Lima',
      provincia: 'Lima',
      distrito: 'San Miguel',
    );
  }

  Future<List<LeadModel>> obtenerNegociacionesDeContacto(
    int idContacto,
  ) async {
    // TODO: reemplazar por SP real — ej: '[CRM].[SP_NegociacionesPorContacto]'
    await Future.delayed(const Duration(milliseconds: 600));

    return [
      LeadModel(
        idLead: 1001,
        idContacto: idContacto,
        nombre: 'Carla',
        apellido: 'Rojas Méndez',
        nombreEmpresa: 'Estudio Creativo',
        asesor: '001',
        fechaHora: '2026-05-28 10:00:00',
        idNumero: 1,
        prefijo: '+51',
        numero: '987654321',
        isFavorito: false,
        correo: 'carla.rojas@estudiocreativo.pe',
        idEstado: '00',
        estado: 'Nuevo',
        idCampania: 1,
        campania: 'Campaña 2026',
        idEvento: 1,
        evento: 'Branding Digital',
        idCanal: 1,
        canal: 'WhatsApp',
        idInteres: 1,
        interes: 'Diseño',
        ibChat: true,
        monto: 0.0,
      ),
      LeadModel(
        idLead: 1002,
        idContacto: idContacto,
        nombre: 'Carla',
        apellido: 'Rojas Méndez',
        nombreEmpresa: 'Estudio Creativo',
        asesor: '001',
        fechaHora: '2026-05-28 11:00:00',
        idNumero: 1,
        prefijo: '+51',
        numero: '987654321',
        isFavorito: false,
        correo: 'carla.rojas@estudiocreativo.pe',
        idEstado: '01',
        estado: 'En desarrollo',
        idCampania: 1,
        campania: 'Campaña 2026',
        idEvento: 1,
        evento: 'Branding Digital',
        idCanal: 4,
        canal: 'Instagram',
        idInteres: 1,
        interes: 'Diseño',
        ibChat: false,
        monto: 0.0,
      ),
      LeadModel(
        idLead: 1003,
        idContacto: idContacto,
        nombre: 'Carla',
        apellido: 'Rojas Méndez',
        nombreEmpresa: 'Estudio Creativo',
        asesor: '001',
        fechaHora: '2026-05-20 12:00:00',
        idNumero: 1,
        prefijo: '+51',
        numero: '987654321',
        isFavorito: false,
        correo: 'carla.rojas@estudiocreativo.pe',
        idEstado: '02',
        estado: 'Propuesta',
        idCampania: 1,
        campania: 'Campaña 2026',
        idEvento: 1,
        evento: 'Branding Digital',
        idCanal: 7,
        canal: 'Web',
        idInteres: 1,
        interes: 'Diseño',
        ibChat: false,
        monto: 50.0,
      ),
      LeadModel(
        idLead: 1004,
        idContacto: idContacto,
        nombre: 'Carla',
        apellido: 'Rojas Méndez',
        nombreEmpresa: 'Estudio Creativo',
        asesor: '001',
        fechaHora: '2026-04-20 13:00:00',
        idNumero: 1,
        prefijo: '+51',
        numero: '987654321',
        isFavorito: false,
        correo: 'carla.rojas@estudiocreativo.pe',
        idEstado: '04',
        estado: 'Cobranza',
        idCampania: 1,
        campania: 'Campaña 2026',
        idEvento: 1,
        evento: 'Branding Digital',
        idCanal: 1,
        canal: 'WhatsApp',
        idInteres: 1,
        interes: 'Diseño',
        ibChat: false,
        monto: 50.0,
      ),
    ];
  }
}
