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

          final [_, bgImage as ui.Image] = snapshot.data!;

          return ValueListenableBuilder(
              valueListenable: Hive.box<Answer>('answerBox').listenable(),
              builder: (context, box, _) {
                final answers = box.values
                    .where((answer) =>
                        selectedName ==
                        '${answer.firstName} ${answer.lastName}')
                    .map((answer) => answer.choices)
                    .toList();

                return Scaffold(
                    appBar: AppBar(
                      backgroundColor: const Color(0xFFE9C46A),
                      actions: [
                        IconButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      SimpleDialog(
                                          title: const Text('Filter'),
                                          children: [
                                            SimpleDialogOption(
                                              child: DropdownMenu(
                                                  label: const Text('Name'),
                                                  controller: nameController,
                                                  onSelected: (value) {
                                                    setState(() {
                                                      selectedName = value;
                                                    });
                                                  },
                                                  dropdownMenuEntries: [
                                                    const DropdownMenuEntry(
                                                        value: null,
                                                        label: 'All'),
                                                    ...box.values.map((answer) {
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
                            icon:
                                const Icon(Icons.settings, color: Colors.white))
                      ],
                    ),
                    body: DataStrings(
                        dataStringData: DataStringsData.create(
                            title: 'STEM',
                            questions: questions,
                            answers: answers,
                            bgImage: bgImage)));
              });
        });
  }
}
