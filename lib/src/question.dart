import 'package:equatable/equatable.dart';

class Question extends Equatable {
  final String text;
  final List<String> choices;

  const Question({
    required this.text,
    required this.choices,
  });

  @override
  List<Object?> get props => [text, choices];
}
