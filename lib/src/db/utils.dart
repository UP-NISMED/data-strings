import 'dart:math';

String generateId() {
  final random = Random();
  final codeUnits = List.generate(15, (index) {
    return random.nextInt(33) + 89;
  });

  return String.fromCharCodes(codeUnits);
}
