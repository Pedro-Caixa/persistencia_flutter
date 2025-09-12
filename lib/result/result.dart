/// Classe genérica para representar o resultado de operações que podem falhar
/// Inspirada no padrão Result do Rust e outras linguagens funcionais
sealed class Result<T> {
  const Result();

  /// Factory constructor para criar um resultado de sucesso
  factory Result.success(T data) = Success<T>;

  /// Factory constructor para criar um resultado de falha
  factory Result.failure(String message) = Failure<T>;

  /// Retorna true se o resultado é um sucesso
  bool get isSuccess => this is Success<T>;

  /// Retorna true se o resultado é uma falha
  bool get isFailure => this is Failure<T>;

  /// Retorna os dados em caso de sucesso, null em caso de falha
  T? get data => switch (this) {
    Success<T> success => success.data,
    Failure<T> _ => null,
  };

  /// Retorna a mensagem de erro em caso de falha, null em caso de sucesso
  String? get message => switch (this) {
    Success<T> _ => null,
    Failure<T> failure => failure.message,
  };

  /// Executa uma função se o resultado for sucesso
  Result<U> map<U>(U Function(T data) mapper) {
    return switch (this) {
      Success<T> success => Result.success(mapper(success.data)),
      Failure<T> failure => Result.failure(failure.message),
    };
  }

  /// Executa uma função que pode falhar se o resultado for sucesso
  Result<U> flatMap<U>(Result<U> Function(T data) mapper) {
    return switch (this) {
      Success<T> success => mapper(success.data),
      Failure<T> failure => Result.failure(failure.message),
    };
  }

  /// Executa uma função se o resultado for sucesso, ignora se for falha
  void onSuccess(void Function(T data) callback) {
    if (this case Success<T> success) {
      callback(success.data);
    }
  }

  /// Executa uma função se o resultado for falha, ignora se for sucesso
  void onFailure(void Function(String message) callback) {
    if (this case Failure<T> failure) {
      callback(failure.message);
    }
  }

  /// Executa funções diferentes dependendo do resultado
  U fold<U>({
    required U Function(T data) onSuccess,
    required U Function(String message) onFailure,
  }) {
    return switch (this) {
      Success<T> success => onSuccess(success.data),
      Failure<T> failure => onFailure(failure.message),
    };
  }
}

/// Representa um resultado de sucesso contendo dados
final class Success<T> extends Result<T> {
  /// Os dados do resultado bem-sucedido
  final T data;

  const Success(this.data);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Success<T> &&
            runtimeType == other.runtimeType &&
            data == other.data);
  }

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'Success(data: $data)';
}

/// Representa um resultado de falha contendo uma mensagem de erro
final class Failure<T> extends Result<T> {
  /// A mensagem de erro
  final String message;

  const Failure(this.message);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Failure<T> &&
            runtimeType == other.runtimeType &&
            message == other.message);
  }

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => 'Failure(message: $message)';
}

/// Extensões úteis para trabalhar com Result
extension ResultExtensions<T> on Result<T> {
  /// Retorna o valor ou um valor padrão em caso de falha
  T getOrElse(T defaultValue) {
    return switch (this) {
      Success<T> success => success.data,
      Failure<T> _ => defaultValue,
    };
  }

  /// Retorna o valor ou executa uma função para obter um valor padrão
  T getOrElseGet(T Function() defaultValueProvider) {
    return switch (this) {
      Success<T> success => success.data,
      Failure<T> _ => defaultValueProvider(),
    };
  }

  /// Retorna o valor ou lança uma exceção em caso de falha
  T getOrThrow() {
    return switch (this) {
      Success<T> success => success.data,
      Failure<T> failure => throw Exception(failure.message),
    };
  }
}

/// Extensões para trabalhar com Result que contém listas
extension ResultListExtensions<T> on Result<List<T>> {
  /// Retorna true se o resultado é sucesso e a lista não está vazia
  bool get isSuccessAndNotEmpty => isSuccess && (data?.isNotEmpty ?? false);

  /// Retorna true se o resultado é sucesso e a lista está vazia
  bool get isSuccessAndEmpty => isSuccess && (data?.isEmpty ?? true);

  /// Retorna o tamanho da lista em caso de sucesso, 0 em caso de falha
  int get length => data?.length ?? 0;
}

/// Extensões para trabalhar com Result que contém valores nullable
extension ResultNullableExtensions<T> on Result<T?> {
  /// Retorna true se o resultado é sucesso e o valor não é null
  bool get isSuccessAndNotNull => isSuccess && data != null;

  /// Retorna true se o resultado é sucesso e o valor é null
  bool get isSuccessAndNull => isSuccess && data == null;
}
