// lib/config/env/env_config.dart

enum Environment { dev, qa, prod }

class EnvConfig {
  // Entorno actual (cámbialo según necesites)
  static const Environment current = Environment.qa;

  // Versión mostrada en footer/drawer y comparada contra AppUpdateService —
  // antes vivía en AppConstants.version como constante suelta, sin relación
  // con el entorno; había que acordarse de cambiarla a mano junto con
  // `current` antes de cada build (fuente real del bug: quedaban
  // desincronizadas). Ahora es un solo interruptor (`current`) para ambas.
  static String get version {
    switch (current) {
      case Environment.dev:
      case Environment.qa:
        return '1.0.13';
      case Environment.prod:
        return '1.0.0.1';
    }
  }

  // Configuración según entorno
  static String get baseUrl {
    switch (current) {
      case Environment.dev:
        return 'https://expediter-falsify-spinach.ngrok-free.dev/'; // URL DE DEV
      case Environment.qa:
        return 'https://natcodee.net:40805/gs1pe_interfaz/'; // URL DE QA
      // return 'https://expediter-falsify-spinach.ngrok-free.dev/'; // URL DE QA
      case Environment.prod:
        return 'https://apicommerce.gs1pe.org.pe/'; // URL DE PRODUCCION
    }
  }

  static String get urlArchivos {
    switch (current) {
      case Environment.dev:
        return 'https://natcodee.net:40805/archivos_wsp_gs1/'; // URL DE DEV
      case Environment.qa:
        return 'https://natcodee.net:40805/archivos_wsp_gs1/'; // URL DE QA
      case Environment.prod:
        return 'https://gs1tokenfile.gs1pe.org.pe/'; // URL DE PRODUCCION
    }
  }

  static String get urlWebSocket {
    switch (current) {
      case Environment.dev:
        return 'https://natcodee.net:9002/socket/'; // URL DE DEV
      case Environment.qa:
        return 'https://natcodee.net:9002/socket/'; // URL DE QA
      case Environment.prod:
        return 'https://intranet.gs1pe.org.pe:9005/socket/'; // URL DE PRODUCCION
    }
  }

  // Certificado intermedio que el servidor no envía en el handshake TLS —
  // sin él, Android con parches de seguridad desactualizados no arma la
  // cadena de confianza y el socket nunca conecta (dev y qa comparten host,
  // natcodee.net, por eso comparten certificado).
  static String get certificadoConfianza {
    switch (current) {
      case Environment.dev:
      case Environment.qa:
        return 'assets/certs/natcodee_intermedio.crt';
      case Environment.prod:
        return 'assets/certs/prod_intermedio.crt';
    }
  }

  // URL del archivo estático que consulta AppUpdateService — host aparte del
  // backend del CRM, nunca compone con baseUrl (ver ApiConstants.urlVersionCheck).
  static String get urlVersionCheck {
    switch (current) {
      case Environment.dev:
      case Environment.qa:
        return 'https://natcodee.net:40805/gs1pe_crm/update/version.json';
      case Environment.prod:
        return 'https://intranet.gs1pe.org.pe/update/version.json';
    }
  }

  // Configuraciones adicionales
  static const Duration timeoutDuration = Duration(seconds: 30);
  static const int maxRetries = 3;
}
