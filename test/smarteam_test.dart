import 'package:smarteam/smarteam.dart';
import 'package:test/test.dart';

void main() {
  late final Smarteam smarteam;

  setUpAll(() async {
    smarteam = const Smarteam();
    await smarteam.init();
  });

  test('Smarteam Init test', () async {
    const smart = Smarteam();
    final result = await smart.init();

    expect(result, isA<EitherBool>());
    expect(result.isRight(), equals(true));
    expect(result | false, equals(true));
  });

  test('Smarteam Dispose test', () async {
    await smarteam.dispose();
    final result = await smarteam.init();

    expect(result, isA<EitherBool>());
    expect(result.isRight(), equals(true));
    expect(result | false, equals(true));
  });

  test('Smarteam RightTest test', () async {
    final result = await smarteam.rightTest();

    expect(result, isA<EitherBool>());
    expect(result.isRight(), equals(true));
    expect(result | false, equals(true));
  });

  test('Smarteam LeftTest test', () async {
    final result = await smarteam.leftTest();

    expect(result, isA<EitherBool>());
    expect(result.isLeft(), equals(true));
    result.leftMap((l) {
      expect(l, isA<SmartRuntimeError>());
      expect(l.toString(), equals('SmartRuntimeError: Runtime Error'));
    });
  });
}
