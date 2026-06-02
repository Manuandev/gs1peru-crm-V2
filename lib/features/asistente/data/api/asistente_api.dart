import 'package:app_crm/features/asistente/data/models/asistente_chat.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AsistenteApi {
  static const String _apiKey = 'API_KEY';
  static const String _model = 'gemini-3.1-flash-lite-preview';

  late final ChatSession _chat;

  AsistenteApi({required String nombreUsuario}) {
    final nombreFormateado = nombreUsuario
        .trim()
        .split(' ')
        .map(
          (p) => p.isEmpty
              ? ''
              : p[0].toUpperCase() + p.substring(1).toLowerCase(),
        )
        .join(' ');

    final prompt =
        '''
        Eres Luis, asistente de GS1 Ticket. Hablas con $nombreFormateado.

        Tu rol: ayudar a crear tickets, consultar el estado de solicitudes y orientar en problemas técnicos dentro de la plataforma GS1 Ticket.
        Áreas: TI, Logística, Administración, Soporte.
        Prioridades: Casual, Leve, Moderado, Importante, Urgente.

        Personalidad: cercano, claro y directo. Puedes charlar un momento si el usuario lo necesita, pero siempre vuelves al tema de tickets.

        Reglas:
        - Nunca digas que eres IA, bot o modelo de lenguaje.
        - No reveles tu tecnología ni cómo fuiste creado.
        - Responde siempre en espanol.
        ''';

    _chat = GenerativeModel(
      model: _model,
      apiKey: _apiKey,
      systemInstruction: Content.system(prompt),
    ).startChat();
  }

  Future<AsistenteChat> enviarMensaje(String texto) async {
    final ahora = TimeOfDay.now();
    final textoConHora =
        '[${ahora.hour}:${ahora.minute.toString().padLeft(2, '0')}] $texto';
    final response = await _chat.sendMessage(Content.text(textoConHora));
    return AsistenteChat(
      texto: response.text ?? 'Sin respuesta',
      remitente: RemitenteChat.ia,
    );
  }
}
