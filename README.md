A library for Dart developers.

## Usage

A simple usage example:

```dart
import 'package:dart_smarteam/smarteam.dart';

main() async {
  const smarteam = Smarteam();
  await smarteam.init();
  final result = await smarteam.userLogin('username', 'password');
  result.fold(
    print,
    print,
  );
  await smarteam.dispose();
}
```
For more see [examples][tests]

[tests]: https://github.com/nimec77/dart_smarteam/blob/master/test/smarteam_test.dart

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/nimec77/dart_smarteam/issues
