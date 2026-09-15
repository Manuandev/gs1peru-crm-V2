// lib/features/chat/presentation/widgets/chat_detail/audio/aac_m4a_muxer.dart

import 'dart:io';
import 'dart:typed_data';

/// Empaqueta un archivo AAC crudo (frames ADTS, lo que entrega
/// `AudioRecorder.startStream` con `AudioEncoder.aacLc`) en un contenedor
/// `.m4a` (MP4) — sin re-codificar, solo reordena bytes.
///
/// Por qué existe: el `.m4a` que graba `record` en modo archivo no se puede
/// reproducir hasta hacer `stop()` (el índice MP4 se escribe al final), así que
/// no permite "pausar → escuchar → continuar" como WhatsApp. En modo stream el
/// AAC/ADTS sí se puede cortar en cualquier punto; esta clase lo convierte a
/// `.m4a` para la vista previa y para el envío (mismo formato que el backend y
/// WhatsApp ya reciben hoy).
class AacM4aMuxer {
  AacM4aMuxer._();

  static const List<int> _sampleRates = [
    96000, 88200, 64000, 48000, 44100, 32000,
    24000, 22050, 16000, 12000, 11025, 8000, 7350,
  ];

  /// AAC-LC: cada frame trae 1024 muestras.
  static const int _muestrasPorFrame = 1024;

  /// Convierte [origenAac] → [destinoM4a]. Devuelve `false` si el archivo no
  /// tiene ningún frame ADTS válido (grabación vacía o corrupta).
  static Future<bool> convertir(String origenAac, String destinoM4a) async {
    final origen = File(origenAac);
    if (!await origen.exists()) return false;

    final bytes = await origen.readAsBytes();
    final m4a = _empaquetar(bytes);
    if (m4a == null) return false;

    await File(destinoM4a).writeAsBytes(m4a, flush: true);
    return true;
  }

  static Uint8List? _empaquetar(Uint8List adts) {
    // ── 1. Recorrer los frames ADTS ──────────────────────────────────────
    final tamanios = <int>[];
    final datos = BytesBuilder(copy: false);
    int? perfil, indiceFrecuencia, canales;

    var i = 0;
    while (i + 7 <= adts.length) {
      // syncword 0xFFF
      if (adts[i] != 0xFF || (adts[i + 1] & 0xF0) != 0xF0) {
        i++;
        continue;
      }
      final sinCrc = (adts[i + 1] & 0x01) == 1;
      final cabecera = sinCrc ? 7 : 9;
      final largoFrame =
          ((adts[i + 3] & 0x03) << 11) | (adts[i + 4] << 3) | (adts[i + 5] >> 5);

      if (largoFrame <= cabecera) {
        i++;
        continue;
      }
      // Último frame cortado a la mitad (se pausó/escribió justo ahí) → se descarta
      if (i + largoFrame > adts.length) break;

      perfil ??= (adts[i + 2] >> 6) & 0x03;
      indiceFrecuencia ??= (adts[i + 2] >> 2) & 0x0F;
      canales ??= ((adts[i + 2] & 0x01) << 2) | (adts[i + 3] >> 6);

      tamanios.add(largoFrame - cabecera);
      datos.add(Uint8List.sublistView(adts, i + cabecera, i + largoFrame));
      i += largoFrame;
    }

    if (tamanios.isEmpty ||
        indiceFrecuencia == null ||
        indiceFrecuencia >= _sampleRates.length) {
      return null;
    }

    final sampleRate = _sampleRates[indiceFrecuencia];
    final objetoAudio = perfil! + 1; // ADTS guarda perfil = audioObjectType - 1
    final frames = tamanios.length;
    final duracionMuestras = frames * _muestrasPorFrame;
    final duracionMs = duracionMuestras * 1000 ~/ sampleRate;
    final mdatDatos = datos.takeBytes();

    // AudioSpecificConfig (2 bytes): objeto(5) · frecuencia(4) · canales(4) · 000
    final asc = [
      (objetoAudio << 3) | (indiceFrecuencia >> 1),
      ((indiceFrecuencia & 0x01) << 7) | (canales! << 3),
    ];

    final ftyp = _caja('ftyp', [
      ..._ascii('M4A '),
      ..._u32(0),
      ..._ascii('M4A '),
      ..._ascii('isom'),
      ..._ascii('mp42'),
    ]);

    // moov va antes que mdat (reproducción progresiva por URL) — su tamaño no
    // depende del offset, así que se arma una vez para medir y otra con el real.
    List<int> armarMoov(int offsetDatos) => _moov(
      sampleRate: sampleRate,
      canales: canales!,
      asc: asc,
      tamanios: tamanios,
      duracionMs: duracionMs,
      duracionMuestras: duracionMuestras,
      offsetDatos: offsetDatos,
    );

    final largoMoov = armarMoov(0).length;
    final moov = armarMoov(ftyp.length + largoMoov + 8);

    final salida = BytesBuilder(copy: false)
      ..add(ftyp)
      ..add(moov)
      ..add(_u32(8 + mdatDatos.length))
      ..add(_ascii('mdat'))
      ..add(mdatDatos);
    return salida.takeBytes();
  }

