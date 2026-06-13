import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result', () {
    test('Ok carries a value', () {
      const r = Ok<int, AppException>(42);
      expect(r.isOk, isTrue);
      expect(r.isErr, isFalse);
      expect(r.value, 42);
    });

    test('Err carries an error', () {
      const r = Err<int, AppException>(DatabaseException('boom'));
      expect(r.isOk, isFalse);
      expect(r.isErr, isTrue);
      expect((r as Err).error, isA<DatabaseException>());
    });

    test('fold dispatches on Ok/Err', () {
      const ok = Ok<int, AppException>(1);
      const err = Err<int, AppException>(DatabaseException('x'));
      expect(ok.fold((e) => 'err', (v) => 'ok:$v'), 'ok:1');
      expect(err.fold((e) => 'err:${e.message}', (v) => 'ok:$v'), 'err:x');
    });
  });
}
