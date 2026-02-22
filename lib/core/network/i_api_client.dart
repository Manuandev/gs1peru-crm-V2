/// Contrato del cliente HTTP.
///
/// IMPLEMENTACIONES POSIBLES:
/// - Dio   → usar [dio] package (recomendado)
/// - http  → usar [http] package
///
/// PARA IMPLEMENTAR:
/// 1. Crea tu clase en [api_client.dart]
/// 2. Implementa esta interfaz
/// 3. Regístrala en [injection_container.dart]
abstract class IApiClient {
  Future<Map<String, dynamic>> get(String endpoint);

  Future<Map<String, dynamic>> post(
    String endpoint, {
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> put(
    String endpoint, {
    required Map<String, dynamic> body,
  });

  Future<void> delete(String endpoint);
}