import 'dart:async';
import 'dart:ui' as ui;
import 'package:data_strings/main.dart';
import 'package:data_strings/src/data_strings.dart';
import 'package:data_strings/src/data_strings_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DataStringsPage extends StatelessWidget {
  const DataStringsPage({super.key, this.firstName, this.lastName});

  final String? firstName;
  final String? lastName;

  Future<ui.Image> _loadBgImage() async {
    final data = await rootBundle.load('assets/bg.png');
    final bytes = data.buffer.asUint8List();
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(bytes, completer.complete);
    return completer.future;
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
                  future: _loadBgImage(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return const Center(child: Text('Error loading image'));
                    }

                    debugPrint('Loaded image: ${snapshot.data}');
                    return DataStrings(
                        dataStringData: DataStringsData.create(
                            title: 'STEM',
                            questions: questions,
                            answers: const [],
                            bgImage: snapshot.data));
                  }))
        ],
      ),
    );
  }
}
