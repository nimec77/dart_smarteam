// ignore_for_file: avoid_print
import 'package:dart_smarteam/smarteam.dart';

Future<void> main() async {
  const smarteam = Smarteam();
  await smarteam.init();
  final result = await smarteam.userLogin('username', 'password');
  result.fold(
    print,
    print,
  );
  await smarteam.dispose();
}
