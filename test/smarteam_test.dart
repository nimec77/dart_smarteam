import 'package:smarteam/smarteam.dart';
import 'package:test/test.dart';

void main() {
  late final Smarteam smarteam;

  setUpAll(() {
    // smarteam = const Smarteam()..init();
  });

  // test('Smarteam is MonoState test', () {
  //   const smart1 = Smarteam();
  //   const smart2 = Smarteam();
  //
  //   expect(smart1 == smart2, equals(true));
  // });

  test('Smarteam Init test', () async {
    smarteam = const Smarteam();
    final result = await smarteam.init();
    expect(result, isA<EitherBool>());
    expect(result.isRight(), equals(true));
  });

  // test('Smarteam Init many times test', () async {
  //   final result1 = await smarteam.init();
  //   expect(result1, isA<EitherBool>());
  //   expect(result1.isRight(), equals(true));
  //
  //   final result2 = await smarteam.init();
  //   expect(result2, isA<EitherBool>());
  //   expect(result2.isRight(), equals(true));
  // });
  //
  // test('Smarteam RigthTest test', () {
  //   final result = smarteam.rightTest();
  //
  //   expect(result, isA<EitherBool>());
  //   expect(result.isRight(), equals(true));
  //   expect(result | false, equals(true));
  // });
  //
  // test('Smarteam LeftTest test', () {
  //   final result = smarteam.leftTest();
  //
  //   expect(result, isA<EitherBool>());
  //   expect(result.isLeft(), equals(true));
  //   result.leftMap((l) {
  //     expect(l, isA<SmartRuntimeError>());
  //     expect(l.toString(), equals('SmartRuntimeError: Runtime Error'));
  //   });
  // });
}
