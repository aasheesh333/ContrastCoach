import 'package:contrast_coach/core/errors/app_exception.dart';

sealed class Result<T, E extends AppException> {
  const Result();

  bool get isOk => this is Ok<T, E>;
  bool get isErr => this is Err<T, E>;

  R fold<R>(R Function(E error) onErr, R Function(T value) onOk) {
    final self = this;
    if (self is Ok<T, E>) return onOk(self.value);
    return onErr((self as Err<T, E>).error);
  }
}

class Ok<T, E extends AppException> extends Result<T, E> {
  const Ok(this.value);
  final T value;
}

class Err<T, E extends AppException> extends Result<T, E> {
  const Err(this.error);
  final E error;
}
