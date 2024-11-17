import 'package:data_strings/src/pages/question.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<StatefulWidget> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(backgroundColor: const Color(0xFFE9C46A)),
        body: Form(
          key: _formKey,
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                Text('Profile', style: Theme.of(context).textTheme.headlineMedium),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'First Name'),
                  controller: _firstNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Last Name'),
                  controller: _lastNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuestionPage(
                              answers: const [],
                              index: 0,
                              firstName: _firstNameController.text,
                              lastName: _lastNameController.text),
                        ),
                      );
                    }
                  },
                  child: const Text('Submit'),
                ),
              ])),
        ));
  }
}
