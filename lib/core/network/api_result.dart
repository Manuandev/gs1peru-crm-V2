// lib/core/network/api_result.dart

sealed class ApiResult<T> {
  const ApiResult();
}

class ApiSuccess<T> extends ApiResult<T> {
  final T data;
  const ApiSuccess(this.data);
}

class ApiEmpty<T> extends ApiResult<T> {
  const ApiEmpty();
}

class ApiNoInternet<T> extends ApiResult<T> {
  const ApiNoInternet();
}

class ApiError<T> extends ApiResult<T> {
  final String message;
  const ApiError(this.message);
}