import 'package:data_strings/src/data_strings_data.dart';
import 'package:data_strings/src/data_strings_painter.dart';
import 'package:flutter/material.dart';

class DataStrings extends StatelessWidget {
  final DataStringsData dataStringData;
  final Size? size;
  final Color? fontColor;

  const DataStrings(
      {super.key, required this.dataStringData, this.size, this.fontColor});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: size ?? Size.infinite,
      painter: DataStringsPainter(
          title: dataStringData.title,
          description: dataStringData.description,
          questions: dataStringData.questions,
          answers: dataStringData.answers,
          bgImage: dataStringData.bgImage),
    );
  }
}
