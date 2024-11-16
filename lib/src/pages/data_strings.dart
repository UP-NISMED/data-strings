import 'dart:async';
import 'dart:ui' as ui;
import 'package:data_strings/main.dart';
import 'package:data_strings/src/data_strings.dart';
import 'package:data_strings/src/data_strings_data.dart';
import 'package:data_strings/src/db/db.dart';
import 'package:data_strings/src/db/models/answer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DataStringsPage extends StatefulWidget {
  const DataStringsPage({super.key, this.firstName, this.lastName});

  final String? firstName;
  final String? lastName;

  @override
  State<StatefulWidget> createState() => _DataStringsPageState();
}

class _DataStringsPageState extends State<DataStringsPage> {
  final AnswerService _answerService = AnswerService();

  Future<ui.Image> _loadBgImage() async {
    final data = await rootBundle.load('assets/bg.png');
    final bytes = data.buffer.asUint8List();
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(bytes, completer.complete);
    return completer.future;
  }

  Future<void> openBox() async {
    await Hive.openBox<Answer>('answerBox');
  }

  @override
  void initState() {
    super.initState();
    openBox();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return Scaffold(
      appBar: AppBar(backgroundColor: const Color(0xFFE9C46A)),
      body: Column(
        children: [
          const Row(children: []),
          Expanded(
              child: FutureBuilder(
                  future: _answerService.getAllAnswers(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return const Center(child: Text('Error loading image'));
                    }

                    return ValueListenableBuilder(
                        valueListenable:
                            Hive.box<Answer>('answerBox').listenable(),
                        builder: (context, box, _) {
                          final answers = box.values.map((answer) => answer.choices).toList();
                          return DataStrings(
                              dataStringData: DataStringsData.create(
                            title: 'STEM',
                            questions: questions,
                            answers: answers,
                          ));
                        });
                  }))
        ],
      ),
    );
  }
}
