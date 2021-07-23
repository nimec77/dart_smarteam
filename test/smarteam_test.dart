import 'package:smarteam/smarteam.dart';
import 'package:test/test.dart';

void main() {
  test('Smarteam Init test', () async {
    const smarteam = Smarteam();
    final result = await smarteam.init();

    expect(result, isA<EitherBool>());
    expect(result.isRight(), equals(true));
    expect(result | false, equals(true));
  });
}
