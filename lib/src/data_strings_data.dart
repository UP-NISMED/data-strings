import 'package:data_strings/src/question.dart';
import 'package:equatable/equatable.dart';
import 'package:quiver/iterables.dart';
import 'dart:ui' as ui;

class DataStringsData extends Equatable {
  final String title;
  final String? description;
  final List<Question> questions;
  final List<List<int>> answers;
  final ui.Image? bgImage; 

  DataStringsData._({
    required this.title,
    this.description,
    required this.questions,
    required this.answers,
    this.bgImage,
  }) {
    // Assert the the answers are valid (within the range of the choices)
    for (final answer in answers) {
      for (final pair in zip([questions, answer])) {
        final question = pair[0] as Question;
        final choice = pair[1] as int;
        assert(choice >= 0 && choice < question.choices.length);
      }
    }
  }

  factory DataStringsData.create({
    required String title,
    String? description,
    required List<Question> questions,
    required List<List<int>> answers,
    ui.Image? bgImage,
    String? bgImagePath,
  }) {
    return DataStringsData._(
      title: title,
      description: description,
      questions: questions,
      answers: answers,
      bgImage: bgImage,
    );
  }

  @override
  List<Object?> get props => [title, description, questions, answers, bgImage];
}
