import 'package:flutter/material.dart';
import 'package:data_strings/src/question.dart';
import 'dart:ui' as ui;

class DataStringsPainter extends CustomPainter {
  final String title;
  final String? description;
  final List<Question> questions;
  final List<List<int>> answers;
  final ui.Image? bgImage;
  // 12 for tablet, 8 for phone
  static const double fontSize = 12;

  DataStringsPainter({
    required this.title,
    this.description,
    required this.questions,
    required this.answers,
    this.bgImage,
  });

  List<Offset> _computeQuestionPoints(
      Question question, double x, double height) {
    return question.choices
        .asMap()
        .map((i, choice) {
          final y = height * ((i + 1) / (question.choices.length + 1));
          return MapEntry(i, Offset(x, y));
        })
        .values
        .toList();
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (bgImage != null) {
      final srcRect = Rect.fromLTWH(0, 0, bgImage!.width.toDouble(),
          bgImage!.height.toDouble());
      final destRect = Offset.zero & size;
      canvas.drawImageRect(bgImage!, srcRect, destRect, Paint());
    }

    // Column layout
    final columnWidth = size.width / questions.length;

    var x = columnWidth / 2;
    List<List<Offset>> questionPointList = [];
    for (var i = 0; i < questions.length; i++) {
      final questionSpan = TextSpan(
        text: questions[i].text,
        style: const TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      );
      final questionPainter = TextPainter(
        text: questionSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      questionPainter.layout(maxWidth: columnWidth);
      questionPainter.paint(canvas, Offset(x - questionPainter.width / 2, 5));

      final questionPoints =
          _computeQuestionPoints(questions[i], x, size.height);
      questionPointList.add(questionPoints);
      // Draw question
      for (var j = 0; j < questions[i].choices.length; j++) {
        //canvas.drawCircle(point, 2, Paint()..color = Colors.black);
        final choicePainter = TextSpan(
          text: questions[i].choices[j],
          style: const TextStyle(
            fontSize: fontSize,
            color: Colors.black,
          ),
        );
        final choiceTextPainter = TextPainter(
          text: choicePainter,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );
        choiceTextPainter.layout(maxWidth: columnWidth);
        choiceTextPainter.paint(canvas,
            Offset(x - choiceTextPainter.width / 2, questionPoints[j].dy - 6));
      }

      x += columnWidth;
    }

    // Draw answers
    for (var i = 0; i < answers.length; i++) {
      Color color = Colors.primaries[answers[i][0] % Colors.primaries.length];

      for (var j = 0; j < questions.length - 1; j++) {
        final currentPoint = questionPointList[j][answers[i][j]];
        final nextPoint = questionPointList[j + 1][answers[i][j + 1]];
        canvas.drawLine(currentPoint, nextPoint, Paint()..color = color);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
