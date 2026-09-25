// Filtro por unidad de negocio (2026-09-25): parseo del login, combos por
// unidad activa y alcance de las tramas de SignalR/FCM.

import 'package:flutter_test/flutter_test.dart';

import 'package:app_crm/core/index_core.dart';

String _login({String unidades = ''}) {
  final c = AppConstants.sepCampos;
  final l = AppConstants.sepListas;
  return 'TOKEN${l}ASE01${c}Asesor${c}a@b.pe${c}${c}${c}0$c$unidades${l}OK';
}

WebSocketMessage _trama(String proceso, List<String> campos) =>
    WebSocketMessage(
      process: proceso,
      records: [campos],
      receivedAt: DateTime(2026, 9, 25),
    );

void main() {
  group('UserModel.unidades', () {
    test('parsea el campo 6 en el orden del login', () {
      final s = AppConstants.sepComodin;
      final user = UserModel.fromRawString(_login(unidades: '3${s}1${s}5'));
      expect(user.unidades, [3, 1, 5]);
    });

    test('sin campo 6 → sin unidades', () {
      expect(UserModel.fromRawString(_login()).unidades, isEmpty);
    });
  });

  test('UnidadNegocioItemModel parsea idUnidad ¦ codigo ¦ nombre', () {
    final c = AppConstants.sepCampos;
    final r = AppConstants.sepRegistros;
    final lista = UnidadNegocioItemModel.parseList(
      '1${c}FMG${c}Proyectos Retail & CPG${r}2${c}AA${c}Asesoría al asociado',
    );
    expect(lista.map((u) => u.codigo), ['FMG', 'AA']);
    expect(lista.last.nombre, 'Asesoría al asociado');
  });

  group('CatalogsLoaded por unidad', () {
    const listas = ListasGenericas(
      campanias: [
        CampaniaItem(id: 10, nombre: 'A1', idUnidad: 1),
        CampaniaItem(id: 20, nombre: 'B1', idUnidad: 2),
      ],
      oportunidades: [
        OportunidadItem(
          id: 100,
          idCampania: 10,
          nombre: 'OpA',
          idMoneda: '',
          importeGeneral: 0,
          importeAsociado: 0,
        ),
        OportunidadItem(
          id: 200,
          idCampania: 20,
          nombre: 'OpB',
          idMoneda: '',
          importeGeneral: 0,
          importeAsociado: 0,
        ),
      ],
      canales: [],
      intereses: [],
      asesores: [
        AsesorItem(codUser: 'X', nombre: 'X', disponible: true, unidades: [1]),
        AsesorItem(codUser: 'Y', nombre: 'Y', disponible: true, unidades: [2]),
      ],
      eventos: [EventoItem(id: 7, idCampania: 20, nombre: 'EvB')],
      unidades: [
        UnidadNegocioItem(id: 1, codigo: 'FMG', nombre: 'Codificación'),
        UnidadNegocioItem(id: 2, codigo: 'EE', nombre: 'Eventos'),
      ],
    );

    test('campañas, oportunidades, eventos y asesores de la unidad activa', () {
      const estado = CatalogsLoaded(listas: listas, idUnidad: 2);
      expect(estado.campanias.map((c) => c.id), [20]);
      expect(estado.oportunidades.map((o) => o.id), [200]);
      expect(estado.eventos.map((e) => e.id), [7]);
      expect(estado.asesoresUnidad.map((a) => a.codUser), ['Y']);
      // `asesores` sigue completo para resolver nombres.
      expect(estado.asesores, hasLength(2));
      expect(estado.nombreUnidad(2), 'Eventos');
    });

    test('sin unidad activa → combos vacíos', () {
      const estado = CatalogsLoaded(listas: listas);
      expect(estado.campanias, isEmpty);
      expect(estado.oportunidades, isEmpty);
      expect(estado.asesoresUnidad, isEmpty);
    });
  });

  group('UnidadTrama.alcance', () {
    setUp(() {
      final s = AppConstants.sepComodin;
      SessionService().setUser(
        UserModel.fromRawString(_login(unidades: '1${s}2')),
      );
      SessionService().setUnidadActiva(1);
    });

    tearDown(SessionService().clear);

    List<String> whatsapp(String idUnidad) => [
      'hola', 'ASE01', '5', 'text', '9', 'wamid', '2026-09-25 10:00', '',
      '0', '0', '999', idUnidad, 'Unidad $idUnidad',
    ];

    test('unidad activa → activa', () {
      expect(
        UnidadTrama.alcance(_trama('MENSAJE_WHATSAPP', whatsapp('1'))),
        AlcanceUnidad.activa,
      );
    });

    test('otra unidad propia → otraPropia, con nombre', () {
      final m = _trama('MENSAJE_WHATSAPP', whatsapp('2'));
      expect(UnidadTrama.alcance(m), AlcanceUnidad.otraPropia);
      expect(UnidadTrama.deMensaje(m)?.nombreUnidad, 'Unidad 2');
    });

    test('unidad que no tiene → ajena', () {
      expect(
        UnidadTrama.alcance(_trama('MENSAJE_WHATSAPP', whatsapp('3'))),
        AlcanceUnidad.ajena,
      );
    });

    test('trama sin unidad (backend viejo) → activa', () {
      final sinUnidad = whatsapp('1').sublist(0, 11);
      expect(
        UnidadTrama.alcance(_trama('MENSAJE_WHATSAPP', sinUnidad)),
        AlcanceUnidad.activa,
      );
    });

    test('NUEVO_LEAD_BOT lee la unidad en [7]', () {
      final m = _trama('NUEVO_LEAD_BOT', [
        '1', 'ASE01', 'Juan', '999', '9', '5', '4', '2', 'Eventos',
      ]);
      expect(UnidadTrama.alcance(m), AlcanceUnidad.otraPropia);
    });

    test('procesos sin unidad (UPDATE_*) → activa', () {
      expect(
        UnidadTrama.alcance(_trama('UPDATE_MENSAJE_WHATSAPP', ['x'])),
        AlcanceUnidad.activa,
      );
    });
  });
}
