// lib\config\env\env_config.dart

enum Environment { dev, qa, prod }

class EnvConfig {
  // Entorno actual (cámbialo según necesites)
  static const Environment current = Environment.dev;

  // Configuración según entorno
  static String get baseUrl {
    switch (current) {
      case Environment.dev:
        return 'https://expediter-falsify-spinach.ngrok-free.dev/app2/'; // URL DE DEV
      case Environment.qa:
        return 'https://natcodee.net:40805/gs1pe_interfaz/'; // URL DE QA
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
        return ''; // URL DE PRODUCCION
    }
  }

  // Configuraciones adicionales
  static const Duration timeoutDuration = Duration(seconds: 30);
  static const int maxRetries = 3;
}