  static List<int> _moov({
    required int sampleRate,
    required int canales,
    required List<int> asc,
    required List<int> tamanios,
    required int duracionMs,
    required int duracionMuestras,
    required int offsetDatos,
  }) {
    const matriz = [0x00010000, 0, 0, 0, 0x00010000, 0, 0, 0, 0x40000000];

    final mvhd = _cajaCompleta('mvhd', 0, [
      ..._u32(0), // creación
      ..._u32(0), // modificación
      ..._u32(1000), // timescale
      ..._u32(duracionMs),
      ..._u32(0x00010000), // rate 1.0
      ..._u16(0x0100), // volumen 1.0
      ...List.filled(10, 0),
      for (final m in matriz) ..._u32(m),
      ...List.filled(24, 0),
      ..._u32(2), // next_track_ID
    ]);

    final tkhd = _cajaCompleta('tkhd', 0x000007, [
      ..._u32(0),
      ..._u32(0),
      ..._u32(1), // track_ID
      ..._u32(0),
      ..._u32(duracionMs),
      ...List.filled(8, 0),
      ..._u16(0), // layer
      ..._u16(0), // alternate_group
      ..._u16(0x0100), // volumen
      ..._u16(0),
      for (final m in matriz) ..._u32(m),
      ..._u32(0), // ancho
      ..._u32(0), // alto
    ]);

    final mdhd = _cajaCompleta('mdhd', 0, [
      ..._u32(0),
      ..._u32(0),
      ..._u32(sampleRate),
      ..._u32(duracionMuestras),
      ..._u16(0x55C4), // idioma 'und'
      ..._u16(0),
    ]);

    final hdlr = _cajaCompleta('hdlr', 0, [
      ..._u32(0),
      ..._ascii('soun'),
      ...List.filled(12, 0),
      ..._ascii('SoundHandler'),
      0,
    ]);

    final smhd = _cajaCompleta('smhd', 0, [..._u16(0), ..._u16(0)]);

    final dinf = _caja('dinf', [
      ..._cajaCompleta('dref', 0, [
        ..._u32(1),
        ..._cajaCompleta('url ', 0x000001, const []),
      ]),
    ]);

    // esds — descriptores MPEG-4 con largos de 1 byte (todos < 128)
    final dsi = [0x05, asc.length, ...asc];
    final dcd = [
      0x04,
      13 + dsi.length,
      0x40, // AAC
      0x15, // audio stream
      0, 0, 0, // bufferSizeDB
      ..._u32(0), // maxBitrate
      ..._u32(0), // avgBitrate
      ...dsi,
    ];
    const sl = [0x06, 0x01, 0x02];
    final esDescriptor = [
      0x03,
      3 + dcd.length + sl.length,
      ..._u16(1), // ES_ID
      0x00,
      ...dcd,
      ...sl,
    ];
    final esds = _cajaCompleta('esds', 0, esDescriptor);

    final mp4a = _caja('mp4a', [
      ...List.filled(6, 0),
      ..._u16(1), // data_reference_index
      ..._u16(0), // versión
      ..._u16(0), // revisión
      ..._u32(0), // vendor
      ..._u16(canales),
      ..._u16(16), // bits por muestra
      ..._u16(0),
      ..._u16(0),
      ..._u32(sampleRate << 16), // 16.16
      ...esds,
    ]);

    final stbl = _caja('stbl', [
      ..._cajaCompleta('stsd', 0, [..._u32(1), ...mp4a]),
      ..._cajaCompleta('stts', 0, [
        ..._u32(1),
        ..._u32(tamanios.length),
        ..._u32(_muestrasPorFrame),
      ]),
      ..._cajaCompleta('stsc', 0, [
        ..._u32(1),
        ..._u32(1), // first_chunk
        ..._u32(tamanios.length), // todo en un solo chunk
        ..._u32(1),
      ]),
      ..._cajaCompleta('stsz', 0, [
        ..._u32(0),
        ..._u32(tamanios.length),
        for (final t in tamanios) ..._u32(t),
      ]),
      ..._cajaCompleta('stco', 0, [..._u32(1), ..._u32(offsetDatos)]),
    ]);

    final minf = _caja('minf', [...smhd, ...dinf, ...stbl]);
    final mdia = _caja('mdia', [...mdhd, ...hdlr, ...minf]);
    final trak = _caja('trak', [...tkhd, ...mdia]);
    return _caja('moov', [...mvhd, ...trak]);
  }

  // ── Helpers de bytes (big-endian) ──────────────────────────────────────

  static List<int> _caja(String tipo, List<int> contenido) => [
    ..._u32(8 + contenido.length),
    ..._ascii(tipo),
    ...contenido,
  ];

  static List<int> _cajaCompleta(String tipo, int flags, List<int> contenido) =>
      _caja(tipo, [0, ..._u24(flags), ...contenido]);

  static List<int> _u32(int v) =>
      [(v >> 24) & 0xFF, (v >> 16) & 0xFF, (v >> 8) & 0xFF, v & 0xFF];

  static List<int> _u24(int v) => [(v >> 16) & 0xFF, (v >> 8) & 0xFF, v & 0xFF];

  static List<int> _u16(int v) => [(v >> 8) & 0xFF, v & 0xFF];

  static List<int> _ascii(String s) => s.codeUnits;
}
