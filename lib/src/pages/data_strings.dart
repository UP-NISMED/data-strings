import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:collection/collection.dart';
import 'package:csv/csv.dart';
import 'package:data_strings/main.dart';
import 'package:data_strings/src/data_strings.dart';
import 'package:data_strings/src/data_strings_data.dart';
import 'package:data_strings/src/db/db.dart';
import 'package:data_strings/src/db/models/answer.dart';
import 'package:data_strings/src/indicator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
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

enum Presentation {
  dataStrings('Data Strings', 0),
  pieChart('Pie Chart', 1);

  const Presentation(this.label, this.value);
  final String label;
  final int value;
}

class _DataStringsPageState extends State<DataStringsPage> {
  final AnswerService _answerService = getIt<AnswerService>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController presentationController = TextEditingController();
  final TextEditingController questionController = TextEditingController();

  Presentation? presentation = Presentation.dataStrings;
  int? selectedQuestionIndex = 0;
  String? selectedName;
  String? error;

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

    return FutureBuilder(
        future: Future.wait([_answerService.getAllAnswers(), _loadBgImage()]),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading image'));
          }

          final [answers as List<Answer>, bgImage as ui.Image] = snapshot.data!;
          final choices = selectedName != null
              ? answers
                  .where((answer) =>
                      selectedName == '${answer.firstName} ${answer.lastName}')
                  .map((answer) => answer.choices)
                  .toList()
              : answers.map((answer) => answer.choices).toList();

