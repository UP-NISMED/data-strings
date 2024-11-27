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
  final AnswerService _answerService = getIt<AnswerService>();
  final TextEditingController nameController = TextEditingController();
  String? selectedName;

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
                      disabledColor: Colors.grey,
                      onPressed: _answerService.url != null
                          ? () async {
                              try {
                                await _answerService.pushNewLocalAnswers();
                              } catch (e) {
                                _answerService.url = null;
                              } finally {
                                setState(() {});
                              }
                            }
                          : null,
                      icon: const Icon(Icons.upload, color: Colors.white)),
                  IconButton(
                      disabledColor: Colors.grey,
                      onPressed: _answerService.url != null
                          ? () async {
                              try {
                                await _answerService.pullNewRemoteAnswers();
                              } catch (e) {
                                _answerService.url = null;
                              } finally {
                                setState(() {});
                              }
                            }
                          : null,
                      icon: const Icon(Icons.download, color: Colors.white)),
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
                                              const DropdownMenuEntry(
                                                  value: null, label: 'All'),
                                              ...answers.map((answer) {
                                                final fullName =
                                                    '${answer.firstName} ${answer.lastName}';
                                                return DropdownMenuEntry(
                                                    value: fullName,
                                                    label: fullName);
                                              })
                                            ]),
                                      )
                                    ]));
                      },
                      icon: const Icon(Icons.settings, color: Colors.white)),
                ],
                backgroundColor: const Color(0xFFE9C46A),
              ),
              body: DataStrings(
                  dataStringData: DataStringsData.create(
                      title: 'STEM',
                      questions: questions,
                      answers: choices,
                      bgImage: bgImage)));
        });
  }
}
