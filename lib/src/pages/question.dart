import 'package:data_strings/main.dart';
import 'package:data_strings/src/db/db.dart';
import 'package:data_strings/src/db/models/answer.dart';
import 'package:data_strings/src/pages/data_strings.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class QuestionPage extends StatefulWidget {
  const QuestionPage(
      {super.key,
      required this.firstName,
      required this.lastName,
      required this.index,
      required this.answers});

  final int index;
  final List<int> answers;
  final String firstName;
  final String lastName;

  @override
  createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  int? _selectedChoice;
  final AnswerService _answerService = AnswerService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color(0xFFE9C46A)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(children: [
          Text(questions[widget.index].text,
              style: Theme.of(context).textTheme.headlineMedium),
          ...questions[widget.index].choices.mapIndexed((index, choice) {
            return RadioListTile<int>(
              title: Text(choice),
              value: index,
              groupValue: _selectedChoice,
              onChanged: (value) {
                setState(() {
                  _selectedChoice = value;
                });
              },
            );
          }),
          ElevatedButton(
            onPressed: () async {
              if (_selectedChoice != null) {
                if (widget.index == questions.length - 1) {
                  final choices = [...widget.answers, _selectedChoice!];
                  await _answerService.addAnswer(
                      widget.firstName, widget.lastName, choices);
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DataStringsPage(
                                  firstName: widget.firstName,
                                  lastName: widget.lastName,
                                )),
                        (route) => route.isFirst);
                  }
                  return;
                }

                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuestionPage(
                      index: widget.index + 1,
                      answers: [...widget.answers, _selectedChoice!],
                      firstName: widget.firstName,
                      lastName: widget.lastName,
                    ),
                  ),
                );
              }
            },
            child: const Text('Next'),
          ),
        ]),
      ),
    );
  }
}