          return Scaffold(
              appBar: AppBar(
                actions: [
                  IconButton(
                      onPressed: () async {
                        final res = const ListToCsvConverter().convert([
                          [
                            'First Name',
                            'Last Name',
                            ...questions.map((question) => question.text)
                          ],
                          ...answers.map((answer) {
                            return [
                              answer.firstName,
                              answer.lastName,
                              ...answer.choices.mapIndexed((index, choice) {
                                return questions[index].choices[choice];
                              })
                            ];
                          })
                        ]);

                        String? outputFile = await FilePicker.platform.saveFile(
                          dialogTitle: 'Save to CSV',
                          fileName: 'output.csv',
                          bytes: Uint8List.fromList(res.codeUnits),
                        );
                        if (outputFile == null || Platform.isAndroid || Platform.isIOS) {
                          return;
                        }

                        final file = File(outputFile);
                        await file.writeAsString(res);
                      },
                      icon: const Icon(Icons.download, color: Colors.white)),
                  IconButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              final serverUrlController = TextEditingController(
                                  text: _answerService.url);
                              GlobalKey<FormState> formKey =
                                  GlobalKey<FormState>();

                              return SimpleDialog(
                                title: const Text('Settings'),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Form(
                                        key: formKey,
                                        child: Column(
                                          children: [
                                            TextFormField(
                                              onChanged: (value) async {
                                                if (value.isEmpty) {
                                                  error =
                                                      'Server URL is required';
                                                  return;
                                                }

                                                _answerService
                                                    .testUrl(value)
                                                    .then((value) {
                                                  error = null;
                                                }).catchError((e) {
                                                  error = e.toString();
                                                });
                                              },
                                              validator: (value) => error,
                                              controller: serverUrlController,
                                              decoration: const InputDecoration(
                                                  labelText: 'Server URL'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                if (formKey.currentState!
                                                    .validate()) {
                                                  _answerService.url =
                                                      serverUrlController.text;
                                                }
                                              },
                                              child: const Text('Save'),
                                            ),
                                            ElevatedButton(
                                                onPressed: _answerService.url !=
                                                        null
                                                    ? () async {
                                                        try {
                                                          await _answerService
                                                              .pullNewRemoteAnswers();
                                                        } catch (e) {
                                                          _answerService.url =
                                                              null;
                                                        } finally {
                                                          setState(() {});
                                                        }
                                                      }
                                                    : null,
                                                child: const Text(
                                                    'Pull from remote')),
                                            ElevatedButton(
                                                onPressed: _answerService.url !=
                                                        null
                                                    ? () async {
                                                        try {
                                                          await _answerService
                                                              .pushNewLocalAnswers();
                                                        } catch (e) {
                                                          _answerService.url =
                                                              null;
                                                        } finally {
                                                          setState(() {});
                                                        }
                                                      }
                                                    : null,
                                                child: const Text(
                                                    'Push to remote')),
                                          ],
                                        )),
                                  )
                                ],
                              );
                            });
                      },
                      icon: const Icon(CupertinoIcons.globe,
                          color: Colors.white)),
                  IconButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                                    title: const Text('Delete all answers?'),
                                    actions: [
                                      TextButton(
                                          onPressed: () async {
                                            await _answerService
                                                .deleteAllAnswers();
                                            if (!context.mounted) return;
                                            Navigator.of(context).pop();
                                            setState(() {});
                                          },
                                          child: const Text('Yes')),
                                      TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('No')),
                                    ]));
                      },
                      icon: const Icon(Icons.delete, color: Colors.white)),
                  IconButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) => SimpleDialog(
                                    title: const Text('Filter'),
                                    children: [
                                      SimpleDialogOption(
                                        child: DropdownMenu<Presentation>(
                                            label: const Text('Presentation'),
                                            controller: presentationController,
                                            initialSelection:
                                                Presentation.dataStrings,
                                            onSelected: (Presentation? value) {
                                              setState(() {
                                                presentation = value;
                                              });
                                            },
                                            dropdownMenuEntries: Presentation
                                                .values
                                                .map((presentation) =>
                                                    DropdownMenuEntry(
                                                        value: presentation,
                                                        label:
                                                            presentation.label))
                                                .toList()),
                                      ),
                                      if (presentation ==
                                          Presentation.dataStrings)
                                        SimpleDialogOption(
                                          child: DropdownMenu(
                                              label: const Text('Name'),
                                              controller: nameController,
                                              initialSelection: 'All',
                                              onSelected: (value) {
                                                setState(() {
                                                  selectedName = value;
                                                });
                                              },
                                              dropdownMenuEntries: [
                                                if (selectedName != null)
                                                  const DropdownMenuEntry(
                                                      value: null,
                                                      label: 'All'),
                                                ...answers.map((answer) {
                                                  final fullName =
                                                      '${answer.firstName} ${answer.lastName}';
                                                  return DropdownMenuEntry(
                                                      value: fullName,
                                                      label: fullName);
                                                })
                                              ]),
                                        ),
                                      if (presentation == Presentation.pieChart)
                                        SimpleDialogOption(
                                          child: DropdownMenu(
                                              label: const Text('Question'),
                                              controller: questionController,
                                              onSelected: (value) {
                                                setState(() {
                                                  selectedQuestionIndex = value;
                                                });
                                              },
                                              dropdownMenuEntries: questions
                                                  .mapIndexed(
                                                      (index, question) {
                                                return DropdownMenuEntry(
                                                    value: index,
                                                    label: question.text);
                                              }).toList()),
                                        ),
                                    ]));
                      },
                      icon: const Icon(Icons.settings, color: Colors.white)),
                ],
                backgroundColor: const Color(0xFFE9C46A),
              ),
              body: () {
                switch (presentation) {
                  case Presentation.pieChart:
                    return Row(
                      children: [
                        Expanded(
                            child: PieChart(PieChartData(
                                centerSpaceRadius: 0,
                                sections: questions[selectedQuestionIndex!]
                                    .choices
                                    .mapIndexed((index, choice) {
                                  final count = answers
                                      .where((answer) =>
                                          answer.choices[
                                              selectedQuestionIndex!] ==
                                          index)
                                      .length
                                      .toDouble();
                                  return PieChartSectionData(
                                      value: count,
                                      title:
                                          '${(count / answers.length * 100).toStringAsFixed(2)}%',
                                      titleStyle: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                      radius: 140,
                                      color: Colors.primaries[
                                          index % Colors.primaries.length]);
                                }).toList()))),
                        Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: questions[selectedQuestionIndex!]
                                .choices
                                .mapIndexed((index, choice) {
                              return Indicator(
                                color: Colors
                                    .primaries[index % Colors.primaries.length],
                                text: choice,
                                isSquare: true,
                              );
                            }).toList())
                      ],
                    );
                  default:
                    return DataStrings(
                        dataStringData: DataStringsData.create(
                            title: 'STEM',
                            questions: questions,
                            answers: choices,
                            bgImage: bgImage));
                }
              }());
        });
  }
}
