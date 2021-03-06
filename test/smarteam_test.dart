// ignore_for_file: avoid_print

import 'package:dart_smarteam/smarteam.dart';
import 'package:test/test.dart';

import 'constants.dart' as test_constants;

void main() {
  late final Smarteam smarteam;

  setUpAll(() async {
    smarteam = const Smarteam();
    await smarteam.init();
  });

  tearDownAll(() async {
    await smarteam.dispose();
  });

  // group('Smarteam Create tests', () {
  //   test('Smarteam Init test', () async {
  //     const smart = Smarteam();
  //     final result = await smart.init();
  //
  //     expect(result, isA<EitherBool>());
  //     expect(result.isRight(), equals(true));
  //     expect(result | false, equals(true));
  //   });
  //
  //   test('Smarteam Dispose test', () async {
  //     await smarteam.dispose();
  //     final result = await smarteam.init();
  //
  //     result.leftMap(print);
  //     expect(result, isA<EitherBool>());
  //     expect(result.isRight(), equals(true));
  //     expect(result | false, equals(true));
  //   });
  // });

  group('Smarteam TestFunction test', () {
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
  });

  group('Smarteam SmartFunctions test', () {
    test('Smarteam UserLogoff test', () async {
      final result = await smarteam.userLogoff();

      result.leftMap(print);
      expect(result, isA<EitherBool>());
      expect(result.isRight(), equals(true));
      expect(result | false, equals(true));
    });

    test('Smarteam UserLogin test', () async {
      final result = await smarteam.userLogin(test_constants.kUsername, test_constants.kPassword);

      expect(result, isA<EitherBool>());
      expect(result.isRight(), equals(true));
      expect(result | false, equals(true));
    });
  });

  group('Smarteam SmartFunctions error test', () {
    test('Smarteam UserLogin with fake data', () async {
      await smarteam.userLogoff();
      final result = await smarteam.userLogin(test_constants.kUsername, test_constants.kFakePassword);

      print(result.toString());
      expect(result, isA<EitherBool>());
      expect(result.isRight(), equals(true));
      expect(result | true, equals(false));
    });
  });

  group('Smarteam CryptoFunctions test', () {
    test('Crypto GetSid test', () async {
      final result = await smarteam.getSid();

      expect(result, isA<EitherString>());
      expect(result.isRight(), equals(true));
    });

    test('Crypto Encode test', () async {
      final result = await smarteam.encode(test_constants.kEncodeTest);

      expect(result, isA<EitherString>());
      expect(result.isRight(), equals(true));
    });

    test('Crypto Decode test', () async {
      final encoded = await smarteam.encode(test_constants.kEncodeTest);
      final result = await smarteam.decode(encoded | '');

      expect(result, isA<EitherString>());
      expect(result.isRight(), equals(true));
      expect(result | '', equals(test_constants.kEncodeTest));
    });

    test('Crypto Decode error test', () async {
      final result = await smarteam.decode(test_constants.kEncodeTest);

      expect(result, isA<EitherString>());
      expect(result.isLeft(), equals(true));
      result.leftMap((l) {
        expect(l, isA<SmarteamError>());
        expect(l.toString(), equals('SmarteamError: invalid stoul argument'));
      });
    });
  });
}
