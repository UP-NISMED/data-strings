import 'package:data_strings/main.dart';
import 'package:data_strings/src/db/db.dart';
import 'package:data_strings/src/pages/data_strings.dart';
import 'package:data_strings/src/pages/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    final answerService = getIt<AnswerService>();
    String? error;

    return Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/home.png'), fit: BoxFit.contain)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfilePage(),
                    ),
                  );
                },
                child: const Text('Start'),
              ),
              const SizedBox(width: 10, height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DataStringsPage(),
                    ),
                  );
                },
                child: const Text('View Answers'),
              ),
              const SizedBox(width: 10, height: 10),
              ElevatedButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          final serverUrlController = TextEditingController(text: answerService.url);
                          GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
                                          error = 'Server URL is required';
                                          return;
                                        }

                                        answerService.testUrl(value).then((value) {
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
                                        if (formKey.currentState!.validate()) {
                                          answerService.url =
                                              serverUrlController.text;
                                          Navigator.pop(context);
                                        }
                                      },
                                      child: const Text('Save'),
                                    )
                                  ],
                                )),
                              )
                            ],
                          );
                        });
                  },
                  child: const Text('Settings'))
            ],
          ),
        ));
  }
}
