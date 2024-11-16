import 'package:data_strings/src/db/utils.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:data_strings/src/db/models/answer.dart';

class AnswerService {
  final String _boxName = 'answerBox';

  Future<Box<Answer>> get _box async => await Hive.openBox<Answer>(_boxName);

  Future<void> addAnswer(
      String firstName, String lastName, List<int> choices) async {
    final box = await _box;
    await box.add(Answer(
        id: generateId(),
        firstName: firstName,
        lastName: lastName,
        choices: choices));
  }

  Future<List<Answer>> getAllAnswers() async {
    final box = await _box;
    return box.values.toList();
  }
}
