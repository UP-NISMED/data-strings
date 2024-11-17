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

    return Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/home.png'), fit: BoxFit.fitWidth)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
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
              ElevatedButton(onPressed: () {}, child: const Text('Settings'))
            ],
          ),
        ));
  }
}
