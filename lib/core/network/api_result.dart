// lib\core\network\api_result.dart

class ApiResult {
  final bool ok;
  final String code;
  final String message;

  ApiResult({required this.ok, required this.code, required this.message});
}
